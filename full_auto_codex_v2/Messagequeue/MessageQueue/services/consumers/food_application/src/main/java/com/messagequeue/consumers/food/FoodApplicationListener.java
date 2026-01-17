package com.messagequeue.consumers.food;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class FoodApplicationListener {
  private static final Logger log = LoggerFactory.getLogger(FoodApplicationListener.class);
  private final DummyPdfGenerator pdfGenerator = new DummyPdfGenerator();

  @RabbitListener(queues = "${consumer.queue:food_application}")
  public void onMessage(String payload) {
    log.info("Received food_application payload: {}", payload);
    pdfGenerator.generate("food_application");
  }
}
