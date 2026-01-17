package com.messagequeue.consumers.food;

import org.springframework.amqp.rabbit.annotation.EnableRabbit;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@EnableRabbit
@SpringBootApplication
public class FoodApplicationConsumerApplication {
  public static void main(String[] args) {
    SpringApplication.run(FoodApplicationConsumerApplication.class, args);
  }
}
