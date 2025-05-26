# 💸 SplitEase — A Bill Splitting Web App

SplitEase is a full-featured bill splitting web application designed to help groups manage shared expenses, settle dues, and track balances with ease. Built with a **Flutter web frontend**, **Go backend**, and **MongoDB** for data storage.

---

## 🌐 Live Demo
*Not added yet (Will take a day)*

---

## 🛠️ Tech Stack

| Layer       | Technology         |
|-------------|--------------------|
| Frontend    | Flutter Web        |
| Backend     | Go (Golang)        |
| Database    | MongoDB            |
| Auth        | JWT (Token-Based)  |
| State Mgmt  | Provider (Flutter) |
| Routing     | GoRouter (Flutter) |

---

## 🚀 Features

### ✅ Core Functionality
- 🔐 User Authentication (JWT based)
- 👥 Group creation and membership management
- 💰 Add, view, and delete expenses
- ✍️ Expense types: Equal, Ratio, Uneven splits
- 🧾 Notes and metadata on expenses
- 💸 Add and remove transactions between users
- 🧮 **Settle Up**: Calculate who owes whom and how much

### 🧑‍🎨 UI/UX
- 📱 Responsive and polished Flutter Web interface
- 🌙 Light/Dark theme support with persistence
- 🔄 Real-time form validation for expense creation
- 📋 Expandable expense tiles to view splits
- 🧑‍🤝‍🧑 Avatar and email display for users

---

## 📁 Project Structure

```bash
📦 split-ease/
├── frontend/              # Flutter web app
│   ├── lib/
│   │   ├── theme/         # Theming system (colors, text styles)
│   │   ├── screens/       # Pages like Home, GroupDetails, Expenses, Members
│   │   ├── widgets/       # Reusable UI components
│   │   ├── provider/      # Providers for session and theme storage and usage
│   │   ├── routers/       # GoRouter-based navigation
│   │   ├── models/        # Dart models for API data
│   │   ├── services/      # API interaction via http
│   │   └── main.dart
│
├── backend/               # Go backend
│   ├── models/            # Structs for User, Group, Expense, Transaction
│   ├── handlers/          # HTTP handler functions
│   ├── services/          # Business logic
│   ├── storage/           # DB queries (MongoDB)
│   ├── middleware/        # Auth and context
│   ├── config/            # DB connection and env handling
│   └── main.go
```

---

## 🔧 Running Locally

### 📦 Backend

```bash
cd backend/
go mod tidy
go run cmd/servers/main.go
```

Ensure you've set the env vars as in .env.example.

### 💻 Frontend

```bash
flutter pub get
flutter run -d chrome
```

---

## 📬 API Endpoints

Some example endpoints:

- `POST /login` — User authentication
- `GET /groups` — List user’s groups
- `POST /group` — Create a new group
- `GET /group/{id}` — Group details
- `POST /group/{id}/expense` — Add expense
- `GET /group/{id}/expenses` — View expenses
- `POST /group/{id}/transaction` — Add transaction
- `GET /group/{id}/settle` — Get settle up summary

---

## 🔐 Authentication

- Uses JWT tokens for stateless authentication
- Token stored in local storage on login
- Token passed via `Authorization` header for protected endpoints

---

## 🧪 Testing

- Manual testing via frontend
- Backend modularized for unit testing (optional)

---

## 💡 Future Improvements

- 🧾 Expense editing
- 📱 Mobile optimization
- 📊 Dashboard analytics
- 🔔 Notifications
- 🌍 Global currency support

---

## 👨‍💻 Author

Made with ❤️ by [Aric Maji / IITH]

---