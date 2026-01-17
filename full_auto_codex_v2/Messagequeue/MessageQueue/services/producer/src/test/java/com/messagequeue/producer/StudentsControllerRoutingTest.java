package com.messagequeue.producer;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.HashMap;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class StudentsControllerRoutingTest {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private ObjectMapper objectMapper;

  @MockBean
  private RabbitTemplate rabbitTemplate;

  @Test
  void publishesToBothExchangesWithGrantType() throws Exception {
    Map<String, Object> payload = new HashMap<>();
    payload.put("studentId", "S-3");
    payload.put("firstName", "Katherine");
    payload.put("lastName", "Johnson");
    payload.put("email", "katherine@example.com");
    payload.put("grantType", "grant.2.contract");

    mockMvc.perform(post("/students")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsBytes(payload)))
        .andExpect(status().isAccepted());

    verify(rabbitTemplate, times(1))
        .send(eq("SOCIAL_ASSISTANCE_EXCHANGE"), eq(""), any(Message.class));
    verify(rabbitTemplate, times(1))
        .send(eq("GRANT_EXCHANGE"), eq("grant.2.contract"), any(Message.class));
  }
}
