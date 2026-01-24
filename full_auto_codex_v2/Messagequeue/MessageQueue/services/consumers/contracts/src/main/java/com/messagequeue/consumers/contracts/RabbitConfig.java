package com.messagequeue.consumers.contracts;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.QueueBuilder;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitConfig {
  @Bean
  public Queue consumerQueue(@Value("${consumer.queue:grant_contracts}") String queueName) {
    return QueueBuilder.durable(queueName).build();
  }

  @Bean
  public TopicExchange grantExchange(
      @Value("${exchanges.grant:GRANT_EXCHANGE}") String exchangeName) {
    return new TopicExchange(exchangeName, true, false);
  }

  @Bean
  public Binding consumerBinding(
      Queue consumerQueue,
      TopicExchange grantExchange,
      @Value("${consumer.routing-key:grant.*.contract}") String routingKey) {
    return BindingBuilder.bind(consumerQueue).to(grantExchange).with(routingKey);
  }
}
