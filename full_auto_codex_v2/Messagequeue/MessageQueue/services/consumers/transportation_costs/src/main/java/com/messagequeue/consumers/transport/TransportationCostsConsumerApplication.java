package com.messagequeue.consumers.transport;

import org.springframework.amqp.rabbit.annotation.EnableRabbit;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@EnableRabbit
@SpringBootApplication
public class TransportationCostsConsumerApplication {
  public static void main(String[] args) {
    SpringApplication.run(TransportationCostsConsumerApplication.class, args);
  }
}
