package com.messagequeue.consumers.financial;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class FinancialAssistanceListener {
  private static final Logger log = LoggerFactory.getLogger(FinancialAssistanceListener.class);
  private final DummyPdfGenerator pdfGenerator = new DummyPdfGenerator();

  @RabbitListener(queues = "${consumer.queue:financial_assistance_application}")
  public void onMessage(String payload) {
    log.info("Received financial_assistance_application payload: {}", payload);
    pdfGenerator.generate("financial_assistance_application");
  }
}
