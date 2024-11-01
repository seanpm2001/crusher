#!/bin/bash -eu
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# supp_size is unused in harfbuzz so we will avoid it being unused.

./build_coverage.sh

sed -i 's/supp_size;/supp_size;(void)(supp_size);/g' ./thirdparty/harfbuzz/src/hb-subset-cff1.cc

if [ ! -d "/home/opt/crusher/third_party/AFLplusplus" ]; then
    ORIGDIR=$(pwd)
    cd /home/opt/crusher/third_party
    git clone https://github.com/AFLplusplus/AFLplusplus.git
    cd AFLplusplus
    git submodule init
    git submodule update --recursive --init
    make all -j $(nproc)
    cd $ORIGDIR
fi

export CC=/home/opt/crusher/third_party/AFLplusplus/afl-clang
export CXX=/home/opt/crusher/third_party/AFLplusplus/afl-clang++
export CFLAGS="-g"
export CXXFLAGS="-g"
export WORK=/fuzz/build
export OUT=/fuzz/build
export SRC=.
export LIB_FUZZING_ENGINE=$CXXFLAGS

LDFLAGS="$CXXFLAGS" make -j$(nproc) HAVE_GLUT=no build=debug OUT=$WORK \
    $WORK/libmupdf-third.a $WORK/libmupdf.a
fuzz_target=pdf_fuzzer

$CXX $CXXFLAGS -std=c++11 -Iinclude \
    $SRC/pdf_fuzzer.cc -o $OUT/$fuzz_target \
    $LIB_FUZZING_ENGINE $WORK/libmupdf.a $WORK/libmupdf-third.a

cp $SRC/{*.zip,*.dict,*.options} $OUT

if [ ! -f "${OUT}/${fuzz_target}_seed_corpus.zip" ]; then
  echo "missing seed corpus"
  exit 1
fi

unzip -j $OUT/pdf_fuzzer_seed_corpus.zip -d $OUT/pdfs

cp /fuzz/llm_corpus/*.pdf $OUT/pdfs

if [ ! -f "${OUT}/${fuzz_target}.dict" ]; then
  echo "missing dictionary"
  exit 1
fi

if [ ! -f "${OUT}/${fuzz_target}.options" ]; then
  echo "missing options"
  exit 1
fi


