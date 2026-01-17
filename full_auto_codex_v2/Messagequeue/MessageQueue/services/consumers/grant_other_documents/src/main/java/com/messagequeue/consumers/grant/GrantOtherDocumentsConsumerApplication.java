package com.messagequeue.consumers.grant;

import org.springframework.amqp.rabbit.annotation.EnableRabbit;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@EnableRabbit
@SpringBootApplication
public class GrantOtherDocumentsConsumerApplication {
  public static void main(String[] args) {
    SpringApplication.run(GrantOtherDocumentsConsumerApplication.class, args);
  }
}
