package com.messagequeue.consumers.grant;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class DummyPdfGeneratorTest {
  @Test
  void generateDoesNotThrow() {
    DummyPdfGenerator generator = new DummyPdfGenerator();
    assertDoesNotThrow(() -> generator.generate("grant_other_documents"));
  }

  @Test
  void pdfDisabledFlagIsDetected() {
    System.setProperty("pdf.disabled", "1");
    try {
      DummyPdfGenerator generator = new DummyPdfGenerator();
      assertTrue(generator.isPdfDisabled());
    } finally {
      System.clearProperty("pdf.disabled");
    }
  }
}
