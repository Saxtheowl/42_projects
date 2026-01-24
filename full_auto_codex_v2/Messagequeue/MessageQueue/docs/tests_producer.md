# Tests producer

Executer les tests unitaires du producer :
```bash
cd services/producer
mvn test
```

Les tests couvrent :
- validation champs requis (email/grantType)
- validation format grantType (routing key)
- routing key custom + trimming
- health endpoint

Ou via le script :
```bash
./scripts/test_producer.sh
```
Note: aucun PDF n'est genere par ces tests.
Note: `PDF_OUTPUT_DIR` n'est pas utilise par le producer.
