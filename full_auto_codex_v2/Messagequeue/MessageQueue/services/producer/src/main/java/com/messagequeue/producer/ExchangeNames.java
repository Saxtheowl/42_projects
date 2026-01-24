package com.messagequeue.producer;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class ExchangeNames {
  private final String social;
  private final String grant;

  public ExchangeNames(
      @Value("${exchanges.social:SOCIAL_ASSISTANCE_EXCHANGE}") String social,
      @Value("${exchanges.grant:GRANT_EXCHANGE}") String grant) {
    this.social = social;
    this.grant = grant;
  }

  public String social() {
    return social;
  }

  public String grant() {
    return grant;
  }
}
