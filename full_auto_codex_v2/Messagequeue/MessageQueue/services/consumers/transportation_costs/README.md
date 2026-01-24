# TransportationCostsApplicationGenerator (stub)

Objectif : consommer la queue transportation_costs_application et generer un PDF.

PDF : voir `docs/pdf_contents.md`.
ACK policy : voir `docs/consumer_ack.md`.
Generation dummy : appelle `scripts/generate_dummy_pdf.py` (python3 requis).

## Binding
- Queue: `consumer.queue` (defaut: transportation_costs_application)
- Exchange fanout: `exchanges.social` (defaut: SOCIAL_ASSISTANCE_EXCHANGE)

## Run local (stub)
```bash
mvn spring-boot:run
```
