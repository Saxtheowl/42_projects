package com.messagequeue.consumers.grant;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class GrantOtherDocumentsListener {
  private static final Logger log = LoggerFactory.getLogger(GrantOtherDocumentsListener.class);
  private final DummyPdfGenerator pdfGenerator = new DummyPdfGenerator();

  @RabbitListener(queues = "${consumer.queue:grant_other_documents}")
  public void onMessage(String payload) {
    log.info("Received grant_other_documents payload: {}", payload);
    pdfGenerator.generate("grant_other_documents");
  }
}
