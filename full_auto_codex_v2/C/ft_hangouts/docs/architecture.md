# Architecture technique proposée

## Plateforme
- **Android** (Kotlin recommandé) avec Android Studio.
- Minimum SDK 26, orientation portrait/paysage.
- Architecture MVVM (ViewModel + LiveData/Flow).

## Modules logiques
1. **Data layer**
   - SQLite via `Room` (si non autorisé → `SQLiteOpenHelper`).
   - DAO `ContactsDao`, `MessagesDao`.
   - Entités `ContactEntity`, `MessageEntity`.
2. **Repository layer**
   - `ContactsRepository` (CRUD, recherche, tags).
   - `MessagesRepository` (envoi/réception, filtrage par contact).
3. **Domain layer**
   - Use-cases `CreateContact`, `UpdateContact`, `SendSms`, `ReceiveSmsMock`.
4. **Presentation layer**
   - `MainActivity` + fragments : `ContactListFragment`, `ContactDetailFragment`, `ConversationFragment`, `SettingsFragment`.
   - Navigation Component pour transitions.

## Persistance
- Table `contacts` : id, firstname, lastname, phone, email, campus, tags(JSON), notes, created_at, updated_at.
- Table `messages` : id, contact_id FK, direction (IN/OUT), body, timestamp.
- Option bonus : table `hangouts` (id, name, description, visibility).

## Services & background
- `MessagingService` (WorkManager) simulant réception SMS selon un fichier seed.
- Notifications channel "ft-hangouts" + actions rapides.
- Sauvegarde du timestamp `last_background` en SharedPreferences.

## Internationalisation & thème
- `strings.xml` FR/EN (fallback EN), `colors.xml` pour 3 thèmes.
- Menu paramètres -> change header color, active/désactive auto-contact.

## Prototype CLI
- `src/mock_app.py` : stockage JSON, commandes `contacts`/`messages`, support FR/EN.
- Permet de valider logique métier en attendant l’UI Android.

## Tests
- `scripts/run_tests.sh` (CLI) : scénarios CRUD + messagerie.
- À prévoir : tests unitaires Kotlin (`JUnit`) + instrumentation Espresso sur l’app Android.
- `scripts/run_demo.sh` : lance un émulateur + installe l’APK généré (`./gradlew assembleDebug`).
