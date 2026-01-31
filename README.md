# Product Hub – Flutter Web Dashboard

A **Product Dashboard** web app built with Flutter Web and **BLoC/Cubit** for state management. It uses a feature-based (clean) architecture, responsive layout, and the [DummyJSON](https://dummyjson.com/products) API for product data.

## Features

- **Product list** – Responsive DataTable (desktop) or GridView (mobile) with product ID, name, category, price, and stock status
- **Search & filter** – Search by query, filter by category, “In stock only” toggle
- **Sorting** – Sort by ID, name, category, price, or stock (table column headers)
- **Add/Edit product** – Modal form with validation; state updates via Cubit
- **Product details** – Navigate to a details page; Edit button reuses the same form
- **Sidebar navigation** – Dashboard, Products, Settings
- **AppBar** – App name and search field
- **Theme switcher** – Light/Dark mode (Settings page)
- **Routing** – `go_router` for Dashboard, Products, Product details, Settings

## Architecture

```
lib/
├── core/
│   ├── theme/          # AppTheme, ThemeModeScope
│   └── router/         # go_router, ShellScaffold
├── features/product/
│   ├── data/
│   │   ├── datasources/   # ProductRemoteDataSource (DummyJSON API)
│   │   └── repositories/ # ProductRepositoryImpl
│   ├── domain/         # (repository interface in data layer)
│   ├── models/         # Product
│   └── presentation/
│       ├── blocs/      # ProductCubit, ProductDetailCubit, ProductFormCubit
│       ├── pages/      # Dashboard, ProductList, ProductDetails, Settings
│       └── widgets/    # Sidebar, AppBarWithSearch, ProductFormModal
└── main.dart
```

## Getting Started

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run on web**
   ```bash
   flutter run -d chrome
   ```
   Or build for production:
   ```bash
   flutter build web
   ```

3. **Run on other platforms**
   ```bash
   flutter run
   ```

## Tech Stack

- **State management:** `flutter_bloc` (Cubit)
- **Routing:** `go_router`
- **HTTP:** `http` for DummyJSON API
- **Models:** `equatable`
- **UI:** Material 3, responsive layout (LayoutBuilder, MediaQuery)
