# ContractGenerator (stub)

Objectif : consommer la queue grant_contracts et generer un PDF.

PDF : voir `docs/pdf_contents.md`.
ACK policy : voir `docs/consumer_ack.md`.
Generation dummy : appelle `scripts/generate_dummy_pdf.py` (python3 requis).

## Binding
- Queue: `consumer.queue` (defaut: grant_contracts)
- Exchange topic: `exchanges.grant` (defaut: GRANT_EXCHANGE)
- Routing key: `consumer.routing-key` (defaut: grant.*.contract)

## Run local (stub)
```bash
mvn spring-boot:run
```
