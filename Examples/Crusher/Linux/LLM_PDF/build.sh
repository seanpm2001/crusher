#!/bin/bash -eu

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

LDFLAGS="$CXXFLAGS" make -j$(nproc) HAVE_GLUT=no build=debug OUT=$WORK \
    $WORK/libmupdf-third.a $WORK/libmupdf.a
fuzz_target=pdf_fuzzer

$CXX $CXXFLAGS -std=c++11 -Iinclude \
    $SRC/pdf_fuzzer.cc -o $OUT/$fuzz_target \
    $WORK/libmupdf.a $WORK/libmupdf-third.a

cp $SRC/{*.zip} $OUT

if [ ! -f "${OUT}/${fuzz_target}_seed_corpus.zip" ]; then
  echo "missing seed corpus"
  exit 1
fi

unzip -j $OUT/pdf_fuzzer_seed_corpus.zip -d $OUT/pdfs

cp /fuzz/llm_corpus/*.pdf $OUT/pdfs

