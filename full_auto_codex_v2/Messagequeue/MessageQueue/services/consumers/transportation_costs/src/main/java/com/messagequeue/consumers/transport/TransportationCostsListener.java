package com.messagequeue.consumers.transport;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class TransportationCostsListener {
  private static final Logger log = LoggerFactory.getLogger(TransportationCostsListener.class);
  private final DummyPdfGenerator pdfGenerator = new DummyPdfGenerator();

  @RabbitListener(queues = "${consumer.queue:transportation_costs_application}")
  public void onMessage(String payload) {
    log.info("Received transportation_costs_application payload: {}", payload);
    pdfGenerator.generate("transportation_costs_application");
  }
}
