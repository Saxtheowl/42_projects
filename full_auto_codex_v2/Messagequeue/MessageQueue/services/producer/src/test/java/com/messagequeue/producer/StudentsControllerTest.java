package com.messagequeue.producer;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.HashMap;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class StudentsControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private ObjectMapper objectMapper;

  @Test
  void rejectMissingRequiredField() throws Exception {
    Map<String, Object> payload = new HashMap<>();
    payload.put("studentId", "S-1");
    payload.put("firstName", "Ada");
    payload.put("lastName", "Lovelace");

    mockMvc.perform(post("/students")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsBytes(payload)))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.status").value("missing or invalid field: email"));
  }

  @Test
  void acceptValidPayload() throws Exception {
    Map<String, Object> payload = new HashMap<>();
    payload.put("studentId", "S-2");
    payload.put("firstName", "Grace");
    payload.put("lastName", "Hopper");
    payload.put("email", "grace@example.com");
    payload.put("grantType", "grant.1.contract");

    mockMvc.perform(post("/students")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsBytes(payload)))
        .andExpect(status().isAccepted())
        .andExpect(jsonPath("$.status").value("queued"))
        .andExpect(jsonPath("$.routingKey").value("grant.1.contract"));
  }

  @Test
  void healthEndpoint() throws Exception {
    mockMvc.perform(get("/health"))
        .andExpect(status().isOk())
        .andExpect(content().string("ok"));
  }
}
