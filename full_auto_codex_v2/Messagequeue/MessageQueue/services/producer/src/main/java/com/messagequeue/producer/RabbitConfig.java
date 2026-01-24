package com.messagequeue.producer;

import org.springframework.amqp.core.FanoutExchange;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitConfig {
  private final ExchangeNames exchangeNames;

  public RabbitConfig(ExchangeNames exchangeNames) {
    this.exchangeNames = exchangeNames;
  }

  @Bean
  public FanoutExchange socialAssistanceExchange() {
    return new FanoutExchange(exchangeNames.social());
  }

  @Bean
  public TopicExchange grantExchange() {
    return new TopicExchange(exchangeNames.grant());
  }
}
