package com.messagequeue.consumers.transport;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DummyPdfGenerator {
  private static final Logger log = LoggerFactory.getLogger(DummyPdfGenerator.class);

  public void generate(String docType) {
    if (isPdfDisabled()) {
      log.info("PDF generation disabled (PDF_DISABLED=1).");
      return;
    }
    Path scriptPath = resolveScriptPath();
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

  private Path resolveScriptPath() {
    Path base = Path.of(System.getProperty("user.dir"));
    Path direct = base.resolve("scripts").resolve("generate_dummy_pdf.py");
    if (Files.exists(direct)) {
      return direct;
    }
    return base.resolve("..").resolve("..").resolve("..")
        .resolve("scripts").resolve("generate_dummy_pdf.py").normalize();
  }

  boolean isPdfDisabled() {
    if ("1".equals(System.getenv("PDF_DISABLED"))) {
      return true;
    }
    return "1".equals(System.getProperty("pdf.disabled"));
  }
}
