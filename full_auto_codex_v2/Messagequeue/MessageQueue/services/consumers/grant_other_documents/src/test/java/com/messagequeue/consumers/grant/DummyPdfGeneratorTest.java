package com.messagequeue.consumers.grant;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

import org.junit.jupiter.api.Test;

class DummyPdfGeneratorTest {
  @Test
  void generateDoesNotThrow() {
    DummyPdfGenerator generator = new DummyPdfGenerator();
    assertDoesNotThrow(() -> generator.generate("grant_other_documents"));
  }
}
