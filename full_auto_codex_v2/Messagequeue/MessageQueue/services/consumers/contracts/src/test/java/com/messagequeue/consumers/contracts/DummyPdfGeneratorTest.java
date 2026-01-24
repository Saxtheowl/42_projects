package com.messagequeue.consumers.contracts;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class DummyPdfGeneratorTest {
  @Test
  void generateDoesNotThrow() {
    DummyPdfGenerator generator = new DummyPdfGenerator();
    assertDoesNotThrow(() -> generator.generate("grant_contracts"));
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
