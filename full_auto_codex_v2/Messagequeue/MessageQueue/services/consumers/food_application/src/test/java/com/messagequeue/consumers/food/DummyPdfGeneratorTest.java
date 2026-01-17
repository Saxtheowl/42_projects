package com.messagequeue.consumers.food;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

import org.junit.jupiter.api.Test;

class DummyPdfGeneratorTest {
  @Test
  void generateDoesNotThrow() {
    DummyPdfGenerator generator = new DummyPdfGenerator();
    assertDoesNotThrow(() -> generator.generate("food_application"));
  }
}
