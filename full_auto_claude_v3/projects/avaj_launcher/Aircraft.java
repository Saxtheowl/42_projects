// avaj_launcher - Aircraft Simulation (Java)
// Air traffic simulation with weather effects

import java.io.*;
import java.util.*;

// Coordinates class
class Coordinates {
    private int longitude;
    private int latitude;
    private int height;

    public Coordinates(int longitude, int latitude, int height) {
        this.longitude = longitude;
        this.latitude = latitude;
        this.height = Math.max(0, Math.min(100, height));
    }

    public int getLongitude() { return longitude; }
    public int getLatitude() { return latitude; }
    public int getHeight() { return height; }

    public void setLongitude(int l) { longitude = l; }
    public void setLatitude(int l) { latitude = l; }
    public void setHeight(int h) { height = Math.max(0, Math.min(100, h)); }

    @Override
    public String toString() {
        return "(" + longitude + ", " + latitude + ", " + height + ")";
    }
}

// Weather types
enum Weather {
    SUN, RAIN, FOG, SNOW
}

// Weather Tower - Observable
class WeatherTower {
    private List<Flyable> observers = new ArrayList<>();
    private static String[] weatherTypes = {"SUN", "RAIN", "FOG", "SNOW"};

    public void register(Flyable flyable) {
        observers.add(flyable);
        System.out.println("Tower says: " + flyable.getClass().getSimpleName() +
                          "#" + flyable.getName() + " registered to weather tower.");
    }

    public void unregister(Flyable flyable) {
        observers.remove(flyable);
        System.out.println(flyable.getClass().getSimpleName() + "#" +
                          flyable.getName() + " unregistered from weather tower.");
    }

    public String getWeather(Coordinates coordinates) {
        int hash = coordinates.getLongitude() + coordinates.getLatitude() + coordinates.getHeight();
        return weatherTypes[Math.abs(hash) % 4];
    }

    public void changeWeather() {
        List<Flyable> toRemove = new ArrayList<>();
        for (Flyable f : new ArrayList<>(observers)) {
            f.updateConditions();
            if (f.getCoordinates().getHeight() <= 0) {
                toRemove.add(f);
            }
        }
        for (Flyable f : toRemove) {
            unregister(f);
        }
    }
}

// Flyable interface
interface Flyable {
    void updateConditions();
    void registerTower(WeatherTower tower);
    String getName();
    Coordinates getCoordinates();
}

// Abstract Aircraft class
abstract class Aircraft {
    protected long id;
    protected String name;
    protected Coordinates coordinates;
    private static long idCounter = 0;

    protected Aircraft(String name, Coordinates coordinates) {
        this.id = nextId();
        this.name = name;
        this.coordinates = coordinates;
    }

    private long nextId() {
        return ++idCounter;
    }
}

// Helicopter
class Helicopter extends Aircraft implements Flyable {
    private WeatherTower weatherTower;

    public Helicopter(String name, Coordinates coordinates) {
        super(name, coordinates);
    }

    @Override
    public void updateConditions() {
        String weather = weatherTower.getWeather(coordinates);
        String message = "Helicopter#" + name + "(" + coordinates + "): ";

        switch (weather) {
            case "SUN":
                coordinates.setLongitude(coordinates.getLongitude() + 10);
                coordinates.setHeight(coordinates.getHeight() + 2);
                message += "This is hot!";
                break;
            case "RAIN":
                coordinates.setLongitude(coordinates.getLongitude() + 5);
                message += "It's raining. Better watch out for lightnings.";
                break;
            case "FOG":
                coordinates.setLongitude(coordinates.getLongitude() + 1);
                message += "Visibility is very low.";
                break;
            case "SNOW":
                coordinates.setHeight(coordinates.getHeight() - 12);
                message += "My rotor is going to freeze!";
                break;
        }
        System.out.println(message);
    }

    @Override
    public void registerTower(WeatherTower tower) {
        this.weatherTower = tower;
        tower.register(this);
    }

    @Override
    public String getName() { return name; }

    @Override
    public Coordinates getCoordinates() { return coordinates; }
}

// JetPlane
class JetPlane extends Aircraft implements Flyable {
    private WeatherTower weatherTower;

    public JetPlane(String name, Coordinates coordinates) {
        super(name, coordinates);
    }

    @Override
    public void updateConditions() {
        String weather = weatherTower.getWeather(coordinates);
        String message = "JetPlane#" + name + "(" + coordinates + "): ";

        switch (weather) {
            case "SUN":
                coordinates.setLatitude(coordinates.getLatitude() + 10);
                coordinates.setHeight(coordinates.getHeight() + 2);
                message += "Let's enjoy the good weather!";
                break;
            case "RAIN":
                coordinates.setLatitude(coordinates.getLatitude() + 5);
                message += "It's raining. Better watch out for lightnings.";
                break;
            case "FOG":
                coordinates.setLatitude(coordinates.getLatitude() + 1);
                message += "I can't see anything!";
                break;
            case "SNOW":
                coordinates.setHeight(coordinates.getHeight() - 7);
                message += "It's snowing. We're gonna crash.";
                break;
        }
        System.out.println(message);
    }

