# Microservices Demo

Demonstration of microservices architecture with multiple HTTP services.

## Architecture

```
                    ┌─────────────────┐
                    │   API Gateway   │
                    │   (port 8000)   │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  User Service   │ │  Order Service  │ │ Product Service │
│   (port 8001)   │ │   (port 8002)   │ │   (port 8003)   │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

## Features

- Service Registry (discovery)
- API Gateway (aggregation)
- Independent services
- RESTful APIs
- Health checks

## Usage

```bash
# Run all services
python3 microservices.py

# Run individual service
python3 microservices.py user
python3 microservices.py order
python3 microservices.py product
python3 microservices.py gateway
```

## Endpoints

### API Gateway (8000)
- `GET /api/dashboard` - System overview
- `GET /api/user-orders?user_id=1` - User with orders

### User Service (8001)
- `GET /users` - List all users
- `GET /users/{id}` - Get user
- `POST /users` - Create user
- `GET /health` - Health check

### Order Service (8002)
- `GET /orders` - List all orders
- `GET /orders?user_id=1` - User's orders
- `GET /orders/{id}` - Get order
- `POST /orders` - Create order

### Product Service (8003)
- `GET /products` - List all products
- `GET /products/{id}` - Get product

## Testing

```bash
# List users
curl http://localhost:8001/users

# Get specific user
curl http://localhost:8001/users/1

# Create user
curl -X POST http://localhost:8001/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Dave","email":"dave@example.com"}'

# Dashboard
curl http://localhost:8000/api/dashboard

# User with orders
curl "http://localhost:8000/api/user-orders?user_id=1"

# Health check
curl http://localhost:8001/health
```

## Concepts

### Service Discovery
Services register themselves with a central registry.
Gateway uses registry to find service instances.

### API Gateway
- Single entry point
- Request routing
- Data aggregation
- Cross-cutting concerns

### Communication
- Synchronous HTTP/REST
- JSON payloads
- Stateless services

## Production Considerations

For real-world deployment:
- Use Docker containers
- Add message queue (RabbitMQ, Kafka)
- Implement circuit breaker pattern
- Add distributed tracing
- Use proper service mesh (Istio)
- Implement authentication/authorization
- Add rate limiting
- Use database per service

## Requirements

- Python 3.6+
- No external dependencies

## Author

Implementation for 42 curriculum.
