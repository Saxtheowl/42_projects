package com.messagequeue.consumers.transport;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

import org.junit.jupiter.api.Test;

class DummyPdfGeneratorTest {
  @Test
  void generateDoesNotThrow() {
    DummyPdfGenerator generator = new DummyPdfGenerator();
    assertDoesNotThrow(() -> generator.generate("transportation_costs_application"));
  }
}
