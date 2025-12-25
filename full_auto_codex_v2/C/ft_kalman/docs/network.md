# Boucle réseau (préparation)

- Le sujet impose un dialogue UDP avec `imu-sensor-stream` (ex: `./imu-sensor-stream -s 42 -d 42 -p 4242`). Binaire absent sur l'environnement actuel => protocole exact à confirmer dès que disponible via `-h`.
- Wrapper fourni : `include/udp.hpp` / `src/udp.cpp` (RAII, bind local, timeout réception, `sendTo/recvFrom`).
- Mode démo `./kalman_demo --udp <port> <count>` :
  - Bind sur `<port>`, attend des paquets texte `dt ax ay az mx my mz` (accélération + mesure position).
  - À chaque paquet : `predict(dt, accel)` puis `update(measurement)` et renvoie l'état en JSON `{"step":n,"pos":[...],"vel":[...]}`.
  - Permet de tester la boucle réseau localement sans `imu-sensor-stream`.
- Script associé : `scripts/mock_stream.py <port> [count]` envoie des mesures synthétiques et affiche les réponses.
- TODO dès que le flux réel est disponible : journaliser les paquets bruts, documenter le format, ajouter parseur/serializer adapté au protocole officiel (handshake, cadence), tests de roundtrip.

## Outil client brut
- Binaire `kalman_client` (Makefile `make client`) : envoie un payload de handshake et affiche les paquets reçus (timeout 1s).
- Usage : `./kalman_client 127.0.0.1 4242 "HELLO" 3` (host, port, handshake, nombre max de paquets à lire).
- Objectif : sniffer et logguer les premiers paquets de `imu-sensor-stream` pour déduire le protocole et itérer sans coder à l'aveugle.
