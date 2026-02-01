#!/usr/bin/env python3
"""
zappy - Network Multiplayer Game
Server-client game with AI players
"""

import sys
import socket as sock_module
import threading
import select
import random
import time
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, field
from enum import Enum


class Direction(Enum):
    NORTH = 0
    EAST = 1
    SOUTH = 2
    WEST = 3


class Resource(Enum):
    FOOD = "food"
    LINEMATE = "linemate"
    DERAUMERE = "deraumere"
    SIBUR = "sibur"
    MENDIANE = "mendiane"
    PHIRAS = "phiras"
    THYSTAME = "thystame"


@dataclass
class Tile:
    """A map tile."""
    resources: Dict[Resource, int] = field(default_factory=dict)
    players: List['Player'] = field(default_factory=list)

    def __post_init__(self):
        for r in Resource:
            if r not in self.resources:
                self.resources[r] = 0


@dataclass
class Player:
    """A game player."""
    id: int
    team: str
    x: int
    y: int
    direction: Direction = Direction.NORTH
    level: int = 1
    inventory: Dict[Resource, int] = field(default_factory=dict)
    alive: bool = True
    socket: Optional[Any] = None

    def __post_init__(self):
        for r in Resource:
            if r not in self.inventory:
                self.inventory[r] = 0
        self.inventory[Resource.FOOD] = 10


# Elevation requirements
ELEVATION_REQUIREMENTS = {
    2: {Resource.LINEMATE: 1, "players": 1},
    3: {Resource.LINEMATE: 1, Resource.DERAUMERE: 1, Resource.SIBUR: 1, "players": 2},
    4: {Resource.LINEMATE: 2, Resource.SIBUR: 1, Resource.PHIRAS: 2, "players": 2},
    5: {Resource.LINEMATE: 1, Resource.DERAUMERE: 1, Resource.SIBUR: 2, Resource.PHIRAS: 1, "players": 4},
    6: {Resource.LINEMATE: 1, Resource.DERAUMERE: 2, Resource.SIBUR: 1, Resource.MENDIANE: 3, "players": 4},
    7: {Resource.LINEMATE: 1, Resource.DERAUMERE: 2, Resource.SIBUR: 3, Resource.PHIRAS: 1, "players": 6},
    8: {Resource.LINEMATE: 2, Resource.DERAUMERE: 2, Resource.SIBUR: 2, Resource.MENDIANE: 2,
        Resource.PHIRAS: 2, Resource.THYSTAME: 1, "players": 6},
}


