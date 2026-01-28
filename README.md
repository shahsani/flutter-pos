# Flutter POS

A comprehensive Point of Sale (POS) application built with Flutter, designed for data isolation and robust feature management. This app supports multi-user environments (on a single device via secure login) and covers inventory, sales, customer management, and reporting.

## Key Features

*   **User Authentication**: Secure Signup and Login with password hashing (SHA-256).
*   **Data Isolation**: Complete data segregation per user. A user only sees their own customers, products, and sales.
*   **Dashboard**: Real-time overview of sales and key metrics.
*   **Inventory Management**: Create, Read, Update, and Delete (CRUD) products and categories.
*   **Sales Processing**: Efficient sales interface with cart management.
*   **Customer Management**: Mantain customer databases with purchase history.
*   **Reports**: Visual insights into sales performance using charts and detailed lists.
*   **Profile Management**: Update user details and change passwords securely.

## Tech Stack

*   **Framework**: Flutter
*   **State Management**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
*   **Navigation**: [go_router](https://pub.dev/packages/go_router)
*   **Database**: [sqflite](https://pub.dev/packages/sqflite) (Local SQLite)
*   **Local Storage**: [shared_preferences](https://pub.dev/packages/shared_preferences)
*   **Security**: [crypto](https://pub.dev/packages/crypto) (Password hashing)
*   **Utilities**: [uuid](https://pub.dev/packages/uuid), [intl](https://pub.dev/packages/intl)
*   **UI/UX**: [google_fonts](https://pub.dev/packages/google_fonts), [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter), [fl_chart](https://pub.dev/packages/fl_chart)
*   **Export**: [pdf](https://pub.dev/packages/pdf), [printing](https://pub.dev/packages/printing)

## Installation

1.  **Prerequisites**: Ensure you have Flutter installed. [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

2.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd test_pos
    ```

3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

## Usage

Run the app on your connected device or emulator:

```bash
flutter run
```

### Initial Setup
1.  Launch the app.
2.  Navigate to the **Sign Up** screen.
3.  Create a new account.
4.  Log in with your credentials to access the Dashboard.

## Project Structure

The project follows a **Feature-First** architecture with clean separation of concerns.

```text
lib/
├── core/                   # Shared components, database, router, utils
├── features/               # Feature-specific modules
│   ├── auth/               # Authentication (Login, Signup, Profile)
│   ├── customers/          # Customer management
│   ├── dashboard/          # Main dashboard UI
│   ├── inventory/          # Products and Categories
│   ├── reports/            # Sales reports and charts
│   ├── sales/              # Sales processing logic
│   ├── settings/           # App settings
│   └── splash/             # Startup splash screen
└── main.dart               # Entry point
```

Each feature folder typically contains:
*   `data/`: Repositories and data sources.
*   `domain/`: Models and repository definitions.
*   `presentation/`: Screens, widgets, and Riverpod providers.

## License

[MIT License](LICENSE)
