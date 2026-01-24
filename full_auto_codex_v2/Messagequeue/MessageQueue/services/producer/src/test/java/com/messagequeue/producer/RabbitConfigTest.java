package com.messagequeue.producer;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.amqp.core.FanoutExchange;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest(properties = {
    "exchanges.social=SOCIAL_EXCHANGE_TEST",
    "exchanges.grant=GRANT_EXCHANGE_TEST"
})
class RabbitConfigTest {

  @Autowired
  private FanoutExchange socialExchange;

  @Autowired
  private TopicExchange grantExchange;

  @Test
  void exchangesUseConfiguredNames() {
    assertThat(socialExchange.getName()).isEqualTo("SOCIAL_EXCHANGE_TEST");
    assertThat(grantExchange.getName()).isEqualTo("GRANT_EXCHANGE_TEST");
  }
}