    @Override
    public void registerTower(WeatherTower tower) {
        this.weatherTower = tower;
        tower.register(this);
    }

    @Override
    public String getName() { return name; }

    @Override
    public Coordinates getCoordinates() { return coordinates; }
}

// Baloon
class Baloon extends Aircraft implements Flyable {
    private WeatherTower weatherTower;

    public Baloon(String name, Coordinates coordinates) {
        super(name, coordinates);
    }

    @Override
    public void updateConditions() {
        String weather = weatherTower.getWeather(coordinates);
        String message = "Baloon#" + name + "(" + coordinates + "): ";

        switch (weather) {
            case "SUN":
                coordinates.setLongitude(coordinates.getLongitude() + 2);
                coordinates.setHeight(coordinates.getHeight() + 4);
                message += "Let's enjoy the sun!";
                break;
            case "RAIN":
                coordinates.setHeight(coordinates.getHeight() - 5);
                message += "Damn you rain! You're messing up my baloon.";
                break;
            case "FOG":
                coordinates.setHeight(coordinates.getHeight() - 3);
                message += "I can't see where I'm going.";
                break;
            case "SNOW":
                coordinates.setHeight(coordinates.getHeight() - 15);
                message += "It's snowing. We're gonna crash.";
                break;
        }
        System.out.println(message);
    }

    @Override
    public void registerTower(WeatherTower tower) {
        this.weatherTower = tower;
        tower.register(this);
    }

    @Override
    public String getName() { return name; }

    @Override
    public Coordinates getCoordinates() { return coordinates; }
}

// Aircraft Factory
class AircraftFactory {
    public static Flyable newAircraft(String type, String name, int longitude, int latitude, int height) {
        Coordinates coords = new Coordinates(longitude, latitude, height);

        switch (type.toLowerCase()) {
            case "helicopter":
                return new Helicopter(name, coords);
            case "jetplane":
                return new JetPlane(name, coords);
            case "baloon":
                return new Baloon(name, coords);
            default:
                throw new IllegalArgumentException("Unknown aircraft type: " + type);
        }
    }
}

// Main Simulator class
public class Aircraft {
    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("avaj_launcher - Aircraft Simulation");
            System.out.println();
            System.out.println("Usage: java Aircraft <scenario.txt>");
            System.out.println();
            System.out.println("Scenario file format:");
            System.out.println("  <number_of_simulations>");
            System.out.println("  <type> <name> <longitude> <latitude> <height>");
            System.out.println("  ...");
            System.out.println();
            System.out.println("Types: Helicopter, JetPlane, Baloon");
            System.out.println();
            System.out.println("Example:");
            System.out.println("  25");
            System.out.println("  Helicopter H1 10 20 30");
            System.out.println("  JetPlane J1 5 5 50");
            return;
        }

        try {
            BufferedReader reader = new BufferedReader(new FileReader(args[0]));
            PrintStream output = new PrintStream("simulation.txt");
            PrintStream original = System.out;
            System.setOut(output);

            // Read number of simulations
            String line = reader.readLine();
            if (line == null) {
                throw new IllegalArgumentException("Empty file");
            }
            int simulations = Integer.parseInt(line.trim());
            if (simulations <= 0) {
                throw new IllegalArgumentException("Invalid number of simulations");
            }

            // Create weather tower
            WeatherTower tower = new WeatherTower();
            List<Flyable> aircrafts = new ArrayList<>();

            // Read aircraft definitions
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;

                String[] parts = line.split("\\s+");
                if (parts.length != 5) {
                    throw new IllegalArgumentException("Invalid aircraft line: " + line);
                }

                String type = parts[0];
                String name = parts[1];
                int longitude = Integer.parseInt(parts[2]);
                int latitude = Integer.parseInt(parts[3]);
                int height = Integer.parseInt(parts[4]);

                Flyable aircraft = AircraftFactory.newAircraft(type, name, longitude, latitude, height);
                aircraft.registerTower(tower);
                aircrafts.add(aircraft);
            }

            reader.close();

            // Run simulation
            for (int i = 0; i < simulations; i++) {
                tower.changeWeather();
            }

            System.setOut(original);
            System.out.println("Simulation complete. Output written to simulation.txt");

        } catch (FileNotFoundException e) {
            System.err.println("File not found: " + args[0]);
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
        } catch (NumberFormatException e) {
            System.err.println("Invalid number format: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
