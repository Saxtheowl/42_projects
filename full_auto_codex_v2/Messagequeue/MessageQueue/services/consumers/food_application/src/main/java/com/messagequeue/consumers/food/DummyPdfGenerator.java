package com.messagequeue.consumers.food;

import java.io.IOException;
import java.nio.file.Path;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DummyPdfGenerator {
  private static final Logger log = LoggerFactory.getLogger(DummyPdfGenerator.class);

  public void generate(String docType) {
    Path scriptPath = Path.of("..", "..", "..", "scripts", "generate_dummy_pdf.py");
    ProcessBuilder builder = new ProcessBuilder(scriptPath.toString());
    builder.environment().putAll(Map.of(
        "PDF_NAME", docType + "_dummy.pdf",
        "PDF_TEXT", docType + " dummy"
    ));

    try {
      Process process = builder.inheritIO().start();
      int code = process.waitFor();
      if (code != 0) {
        log.warn("Dummy PDF generator exited with code {}", code);
      }
    } catch (IOException | InterruptedException exc) {
      Thread.currentThread().interrupt();
      log.warn("Failed to generate dummy PDF", exc);
    }
  }
}
