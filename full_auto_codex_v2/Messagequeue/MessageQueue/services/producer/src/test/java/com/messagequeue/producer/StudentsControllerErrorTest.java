package com.messagequeue.producer;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
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
class StudentsControllerErrorTest {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private ObjectMapper objectMapper;

  @Test
  void rejectsBlankEmail() throws Exception {
    Map<String, Object> payload = new HashMap<>();
    payload.put("studentId", "S-5");
    payload.put("firstName", "Ada");
    payload.put("lastName", "Lovelace");
    payload.put("email", " ");
    payload.put("grantType", "grant.1.contract");

    mockMvc.perform(post("/students")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsBytes(payload)))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.status").value("missing or invalid field: email"));
  }
}
