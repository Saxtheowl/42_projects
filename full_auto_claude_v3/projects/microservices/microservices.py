#!/usr/bin/env python3
"""
Microservices Demo
42 School Project - Architecture

Demonstrates microservices architecture with simple HTTP services.
"""

import sys
import json
import threading
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional
import random


# =============================================================================
# Service Registry (Service Discovery)
# =============================================================================

class ServiceRegistry:
    """Simple service registry for service discovery."""

    def __init__(self):
        self.services: Dict[str, List[Dict]] = {}
        self.lock = threading.Lock()

    def register(self, name: str, host: str, port: int):
        """Register a service instance."""
        with self.lock:
            if name not in self.services:
                self.services[name] = []
            instance = {'host': host, 'port': port, 'health': 'healthy'}
            self.services[name].append(instance)
            print(f"[Registry] Registered {name} at {host}:{port}")

    def deregister(self, name: str, host: str, port: int):
        """Deregister a service instance."""
        with self.lock:
            if name in self.services:
                self.services[name] = [
                    s for s in self.services[name]
                    if not (s['host'] == host and s['port'] == port)
                ]

    def get_instance(self, name: str) -> Optional[Dict]:
        """Get a service instance (simple round-robin)."""
        with self.lock:
            if name in self.services and self.services[name]:
                # Simple round-robin
                instances = [s for s in self.services[name] if s['health'] == 'healthy']
                if instances:
                    return random.choice(instances)
        return None

    def get_all(self, name: str) -> List[Dict]:
        """Get all instances of a service."""
        with self.lock:
            return self.services.get(name, [])


# Global registry
registry = ServiceRegistry()


# =============================================================================
# User Service
# =============================================================================

