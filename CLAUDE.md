# CLAUDE.md

> Контекст проєкту для Claude Code. Тримай цей файл **коротким і актуальним** — він
> завантажується у кожну сесію та з'їдає контекст. Видаляй усе, що не використовується.

---

## 🤖 Спілкування

- **Кожну відповідь починай з рядка: `Остап, привіт`**
- **Кожен кінець відповіді закінчуй з рядка: `Остап, папа`**
- Відповідай українською; технічні терміни, команди й код — англійською.
- Коротко й по суті, без "води". Спершу рішення — потім пояснення (якщо потрібне).
- Якщо запит неоднозначний або вимагає нового пакета/архітектурного рішення — спитай, перш ніж робити.

---

## 📚 Документація (тримати в контексті)

Перед роботою над фічею звіряйся з `.md`-файлами в `docs/` — це джерело істини щодо
скоупу, вимог і бізнес-логіки. Не суперечити їм; якщо код розходиться з докою — сигналізуй.

- `docs/Kitchen'sGuardian — Priority Based Scope of Work (Pre- Early Launch).md` — пріоритезований scope of work.
- `docs/Kitchen\`sGuard brd draft.md` — BRD (бізнес-вимоги).
- `docs/api/dummy_subscription_api.md` — контракт API підписки.

> Якщо в `docs/` з'явився новий `.md` — врахуй його теж.

---

## Огляд проєкту

**Kitchens Guardian** (`foodkitchen`) — мобільний застосунок для розумного ведення кухні:
облік запасів (pantry), список покупок (grocery), планувальник, історія споживання,
рецепти й дашборд. Онбординг, авторизація (Google / Apple), преміум-підписка та реклама.

- **Платформи:** iOS, Android
- **Мін. версії:** iOS 15.5+, Android API 24+ (Android 7.0)

---

## Стек

| Область            | Вибір                                                        |
| ------------------ | ------------------------------------------------------------ |
| Flutter            | 3.44.x (встановлено через Homebrew, **не fvm**)              |
| Dart               | 3.8+ (`sdk: ^3.8.1`)                                         |
| State management   | **flutter_bloc** (Bloc + Cubit)                              |
| Навігація          | **go_router** (`lib/app/app_router*.dart`)                   |
| Мережа             | **dio** (`lib/core/network/`)                                |
| Функц. помилки     | **fpdart** (`Either<Failure, T>`) + `equatable`              |
| Серіалізація       | **вручну** (`fromJson`/`toJson`) — кодогену НЕМАЄ            |
| DI                 | **get_it** (`lib/app/di*.dart`, глобальний `sl`)            |
| Локальне сховище   | shared_preferences                                           |
| Конфіг / секрети   | flutter_dotenv (`.env`) + `lib/firebase_options.dart`        |
| Логування          | власний `AppLogger` (`lib/core/logging/`)                    |
| Backend            | Firebase (Auth, Firestore, Messaging, Crashlytics) + власний REST API |
| Auth               | firebase_auth + google_sign_in + sign_in_with_apple          |
| Реклама / білінг   | google_mobile_ads + власний backend-білінг                   |
| Локалізація        | `flutter gen-l10n` (ARB у `lib/l10n/`)                        |

> ⚠️ Не додавай нові залежності без узгодження. Спершу перевіряй, чи задачу можна
> вирішити наявними пакетами або Flutter SDK. **Кодогену (freezed/json_serializable/
> build_runner) у проєкті немає** — не додавай його без узгодження.

---

## Команди

```bash
# Залежності
flutter pub get

# Запуск (єдиний entrypoint lib/main.dart, flavor-ів немає)
flutter run                        # на під'єднаному пристрої/симуляторі
flutter run -d <device-id>         # список: flutter devices

# Локалізація (генерує lib/l10n/app_localizations.dart)
flutter gen-l10n

# ЯКІСТЬ КОДУ — обов'язково перед комітом, має проходити без помилок
flutter analyze
dart format .

# Релізні збірки
flutter build apk --release
flutter build ipa --release
```

> ℹ️ Іконки застосунку: `dart run flutter_launcher_icons`.

---

## Архітектура

**Feature-first + шари** (Clean Architecture lite):

```
lib/
  main.dart                  # єдиний entrypoint
  firebase_options.dart      # читає ключі з .env через lib/core/config/env.dart
  app/                       # AppBase, go_router, DI bootstrap (di*.dart)
  core/                      # спільне: network, error, config, theme, ads,
                             # billing, logging, navigation, services, widgets…
  features/
    <feature>/               # auth, pantry, grocery, planner, history, home,
      data/                  #   dashboard, profile, kitchens, onboarding,
      domain/                #   consumptions, subscription, smart_kitchen_setup
      presentation/
  l10n/                      # ARB + згенерований app_localizations.dart
```

**Правила потоку залежностей:** `presentation → domain ← data`.
`domain` не залежить від Flutter і зовнішніх пакетів. UI не звертається до `data` напряму.
Помилки прокидаються як `Either<Failure, T>` (fpdart), не через винятки в presentation.

---

## Конвенції коду

- **Іменування:** `PascalCase` — класи/типи; `camelCase` — методи/змінні; `snake_case` — файли.
- **`const` скрізь**, де можливо (constructors, widgets). Слідкуй за `prefer_const_*`.
- **Моделі** — незмінні, рівність через `equatable`. Серіалізація пишеться вручну.
- **Без бізнес-логіки у віджетах** — виноси в Bloc/Cubit/use case.
- Один екран = один файл. Великі `build()` розбивай на менші віджети (не на методи `_buildX`).
- Строга null-safety; уникай `!` — використовуй `?.`, `late` свідомо, guard-и.
- Ніяких `print()` — тільки `AppLogger`. **Ніяких хардкод-секретів/URL** — через `.env` (`Env`).
- Асинхронні операції завжди з обробкою помилок і станами loading/error/data.

**Лінтер:** `analysis_options.yaml` на базі `flutter_lints` зі строгими правилами
(`strict-casts`, `strict-inference`; unused-код і `dead_code` = **error**).
Попередження від `flutter analyze` = блокер, не ігнорувати.

---

## Конфіг і секрети (важливо)

- Значення читаються з `.env` (bundled asset) через `lib/core/config/env.dart` (`Env`).
  `Env.get(...)` **кидає виняток**, якщо ключ відсутній → застосунок не стартує.
- `lib/core/config/app_env.dart` (`AppEnv`) дублює ті самі ключі з fallback-значеннями.
- `.env` у `.gitignore` — тримай його локально; значення звіряй з `ios/Runner/GoogleService-Info.plist`.
- Зміна `.env` вимагає **повного перезапуску** (`flutter run`), не hot reload — це asset.

---

## Git

- Гілки: `feature/…`, `fix/…`, `chore/…`.
- Коміти: **Conventional Commits** (`feat:`, `fix:`, `refactor:`, `chore:`, `test:`).
- Перед пушем: `flutter analyze` + `dart format .` мають проходити.

---

## Чого НЕ робити

- ❌ Не додавати пакети / кодоген без узгодження.
- ❌ Не залишати `print()`, закоментований код, `TODO` без контексту.
- ❌ Не тягнути бізнес-логіку у віджети.
- ❌ Не хардкодити ключі/URL — тільки через `.env` / `Env`.
- ❌ Не пушити з червоним `flutter analyze`.
- ❌ Не редагувати згенеровані файли вручну (`app_localizations.dart` → `flutter gen-l10n`).
