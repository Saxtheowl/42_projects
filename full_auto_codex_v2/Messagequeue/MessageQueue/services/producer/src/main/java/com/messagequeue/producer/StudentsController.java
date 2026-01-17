package com.messagequeue.producer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Set;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageProperties;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class StudentsController {
  private static final String SOCIAL_EXCHANGE = "SOCIAL_ASSISTANCE_EXCHANGE";
  private static final String GRANT_EXCHANGE = "GRANT_EXCHANGE";

  private final RabbitTemplate rabbitTemplate;
  private final ObjectMapper objectMapper;
  private final Set<String> requiredFields =
      Set.of("studentId", "firstName", "lastName", "email");

  public StudentsController(RabbitTemplate rabbitTemplate, ObjectMapper objectMapper) {
    this.rabbitTemplate = rabbitTemplate;
    this.objectMapper = objectMapper;
  }

  @PostMapping("/students")
  public ResponseEntity<PublishResponse> publish(@RequestBody Map<String, Object> payload)
      throws JsonProcessingException {
    for (String field : requiredFields) {
      Object value = payload.get(field);
      if (!(value instanceof String) || ((String) value).isBlank()) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(new PublishResponse("missing or invalid field: " + field, ""));
      }
    }

    byte[] body = objectMapper.writeValueAsBytes(payload);

    MessageProperties props = new MessageProperties();
    props.setContentType(MessageProperties.CONTENT_TYPE_JSON);
    Message message = new Message(body, props);

    rabbitTemplate.send(SOCIAL_EXCHANGE, "", message);

    String grantType = "grant.1.contract";
    Object rawGrantType = payload.get("grantType");
    if (rawGrantType instanceof String && !((String) rawGrantType).isBlank()) {
      grantType = ((String) rawGrantType).trim();
    }

    rabbitTemplate.send(GRANT_EXCHANGE, grantType, message);

    return ResponseEntity.status(HttpStatus.ACCEPTED)
        .body(new PublishResponse("queued", grantType));
  }

  @GetMapping("/health")
  public ResponseEntity<String> health() {
    return ResponseEntity.ok("ok");
  }
}
