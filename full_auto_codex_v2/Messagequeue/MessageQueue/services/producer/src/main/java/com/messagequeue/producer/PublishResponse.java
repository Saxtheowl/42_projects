package com.messagequeue.producer;

public record PublishResponse(String status, String routingKey) {}
