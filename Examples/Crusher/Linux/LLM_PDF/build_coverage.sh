#!/bin/bash -eu

# supp_size is unused in harfbuzz so we will avoid it being unused.
sed -i 's/supp_size;/supp_size;(void)(supp_size);/g' ./thirdparty/harfbuzz/src/hb-subset-cff1.cc

export CC=clang
export CXX=clang++
export CFLAGS="-g -fprofile-instr-generate -fcoverage-mapping"
export CXXFLAGS="-g -fprofile-instr-generate -fcoverage-mapping"
export WORK=/fuzz/build_cov
export OUT=/fuzz/build_cov
export SRC=.

LDFLAGS="$CXXFLAGS" make -j$(nproc) HAVE_GLUT=no build=debug OUT=$WORK \
    $WORK/libmupdf-third.a $WORK/libmupdf.a
fuzz_target=pdf_fuzzer

$CXX $CXXFLAGS -std=c++11 -Iinclude \
    $SRC/pdf_fuzzer.cc -o $OUT/$fuzz_target \
    $WORK/libmupdf.a $WORK/libmupdf-third.a