class GameWorld:
    """The game world."""

    def __init__(self, width: int, height: int):
        self.width = width
        self.height = height
        self.tiles = [[Tile() for _ in range(width)] for _ in range(height)]
        self.players: Dict[int, Player] = {}
        self.teams: Dict[str, List[int]] = {}
        self.next_player_id = 1

        # Spawn resources
        self.spawn_resources()

    def spawn_resources(self):
        """Spawn initial resources."""
        resource_density = {
            Resource.FOOD: 0.5,
            Resource.LINEMATE: 0.3,
            Resource.DERAUMERE: 0.15,
            Resource.SIBUR: 0.1,
            Resource.MENDIANE: 0.1,
            Resource.PHIRAS: 0.08,
            Resource.THYSTAME: 0.05,
        }

        for y in range(self.height):
            for x in range(self.width):
                for resource, density in resource_density.items():
                    if random.random() < density:
                        self.tiles[y][x].resources[resource] += random.randint(1, 3)

    def add_player(self, team: str, sock: Optional[sock_module.socket] = None) -> Player:
        """Add a new player."""
        player_id = self.next_player_id
        self.next_player_id += 1

        x = random.randint(0, self.width - 1)
        y = random.randint(0, self.height - 1)

        player = Player(player_id, team, x, y, socket=sock)
        self.players[player_id] = player
        self.tiles[y][x].players.append(player)

        if team not in self.teams:
            self.teams[team] = []
        self.teams[team].append(player_id)

        return player

    def remove_player(self, player_id: int):
        """Remove a player."""
        if player_id not in self.players:
            return

        player = self.players[player_id]
        self.tiles[player.y][player.x].players.remove(player)

        if player.team in self.teams:
            self.teams[player.team].remove(player_id)

        del self.players[player_id]

    def get_tile(self, x: int, y: int) -> Tile:
        """Get tile at position (wrapping)."""
        return self.tiles[y % self.height][x % self.width]

    def move_forward(self, player: Player):
        """Move player forward."""
        old_tile = self.get_tile(player.x, player.y)
        old_tile.players.remove(player)

        if player.direction == Direction.NORTH:
            player.y = (player.y - 1) % self.height
        elif player.direction == Direction.SOUTH:
            player.y = (player.y + 1) % self.height
        elif player.direction == Direction.EAST:
            player.x = (player.x + 1) % self.width
        elif player.direction == Direction.WEST:
            player.x = (player.x - 1) % self.width

        new_tile = self.get_tile(player.x, player.y)
        new_tile.players.append(player)

    def turn_right(self, player: Player):
        """Turn player right."""
        player.direction = Direction((player.direction.value + 1) % 4)

    def turn_left(self, player: Player):
        """Turn player left."""
        player.direction = Direction((player.direction.value - 1) % 4)

    def look(self, player: Player) -> str:
        """Get player's vision."""
        result = []
        level = player.level

        # Vision is a cone based on level
        for distance in range(level + 1):
            row_tiles = []
            start = -distance
            end = distance + 1

            for offset in range(start, end):
                dx, dy = self._get_offset(player.direction, distance, offset)
                tile = self.get_tile(player.x + dx, player.y + dy)
                row_tiles.append(self._describe_tile(tile))

            result.append(" ".join(row_tiles))

        return ",".join(result)

    def _get_offset(self, direction: Direction, distance: int, offset: int) -> Tuple[int, int]:
        """Get x,y offset based on direction."""
        if direction == Direction.NORTH:
            return (offset, -distance)
        elif direction == Direction.SOUTH:
            return (-offset, distance)
        elif direction == Direction.EAST:
            return (distance, offset)
        else:  # WEST
            return (-distance, -offset)

    def _describe_tile(self, tile: Tile) -> str:
        """Describe tile contents."""
        contents = []
        for player in tile.players:
            contents.append("player")
        for resource, count in tile.resources.items():
            for _ in range(count):
                contents.append(resource.value)
        return " ".join(contents) if contents else ""

    def take(self, player: Player, resource_name: str) -> bool:
        """Player takes resource."""
        try:
            resource = Resource(resource_name)
        except ValueError:
            return False

        tile = self.get_tile(player.x, player.y)
        if tile.resources[resource] > 0:
            tile.resources[resource] -= 1
            player.inventory[resource] += 1
            return True
        return False

    def put(self, player: Player, resource_name: str) -> bool:
        """Player puts down resource."""
        try:
            resource = Resource(resource_name)
        except ValueError:
            return False

        if player.inventory[resource] > 0:
            player.inventory[resource] -= 1
            tile = self.get_tile(player.x, player.y)
            tile.resources[resource] += 1
            return True
        return False

    def inventory(self, player: Player) -> str:
        """Get player inventory."""
        items = []
        for resource, count in player.inventory.items():
            items.append(f"{resource.value} {count}")
        return "{" + ", ".join(items) + "}"

    def can_elevate(self, player: Player) -> bool:
        """Check if player can elevate."""
        if player.level >= 8:
            return False

        req = ELEVATION_REQUIREMENTS[player.level + 1]
        tile = self.get_tile(player.x, player.y)

        # Check resources on tile
        for resource, count in req.items():
            if resource == "players":
                continue
            if tile.resources[resource] < count:
                return False

        # Check player count
        same_level = [p for p in tile.players if p.level == player.level]
        if len(same_level) < req["players"]:
            return False

        return True

    def elevate(self, player: Player) -> bool:
        """Perform elevation."""
        if not self.can_elevate(player):
            return False

        req = ELEVATION_REQUIREMENTS[player.level + 1]
        tile = self.get_tile(player.x, player.y)

        # Consume resources
        for resource, count in req.items():
            if resource != "players":
                tile.resources[resource] -= count

        # Level up all players
        for p in tile.players:
            if p.level == player.level:
                p.level += 1

        return True


