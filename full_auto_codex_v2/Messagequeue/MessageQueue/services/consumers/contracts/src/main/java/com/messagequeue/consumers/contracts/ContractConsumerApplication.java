package com.messagequeue.consumers.contracts;

import org.springframework.amqp.rabbit.annotation.EnableRabbit;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@EnableRabbit
@SpringBootApplication
public class ContractConsumerApplication {
  public static void main(String[] args) {
    SpringApplication.run(ContractConsumerApplication.class, args);
  }
}
