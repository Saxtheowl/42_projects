package com.messagequeue.consumers.contracts;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

import org.junit.jupiter.api.Test;

class DummyPdfGeneratorTest {
  @Test
  void generateDoesNotThrow() {
    DummyPdfGenerator generator = new DummyPdfGenerator();
    assertDoesNotThrow(() -> generator.generate("grant_contracts"));
  }
}
