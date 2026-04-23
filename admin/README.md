# Project Codex Admin Dashboard

The Admin Dashboard is a Flutter-based management interface for Project Codex, used to manage book conversion, editing, and interactive widget tagging.

## Getting Started

This project uses **Supabase** for authentication and data storage. Credentials must be provided at compile-time using `--dart-define`.

### Running the App

To run the application locally, use the following command:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### Development

This project uses `riverpod_generator` for state management and `build_runner` for code generation.

To generate the necessary code, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```
