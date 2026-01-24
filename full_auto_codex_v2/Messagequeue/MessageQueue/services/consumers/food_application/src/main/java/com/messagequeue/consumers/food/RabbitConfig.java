package com.messagequeue.consumers.food;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.FanoutExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.QueueBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitConfig {
  @Bean
  public Queue consumerQueue(@Value("${consumer.queue:food_application}") String queueName) {
    return QueueBuilder.durable(queueName).build();
  }

  @Bean
  public FanoutExchange socialExchange(
      @Value("${exchanges.social:SOCIAL_ASSISTANCE_EXCHANGE}") String exchangeName) {
    return new FanoutExchange(exchangeName, true, false);
  }

  @Bean
  public Binding consumerBinding(Queue consumerQueue, FanoutExchange socialExchange) {
    return BindingBuilder.bind(consumerQueue).to(socialExchange);
  }
}
