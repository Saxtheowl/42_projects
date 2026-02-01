# ft_hangouts - Contact Manager

Mobile contact management application.

## Note

This project is designed for Android/iOS development and requires:
- Android Studio or Xcode
- Mobile development SDKs

## Features

- Contact list display
- Add/Edit/Delete contacts
- Contact details view
- SMS messaging
- Call integration
- App theming
- Last access display

## Required Fields

- First Name
- Last Name
- Phone Number
- Email (optional)
- Photo (optional)
- Address (optional)
- Birthday (optional)

## Functionality

### Contact List
- Display all contacts
- Alphabetical sorting
- Search/filter
- Swipe to delete

### Contact Details
- View all information
- Call button
- SMS button
- Edit button

### Add/Edit
- Form validation
- Photo picker
- Date picker for birthday
- Save/Cancel

### Messaging
- Send SMS from app
- Message history (optional)

### Theming
- Header color customization
- Dark mode support

### Background Notice
- Show popup on return
- Display time since last use

## Data Storage

SQLite database:
```sql
CREATE TABLE contacts (
    id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    photo BLOB,
    address TEXT,
    birthday DATE
);
```

## Permissions

Android:
- READ_CONTACTS
- WRITE_CONTACTS
- SEND_SMS
- CALL_PHONE

iOS:
- Contacts
- Phone
- Messages

## Architecture

- MVVM pattern
- Repository layer
- ViewModel for state
- LiveData/Observable

## UI Components

- RecyclerView/TableView
- Toolbar
- FloatingActionButton
- Material Design/Cupertino

## Author

Implementation guide for 42 curriculum (mobile track).
