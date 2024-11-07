FROM ubuntu:22.04

ARG SRC=/mupdf
RUN apt-get update && apt-get install -y make libtool pkg-config git zip clang libcurl4-openssl-dev vim llvm-dev lcov
RUN git clone --recursive --depth 1 https://github.com/ArtifexSoftware/mupdf.git $SRC
RUN git clone --depth 1 https://github.com/mozilla/pdf.js $SRC/pdf.js && \
    zip -q $SRC/pdf_fuzzer_seed_corpus.zip $SRC/pdf.js/test/pdfs/*.pdf && \
    rm -rf $SRC/pdf.js
# RUN echo core > /proc/sys/kernel/core_pattern
ADD https://raw.githubusercontent.com/rc0r/afl-fuzz/master/dictionaries/pdf.dict $SRC/pdf_fuzzer.dict
COPY *.cc $SRC/
COPY build.sh build_coverage.sh $SRC/

WORKDIR $SRC
