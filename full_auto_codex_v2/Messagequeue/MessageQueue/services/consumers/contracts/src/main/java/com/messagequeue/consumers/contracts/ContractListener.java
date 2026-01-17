package com.messagequeue.consumers.contracts;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class ContractListener {
  private static final Logger log = LoggerFactory.getLogger(ContractListener.class);
  private final DummyPdfGenerator pdfGenerator = new DummyPdfGenerator();

  @RabbitListener(queues = "${consumer.queue:grant_contracts}")
  public void onMessage(String payload) {
    log.info("Received grant_contracts payload: {}", payload);
    pdfGenerator.generate("grant_contracts");
  }
}
