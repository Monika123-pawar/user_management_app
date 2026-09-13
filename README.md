# user_management_app

A Flutter application that fetches and displays users from the ReqRes API with pagination, infinite scrolling, search, caching, pull-to-refresh, error handling, and user details.

## Features

- User list with profile pictures
- User details
- Search users by name
- Pagination & infinite scrolling
- Pull-to-refresh
- Error & retry handling
- Offline caching with Hive
- 30-minute cache expiry
- Responsive UI
- Cubit state management
- Dio API integration
- GetIt dependency injection
- Unit tests

## Tech Stack

- Flutter & Dart
- BLoC / Cubit
- Dio
- Hive
- GetIt
- Mocktail

## API

`https://reqres.in/api/users`

Pagination:

`?per_page=10&page=1`

## Architecture

The project follows a clean architecture approach:

```text
UI
 ↓
Cubit
 ↓
Repository
 ↓
DataSource
 ↓
Dio → API
````

## Run

```
flutter pub get
flutter run
```

## Test

```
flutter test
```

## GitHub

https://github.com/Monika123-pawar/user_management_app

