# avaj_launcher - Aircraft Simulation

Air traffic simulation with weather effects in Java.

## Features

- Aircraft factory pattern
- Observer pattern (weather tower)
- Multiple aircraft types
- Weather-based behavior
- Scenario file parsing

## Building

```bash
javac Aircraft.java
```

## Usage

```bash
java Aircraft scenario.txt
```

## Scenario File Format

```
<number_of_simulations>
<type> <name> <longitude> <latitude> <height>
...
```

## Example Scenario

```
25
Helicopter H1 10 20 30
JetPlane J1 5 5 50
Baloon B1 0 0 25
Helicopter H2 100 50 75
```

## Aircraft Types

### Helicopter
- SUN: longitude +10, height +2
- RAIN: longitude +5
- FOG: longitude +1
- SNOW: height -12

### JetPlane
- SUN: latitude +10, height +2
- RAIN: latitude +5
- FOG: latitude +1
- SNOW: height -7

### Baloon
- SUN: longitude +2, height +4
- RAIN: height -5
- FOG: height -3
- SNOW: height -15

## Weather System

Weather is determined by coordinates:
```
hash = longitude + latitude + height
weather = hash % 4
```

Weather types: SUN, RAIN, FOG, SNOW

## Design Patterns

### Factory Pattern
`AircraftFactory.newAircraft(type, name, coords)`

### Observer Pattern
- WeatherTower (Observable)
- Flyable interface (Observer)
- Aircraft register/unregister from tower

## Output

Results are written to `simulation.txt`:
- Registration messages
- Weather updates per aircraft
- Unregistration on landing (height <= 0)

## Author

Implementation for 42 curriculum.
