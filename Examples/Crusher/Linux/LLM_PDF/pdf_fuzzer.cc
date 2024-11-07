#include <cstdint>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include <stdio.h>
#include <assert.h>

#include <mupdf/fitz.h>


int test_pdf(const uint8_t *data, size_t size) {
  fz_context *ctx;
  fz_stream *stream;
  fz_document *doc;
  fz_pixmap *pix;

  ctx = fz_new_context(nullptr, nullptr, FZ_STORE_DEFAULT);
  stream = NULL;
  doc = NULL;
  pix = NULL;

  fz_var(stream);
  fz_var(doc);
  fz_var(pix);

  fz_try(ctx) {
    fz_register_document_handlers(ctx);
    stream = fz_open_memory(ctx, data, size);
    doc = fz_open_document_with_stream(ctx, "pdf", stream);

    for (int i = 0; i < fz_count_pages(ctx, doc); i++) {
      pix = fz_new_pixmap_from_page_number(ctx, doc, i, fz_identity, fz_device_rgb(ctx), 0);
      fz_drop_pixmap(ctx, pix);
      pix = NULL;
    }
  }
  fz_always(ctx) {
    fz_drop_pixmap(ctx, pix);
    fz_drop_document(ctx, doc);
    fz_drop_stream(ctx, stream);
  }
  fz_catch(ctx) {
    fz_report_error(ctx);
    fz_log_error(ctx, "error rendering pages");
  }

  fz_flush_warnings(ctx);
  fz_drop_context(ctx);

  return 0;
}


int main(int argc, char **argv) {
  if (argc != 2) {
    printf("Usage: ./pdf_fuzzer /path/to/file.pdf\n");
    exit(1);
  }
  printf("Running: %s\n", argv[1]);
  FILE *f = fopen(argv[1], "r");
  assert(f);
  fseek(f, 0, SEEK_END);
  size_t len = ftell(f);
  fseek(f, 0, SEEK_SET);
  unsigned char *buf = (unsigned char*)malloc(len);
  size_t n_read = fread(buf, 1, len, f);
  fclose(f);
  assert(n_read == len);
  test_pdf(buf, len);
  free(buf);
  printf("Done:    %s: (%zd bytes)\n", argv[1], n_read);
  return 0;
}
