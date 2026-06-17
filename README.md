<div align="center">

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Clean_Architecture-blueviolet?style=for-the-badge" />
<img src="https://img.shields.io/badge/Bloc%2FCubit-State_Management-orange?style=for-the-badge" />
<img src="https://img.shields.io/badge/Dio-Networking-red?style=for-the-badge" />

<br/>
<br/>

# 🧱 Kitchen's Guardian

> **A Flutter application built on Clean Architecture with Bloc/Cubit state management.**  
> Scalable · Testable · Maintainable

</div>

---

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────┐
│                 Presentation                │
│         Bloc / Cubit · Pages · Widgets      │
├─────────────────────────────────────────────┤
│                   Domain                   │
│       Entities · Use Cases · Repositories   │
├─────────────────────────────────────────────┤
│                    Data                    │
│   Remote/Local DataSource · Models · Repo   │
└─────────────────────────────────────────────┘
```

---

## 🗂️ Project Structure

```
lib/
│
├── 📁 app/
│   ├── app_base.dart            # Root widget setup
│   ├── app_router.dart          # Route definitions
│   └── di.dart                  # Dependency injection
│
├── 📁 core/
│   ├── common/                  # Shared base classes
│   ├── config/                  # App configuration
│   ├── dialogs/                 # Reusable dialogs
│   ├── error/                   # Failure & exception types
│   ├── extensions/              # Dart extensions
│   ├── global/                  # Global constants
│   ├── screens/                 # Shared screen wrappers
│   ├── services/                # App-level services
│   ├── theme/                   # Colors, typography, theme
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Shared UI components
│
└── 📁 features/
    ├── 📦 auth/
    ├── 📦 consumptions/
    ├── 📦 dashboard/
    ├── 📦 grocery/
    ├── 📦 history/
    ├── 📦 home/
    ├── 📦 kitchens/
    ├── 📦 onboarding/
    ├── 📦 pantry/
    ├── 📦 planner/
    ├── 📦 profile/
    ├── 📦 smart_kitchen_setup/
    └── 📦 subscriptions/
```

---

## 📦 Feature Module Structure

Every feature follows this identical three-layer structure:

```
feature_name/
│
├── 📁 data/                          # Implementation layer
│   ├── datasource/
│   │   ├── remote_datasource.dart    # REST API calls via Dio
│   │   └── local_datasource.dart     # Local cache / DB
│   ├── model/
│   │   └── feature_model.dart        # DTO with fromJson / toJson
│   └── repository/
│       └── feature_repository_impl.dart  # Implements domain contract
│
├── 📁 domain/                        # Business logic layer (pure Dart)
│   ├── entity/
│   │   └── feature_entity.dart       # Core business object
│   ├── repository/
│   │   └── feature_repository.dart   # Abstract contract
│   └── usecase/
│       └── get_feature_usecase.dart  # Single-responsibility use case
│
└── 📁 presentation/                  # UI layer
    ├── bloc/                         # Bloc / Cubit + States + Events
    ├── pages/                        # Full screens
    └── widgets/                      # Feature-scoped components
```

> 💡 **Example — `auth/`**
>
> | File | Responsibility |
> |------|---------------|
> | `data/datasource/remote_datasource.dart` | Calls `/auth/login` via Dio |
> | `data/model/auth_model.dart` | Parses API JSON response |
> | `data/repository/auth_repository_impl.dart` | Implements `AuthRepository` |
> | `domain/entity/auth_entity.dart` | Pure `User` business object |
> | `domain/repository/auth_repository.dart` | Abstract interface |
> | `domain/usecase/login_usecase.dart` | Orchestrates login flow |
> | `presentation/bloc/` | `AuthBloc` · `AuthState` · `AuthEvent` |
> | `presentation/pages/` | `LoginPage`, `RegisterPage` |
> | `presentation/widgets/` | `AuthFormField`, `AuthButton` |

---

## 🔧 Tech Stack

| Concern | Technology |
|---|---|
| Architecture | Clean Architecture (3-layer) |
| State Management | Bloc / Cubit |
| Networking | Dio |
| API | REST |
| DI | get_it |
| Testing | Unit Tests (domain layer) |

---

## 🧪 Testing Strategy

Tests live alongside the domain layer — the only layer with zero Flutter dependencies.

```
test/
└── features/
    └── auth/
        └── domain/
            └── usecase/
                └── login_usecase_test.dart
```

---

## 🚀 Getting Started

```bash
# Clone the repo
git clone https://github.com/your-org/food-guardian.git
# cd into the cloned repository root

# Local secrets (required): copy the template and fill in real values — .env is gitignored
cp .env.example .env

# FCM server sends (if you use FCM HTTP v1 from the app): place your service account JSON at
# assets/services/service_account.json (path overridable via FCM_SERVICE_ACCOUNT_ASSET in .env)

flutter pub get
flutter run
```

### Android release signing

1. Create a keystore under `android/`, e.g.  
   `keytool -genkey -v -keystore android/kitchenguardian.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Copy `android/key.properties.example` → `android/key.properties` and set secrets. **`storeFile` is relative to the `android/` directory** (e.g. `storeFile=kitchenguardian.jks` for `android/kitchenguardian.jks`). Keystore and `key.properties` are gitignored — do not commit them.
3. If `key.properties` is missing, release builds use the **debug** keystore for local testing only — use a real keystore for Play upload.

**Release builds** use R8 (`minifyEnabled` / `shrinkResources`). Ship with:

`flutter build apk --release` or `flutter build appbundle --release`.

---

<div align="center">

Made with ❤️ using Flutter

</div>
