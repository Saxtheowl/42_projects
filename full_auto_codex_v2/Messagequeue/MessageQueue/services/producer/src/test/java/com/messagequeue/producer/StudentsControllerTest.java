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

@SpringBootTest(properties = {
    "exchanges.social=SOCIAL_ASSISTANCE_EXCHANGE",
    "exchanges.grant=GRANT_EXCHANGE"
})
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
    payload.put("grantType", "grant.1.contract");

    mockMvc.perform(post("/students")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsBytes(payload)))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.status").value("missing or invalid field: email"));
  }

  @Test
  void rejectMissingGrantType() throws Exception {
    Map<String, Object> payload = new HashMap<>();
    payload.put("studentId", "S-1B");
    payload.put("firstName", "Ada");
    payload.put("lastName", "Lovelace");
    payload.put("email", "ada@example.com");

    mockMvc.perform(post("/students")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsBytes(payload)))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.status").value("missing or invalid field: grantType"));
  }

  @Test
  void rejectInvalidGrantTypeFormat() throws Exception {
    Map<String, Object> payload = new HashMap<>();
    payload.put("studentId", "S-1C");
    payload.put("firstName", "Ada");
    payload.put("lastName", "Lovelace");
    payload.put("email", "ada@example.com");
    payload.put("grantType", "contract");

    mockMvc.perform(post("/students")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsBytes(payload)))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.status").value(
            "invalid grantType: expected routing key like grant.* or grant.*.*"));
  }

  @Test
  void rejectGrantTypeWithEmptySegment() throws Exception {
    Map<String, Object> payload = new HashMap<>();
    payload.put("studentId", "S-1D");
    payload.put("firstName", "Ada");
    payload.put("lastName", "Lovelace");
    payload.put("email", "ada@example.com");
    payload.put("grantType", "grant..contract");

    mockMvc.perform(post("/students")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsBytes(payload)))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.status").value(
            "invalid grantType: expected routing key like grant.* or grant.*.*"));
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
