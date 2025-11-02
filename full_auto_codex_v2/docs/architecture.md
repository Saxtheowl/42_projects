# Architecture technique

## Choix plateforme
- **Android (Kotlin)** avec Android Studio.
- Minimum SDK : 26 (Android 8.0) pour compatibilité moderne.
- Architecture : **MVVM** avec `ViewModel`, `LiveData` (ou Flow) pour découplage UI / logique.

## Modules
1. **Data**
   - `ContactsDao`, `MessagesDao` via `Room` (ou SQLiteOpenHelper si Room considéré bibliothèque externe non autorisée → fallback manuel).
   - Entités `ContactEntity`, `MessageEntity`.
2. **Repository**
   - `ContactsRepository` (CRUD + flux), `MessagesRepository` (envoi/réception simulée).
3. **Domain**
   - Use cases : `CreateContact`, `SendMessageToContact`, `FetchHangouts`.
4. **Presentation**
   - Activities/Fragments : `MainActivity`, `ContactListFragment`, `ContactDetailFragment`, `ConversationFragment`, `SettingsFragment`.
   - Support multi-langue via `strings.xml` (fr/en).
5. **Services**
   - `MessagingService` (simulateur de SMS entrants via `WorkManager`).
   - Notification Channel pour push.

## Persistence
- Base SQLite :
  - Table `contacts(id INTEGER PK, first_name, last_name, phone, email, role, tags JSON, created_at, updated_at)`
  - Table `messages(id INTEGER PK, contact_id FK, direction TEXT CHECK('IN'/'OUT'), body TEXT, sent_at TIMESTAMP)`
- Migrations : simple versioning (1 → 2 si ajout colonnes).

## API / Connectivité
- Phase initiale : mock local (data seeding JSON).
- Extension : intégration API 42 (OAuth) + backend Node/Express pour relais (facultatif).

## UI/UX
- **Screens** :
  1. Home (liste hangouts + contacts récents + action FAB).
  2. Contact detail (onglets Info / Messages).
  3. Conversation (RecyclerView, bulles messages, champ saisie).
  4. Settings (langue, thème, header color).
- Support orientation portrait/paysage via `ConstraintLayout` et `layout-land` spécifiques.

## Tests
- Unit tests Kotlin (`JUnit`) sur repositories.
- Instrumented tests Espresso sur flows principaux.
- Script `scripts/run_demo.sh` pour lancer un émulateur avec jeu de données.

## Sécurité & confidentialité
- Stockage local chiffré optionnel (EncryptedSharedPreferences).
- Permissions : `READ/RECEIVE_SMS`, `SEND_SMS` (ou simulation si sandbox sans SIM).
- Politique RGPD : informer de la conservation des données.
