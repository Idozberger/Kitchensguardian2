# Dummy subscription API (backend billing)

Use this when the mobile app has `SUBSCRIPTION_BILLING_MODE=backend` (default). Premium is driven by **`entitlement_is_active`** on `GET /api/get_user_profile` after subscribe or restore.

**Auth:** `Authorization: Bearer <access_token>` on all endpoints below.

Replace `https://your-api.example.com` with your `API_BASE_URL`.

---

## 1. List plans

### `GET /api/subscription/plans`

**cURL**

```bash
curl -sS -X GET "https://your-api.example.com/api/subscription/plans" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Accept: application/json"
```

**Response `200`**

```json
{
  "plans": [
    {
      "plan_id": "monthly",
      "title": "Monthly",
      "price_display": "$4.99/mo",
      "price_amount": 4.99,
      "currency": "USD",
      "billing_period": "monthly"
    },
    {
      "plan_id": "annual",
      "title": "Annual",
      "price_display": "$39.99/yr",
      "price_amount": 39.99,
      "currency": "USD",
      "billing_period": "annual"
    }
  ]
}
```

| Field | Type | Required | Notes |
|-------|------|----------|--------|
| `plans` | array | Yes | At least one plan |
| `plan_id` | string | Yes | Sent back on subscribe (`monthly`, `annual`, etc.) |
| `title` | string | Yes | Shown on plan card |
| `price_display` | string | Yes | Localized label, e.g. `$4.99/mo` |
| `price_amount` | number | Yes | Used for annual “Save X%” badge |
| `currency` | string | No | Default `USD` |
| `billing_period` | string | Yes | `monthly` or `annual` / `yearly` |

**Error `4xx/5xx`**

```json
{
  "error": "Human-readable error",
  "message": "Optional alternate message"
}
```

---

## 2. Activate subscription (dummy purchase)

### `POST /api/subscription/subscribe`

**cURL**

```bash
curl -sS -X POST "https://your-api.example.com/api/subscription/subscribe" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"plan_id":"monthly"}'
```

Use `"plan_id":"annual"` for the yearly plan.

**Request body**

```json
{
  "plan_id": "monthly"
}
```

**Response `200`**

```json
{
  "message": "Subscription activated.",
  "entitlement_is_active": true,
  "plan_id": "monthly",
  "expires_at": "2026-06-28T12:00:00Z"
}
```

| Field | Type | Required | Notes |
|-------|------|----------|--------|
| `message` | string | No | Shown in app toast |
| `entitlement_is_active` | bool | Yes | Must be `true` for premium unlock |
| `plan_id` | string | No | Echo of purchased plan |
| `expires_at` | string | No | ISO-8601; informational for dummy billing |

After success, the app invalidates profile cache and calls **`GET /api/get_user_profile`**; that response should include `"entitlement_is_active": true`.

---

## 3. Restore subscription

### `POST /api/subscription/restore`

Re-applies the user’s server-side entitlement (no store receipt).

**cURL**

```bash
curl -sS -X POST "https://your-api.example.com/api/subscription/restore" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Accept: application/json"
```

**Response `200` (active subscription)**

```json
{
  "message": "Subscription restored.",
  "entitlement_is_active": true,
  "plan_id": "annual"
}
```

**Response `200` (no subscription)** — app shows a warning toast

```json
{
  "message": "No active subscription found.",
  "entitlement_is_active": false
}
```

---

## 4. Profile (premium flag)

### `GET /api/get_user_profile`

Must return `entitlement_is_active` so premium gating works after subscribe/restore and on app launch.

**cURL**

```bash
curl -sS -X GET "https://your-api.example.com/api/get_user_profile" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Accept: application/json"
```

**Response `200` (excerpt)**

```json
{
  "first_name": "Jane",
  "last_name": "Doe",
  "email": "jane@example.com",
  "user_id": "usr_123",
  "verified": true,
  "created_at": "2025-01-01T00:00:00Z",
  "avatar": "",
  "entitlement_is_active": true
}
```

---

## Mobile `.env`

```env
BILLING_UI_ENABLED=true
SUBSCRIPTION_BILLING_MODE=backend
API_BASE_URL=https://your-api.example.com
```

To switch back to App Store / Play later:

```env
SUBSCRIPTION_BILLING_MODE=iap
IAP_PREMIUM_PRODUCT_IDS=com.your.app.premium.monthly,com.your.app.premium.yearly
```

---

## Suggested backend behavior (dummy)

1. **`GET /plans`** — return static JSON (values above); no payment processor.
2. **`POST /subscribe`** — set user row `entitlement_is_active = true`, store `plan_id` and optional `expires_at`.
3. **`POST /restore`** — read user row; return current entitlement.
4. **`GET /get_user_profile`** — include `entitlement_is_active` from the same user row.

No Apple/Google verification is required for this mode.