class ZappyServer:
    """Game server."""

    def __init__(self, port: int, width: int, height: int, teams: List[str]):
        self.port = port
        self.world = GameWorld(width, height)
        self.teams = teams
        self.running = False
        self.clients: Dict[sock_module.socket, Player] = {}

    def start(self):
        """Start the server."""
        self.server = sock_module.socket(sock_module.AF_INET, sock_module.SOCK_STREAM)
        self.server.setsockopt(sock_module.SOL_SOCKET, sock_module.SO_REUSEADDR, 1)
        self.server.bind(('', self.port))
        self.server.listen(10)
        self.server.setblocking(False)

        self.running = True
        print(f"Zappy server started on port {self.port}")
        print(f"Map: {self.world.width}x{self.world.height}")
        print(f"Teams: {', '.join(self.teams)}")

    def run(self):
        """Main server loop."""
        self.start()

        while self.running:
            readable = [self.server] + list(self.clients.keys())
            try:
                ready, _, _ = select.select(readable, [], [], 0.1)
            except (select.error, ValueError):
                break

            for sock in ready:
                if sock == self.server:
                    self.accept_client()
                else:
                    self.handle_client(sock)

            # Update game (food consumption, etc.)
            self.update_game()

    def accept_client(self):
        """Accept new client."""
        try:
            client, addr = self.server.accept()
            client.setblocking(False)
            print(f"New connection from {addr}")
            client.send(b"WELCOME\n")
        except Exception as e:
            print(f"Accept error: {e}")

    def handle_client(self, sock: sock_module.socket):
        """Handle client message."""
        try:
            data = sock.recv(1024)
            if not data:
                self.disconnect_client(sock)
                return

            message = data.decode().strip()
            self.process_command(sock, message)

        except Exception as e:
            self.disconnect_client(sock)

    def process_command(self, sock: sock_module.socket, command: str):
        """Process client command."""
        if sock not in self.clients:
            # Team selection
            if command in self.teams:
                player = self.world.add_player(command, sock)
                self.clients[sock] = player
                sock.send(f"{len(self.world.teams[command])}\n".encode())
                sock.send(f"{self.world.width} {self.world.height}\n".encode())
            else:
                sock.send(b"Unknown team\n")
            return

        player = self.clients[sock]
        response = self.execute_command(player, command)
        sock.send(f"{response}\n".encode())

    def execute_command(self, player: Player, command: str) -> str:
        """Execute game command."""
        parts = command.split()
        cmd = parts[0].lower() if parts else ""

        if cmd == "forward":
            self.world.move_forward(player)
            return "ok"
        elif cmd == "right":
            self.world.turn_right(player)
            return "ok"
        elif cmd == "left":
            self.world.turn_left(player)
            return "ok"
        elif cmd == "look":
            return "[" + self.world.look(player) + "]"
        elif cmd == "inventory":
            return self.world.inventory(player)
        elif cmd == "take" and len(parts) > 1:
            return "ok" if self.world.take(player, parts[1]) else "ko"
        elif cmd == "set" and len(parts) > 1:
            return "ok" if self.world.put(player, parts[1]) else "ko"
        elif cmd == "incantation":
            return "elevation underway" if self.world.can_elevate(player) else "ko"
        elif cmd == "broadcast":
            return "ok"
        elif cmd == "connect_nbr":
            return str(len(self.world.teams.get(player.team, [])))
        elif cmd == "fork":
            return "ok"
        elif cmd == "eject":
            return "ok"
        else:
            return "ko"

    def disconnect_client(self, sock: sock_module.socket):
        """Disconnect client."""
        if sock in self.clients:
            player = self.clients[sock]
            self.world.remove_player(player.id)
            del self.clients[sock]
        try:
            sock.close()
        except:
            pass

    def update_game(self):
        """Update game state."""
        # Food consumption, etc.
        pass

    def stop(self):
        """Stop server."""
        self.running = False
        for sock in list(self.clients.keys()):
            self.disconnect_client(sock)
        self.server.close()


def run_demo():
    """Run demo simulation."""
    print("Zappy - Network Multiplayer Game Demo")
    print("=" * 50)

    world = GameWorld(20, 20)

    # Add some players
    p1 = world.add_player("team1")
    p2 = world.add_player("team2")

    print(f"Player 1: Team {p1.team}, Position ({p1.x}, {p1.y})")
    print(f"Player 2: Team {p2.team}, Position ({p2.x}, {p2.y})")

    # Simulate some actions
    print("\nPlayer 1 actions:")
    print(f"  Look: {world.look(p1)}")
    print(f"  Inventory: {world.inventory(p1)}")

    world.move_forward(p1)
    print(f"  Move forward: Now at ({p1.x}, {p1.y})")

    world.turn_right(p1)
    print(f"  Turn right: Facing {p1.direction.name}")

    # Try to take something
    tile = world.get_tile(p1.x, p1.y)
    for res, count in tile.resources.items():
        if count > 0:
            world.take(p1, res.value)
            print(f"  Took: {res.value}")
            break

    print(f"  Inventory: {world.inventory(p1)}")

    print("\n" + "=" * 50)
    print("To run server: python zappy.py server 4242 10 10 team1 team2")


def main():
    if len(sys.argv) < 2:
        print("Zappy - Network Multiplayer Game")
        print()
        print("Usage:")
        print("  python zappy.py demo")
        print("  python zappy.py server <port> <width> <height> <team1> [team2...]")
        print()
        print("Commands (for clients):")
        print("  forward   - Move forward")
        print("  right     - Turn right")
        print("  left      - Turn left")
        print("  look      - See surroundings")
        print("  inventory - Check inventory")
        print("  take <obj> - Take object")
        print("  set <obj>  - Put object")
        print("  incantation - Level up")
        return

    if sys.argv[1] == "demo":
        run_demo()
    elif sys.argv[1] == "server":
        if len(sys.argv) < 6:
            print("Usage: python zappy.py server <port> <width> <height> <team1> [team2...]")
            return
        port = int(sys.argv[2])
        width = int(sys.argv[3])
        height = int(sys.argv[4])
        teams = sys.argv[5:]

        server = ZappyServer(port, width, height, teams)
        try:
            server.run()
        except KeyboardInterrupt:
            server.stop()


if __name__ == "__main__":
    main()
