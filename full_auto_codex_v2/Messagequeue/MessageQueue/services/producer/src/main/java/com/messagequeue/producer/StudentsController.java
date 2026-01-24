package com.messagequeue.producer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.List;
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
  private final RabbitTemplate rabbitTemplate;
  private final ObjectMapper objectMapper;
  private final ExchangeNames exchangeNames;
  private final List<String> requiredFields =
      List.of("studentId", "firstName", "lastName", "email", "grantType");

  public StudentsController(RabbitTemplate rabbitTemplate, ObjectMapper objectMapper,
                            ExchangeNames exchangeNames) {
    this.rabbitTemplate = rabbitTemplate;
    this.objectMapper = objectMapper;
    this.exchangeNames = exchangeNames;
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

    String grantType = ((String) payload.get("grantType")).trim();
    String[] grantParts = grantType.split("\\.");
    if (grantParts.length < 2 || !"grant".equals(grantParts[0])) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST)
          .body(new PublishResponse(
              "invalid grantType: expected routing key like grant.* or grant.*.*", ""));
    }
    for (String part : grantParts) {
      if (part.isBlank()) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(new PublishResponse(
                "invalid grantType: expected routing key like grant.* or grant.*.*", ""));
      }
    }

    byte[] body = objectMapper.writeValueAsBytes(payload);

    MessageProperties props = new MessageProperties();
    props.setContentType(MessageProperties.CONTENT_TYPE_JSON);
    Message message = new Message(body, props);

    rabbitTemplate.send(exchangeNames.social(), "", message);
    rabbitTemplate.send(exchangeNames.grant(), grantType, message);

    return ResponseEntity.status(HttpStatus.ACCEPTED)
        .body(new PublishResponse("queued", grantType));
  }

  @GetMapping("/health")
  public ResponseEntity<String> health() {
    return ResponseEntity.ok("ok");
  }
}