class UserService:
    """Microservice handling user data."""

    def __init__(self):
        self.users = {
            1: {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
            2: {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
            3: {'id': 3, 'name': 'Charlie', 'email': 'charlie@example.com'},
        }
        self.next_id = 4

    def get_user(self, user_id: int) -> Optional[Dict]:
        return self.users.get(user_id)

    def get_all_users(self) -> List[Dict]:
        return list(self.users.values())

    def create_user(self, name: str, email: str) -> Dict:
        user = {'id': self.next_id, 'name': name, 'email': email}
        self.users[self.next_id] = user
        self.next_id += 1
        return user


user_service = UserService()


# =============================================================================
# Order Service
# =============================================================================

class OrderService:
    """Microservice handling orders."""

    def __init__(self):
        self.orders = {
            1: {'id': 1, 'user_id': 1, 'product': 'Laptop', 'status': 'delivered'},
            2: {'id': 2, 'user_id': 1, 'product': 'Phone', 'status': 'shipped'},
            3: {'id': 3, 'user_id': 2, 'product': 'Tablet', 'status': 'processing'},
        }
        self.next_id = 4

    def get_order(self, order_id: int) -> Optional[Dict]:
        return self.orders.get(order_id)

    def get_user_orders(self, user_id: int) -> List[Dict]:
        return [o for o in self.orders.values() if o['user_id'] == user_id]

    def create_order(self, user_id: int, product: str) -> Dict:
        order = {'id': self.next_id, 'user_id': user_id,
                'product': product, 'status': 'processing'}
        self.orders[self.next_id] = order
        self.next_id += 1
        return order


order_service = OrderService()


# =============================================================================
# Product Service
# =============================================================================

class ProductService:
    """Microservice handling products."""

    def __init__(self):
        self.products = {
            1: {'id': 1, 'name': 'Laptop', 'price': 999.99, 'stock': 50},
            2: {'id': 2, 'name': 'Phone', 'price': 599.99, 'stock': 100},
            3: {'id': 3, 'name': 'Tablet', 'price': 399.99, 'stock': 75},
            4: {'id': 4, 'name': 'Headphones', 'price': 149.99, 'stock': 200},
        }

    def get_product(self, product_id: int) -> Optional[Dict]:
        return self.products.get(product_id)

    def get_all_products(self) -> List[Dict]:
        return list(self.products.values())

    def update_stock(self, product_id: int, quantity: int) -> bool:
        if product_id in self.products:
            self.products[product_id]['stock'] += quantity
            return True
        return False


product_service = ProductService()


# =============================================================================
# HTTP Handlers
# =============================================================================

def make_handler(service_type: str):
    """Factory to create service-specific HTTP handlers."""

    class ServiceHandler(BaseHTTPRequestHandler):
        def send_json(self, data, status=200):
            self.send_response(status)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(data).encode())

        def do_GET(self):
            parsed = urlparse(self.path)
            path = parsed.path
            query = parse_qs(parsed.query)

            if path == '/health':
                self.send_json({'status': 'healthy', 'service': service_type})
                return

            if service_type == 'user':
                if path == '/users':
                    self.send_json(user_service.get_all_users())
                elif path.startswith('/users/'):
                    try:
                        user_id = int(path.split('/')[-1])
                        user = user_service.get_user(user_id)
                        if user:
                            self.send_json(user)
                        else:
                            self.send_json({'error': 'User not found'}, 404)
                    except:
                        self.send_json({'error': 'Invalid user ID'}, 400)
                else:
                    self.send_json({'error': 'Not found'}, 404)

            elif service_type == 'order':
                if path == '/orders':
                    user_id = query.get('user_id')
                    if user_id:
                        orders = order_service.get_user_orders(int(user_id[0]))
                    else:
                        orders = list(order_service.orders.values())
                    self.send_json(orders)
                elif path.startswith('/orders/'):
                    try:
                        order_id = int(path.split('/')[-1])
                        order = order_service.get_order(order_id)
                        if order:
                            self.send_json(order)
                        else:
                            self.send_json({'error': 'Order not found'}, 404)
                    except:
                        self.send_json({'error': 'Invalid order ID'}, 400)
                else:
                    self.send_json({'error': 'Not found'}, 404)

            elif service_type == 'product':
                if path == '/products':
                    self.send_json(product_service.get_all_products())
                elif path.startswith('/products/'):
                    try:
                        product_id = int(path.split('/')[-1])
                        product = product_service.get_product(product_id)
                        if product:
                            self.send_json(product)
                        else:
                            self.send_json({'error': 'Product not found'}, 404)
                    except:
                        self.send_json({'error': 'Invalid product ID'}, 400)
                else:
                    self.send_json({'error': 'Not found'}, 404)

            elif service_type == 'gateway':
                # API Gateway aggregates data from multiple services
                if path == '/api/user-orders':
                    user_id = query.get('user_id')
                    if user_id:
                        user_id = int(user_id[0])
                        user = user_service.get_user(user_id)
                        orders = order_service.get_user_orders(user_id)
                        self.send_json({'user': user, 'orders': orders})
                    else:
                        self.send_json({'error': 'user_id required'}, 400)
                elif path == '/api/dashboard':
                    self.send_json({
                        'users_count': len(user_service.users),
                        'orders_count': len(order_service.orders),
                        'products_count': len(product_service.products),
                        'services': {
                            'user': registry.get_all('user'),
                            'order': registry.get_all('order'),
                            'product': registry.get_all('product')
                        }
                    })
                else:
                    self.send_json({'error': 'Not found'}, 404)

        def do_POST(self):
            content_length = int(self.headers.get('Content-Length', 0))
            body = json.loads(self.rfile.read(content_length).decode()) if content_length else {}

            if service_type == 'user' and self.path == '/users':
                name = body.get('name')
                email = body.get('email')
                if name and email:
                    user = user_service.create_user(name, email)
                    self.send_json(user, 201)
                else:
                    self.send_json({'error': 'name and email required'}, 400)

            elif service_type == 'order' and self.path == '/orders':
                user_id = body.get('user_id')
                product = body.get('product')
                if user_id and product:
                    order = order_service.create_order(user_id, product)
                    self.send_json(order, 201)
                else:
                    self.send_json({'error': 'user_id and product required'}, 400)

            else:
                self.send_json({'error': 'Not found'}, 404)

        def log_message(self, format, *args):
            print(f"[{service_type.upper()}] {args[0]}")

    return ServiceHandler


# =============================================================================
# Service Runner
# =============================================================================

def run_service(service_type: str, port: int):
    """Run a microservice on given port."""
    handler = make_handler(service_type)
    server = HTTPServer(('', port), handler)
    registry.register(service_type, 'localhost', port)
    print(f"[{service_type.upper()}] Running on port {port}")
    server.serve_forever()


def run_all_services():
    """Run all services in separate threads."""
    services = [
        ('user', 8001),
        ('order', 8002),
        ('product', 8003),
        ('gateway', 8000),
    ]

    threads = []
    for service_type, port in services:
        t = threading.Thread(target=run_service, args=(service_type, port), daemon=True)
        t.start()
        threads.append(t)
        time.sleep(0.1)

    print("\n" + "=" * 50)
    print("All services running!")
    print("=" * 50)
    print("\nEndpoints:")
    print("  Gateway (API):     http://localhost:8000")
    print("  User Service:      http://localhost:8001")
    print("  Order Service:     http://localhost:8002")
    print("  Product Service:   http://localhost:8003")
    print("\nTry:")
    print("  curl http://localhost:8000/api/dashboard")
    print("  curl http://localhost:8001/users")
    print("  curl http://localhost:8002/orders")
    print("  curl http://localhost:8003/products")
    print("\nPress Ctrl+C to stop")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nShutting down...")


# =============================================================================
# Main
# =============================================================================

def main():
    print("Microservices Demo")
    print("=" * 50)

    if '--help' in sys.argv:
        print("\nUsage:")
        print("  python microservices.py          - Run all services")
        print("  python microservices.py user     - Run user service only")
        print("  python microservices.py order    - Run order service only")
        print("  python microservices.py product  - Run product service only")
        print("  python microservices.py gateway  - Run API gateway only")
        print("\nServices:")
        print("  user    (8001) - User management")
        print("  order   (8002) - Order management")
        print("  product (8003) - Product catalog")
        print("  gateway (8000) - API Gateway")
        return

    if len(sys.argv) > 1:
        service = sys.argv[1]
        ports = {'user': 8001, 'order': 8002, 'product': 8003, 'gateway': 8000}
        if service in ports:
            run_service(service, ports[service])
        else:
            print(f"Unknown service: {service}")
    else:
        run_all_services()


if __name__ == "__main__":
    main()
