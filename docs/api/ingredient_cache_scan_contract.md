# Ingredient cache-aware scan — proposed contract (KG-21 / KG-22)

> **Status: proposed, not implemented.** Unlike `dummy_subscription_api.md`, this endpoint
> doesn't exist yet on either side. This doc exists so the backend team has a concrete spec
> to build against; mobile has no code for this until the fields below ship.

## Why

- `/api/scan_recipt` always triggers a fresh AI call — there's no cache lookup before it,
  and no response field says whether an item came from cache or a new AI call.
- `confidence` (per-item detection score) exists today only on the kitchen-setup scan
  response (`ScannedItemEntity.confidence`), not on `/api/scan_recipt`. The BRD's
  ">95% confidence → store in shared DB" rule can't be applied to receipt scans without it.
- `currency` is sent by mobile as a **request** field on `/api/scan_recipt` but never
  echoed back per item — needed to store currency alongside high-confidence cache entries
  (BRD: "User's currency stored alongside each scanned item").
- Recipe caching already surfaces a "Previously Generated" tag to the user (BRD UC-10).
  There's no equivalent signal for ingredient/receipt-item caching yet.

## Ask: extend `/api/scan_recipt` response, per item

No new endpoint — add fields to each item already in the response:

| Field | Type | Notes |
|---|---|---|
| `confidence` | number | Same shape as kitchen-setup scan's `confidence` |
| `currency` | string (ISO 4217) | Currently request-only; echo it back per item |
| `source` | `"cache"` \| `"ai"` (or bool `cache_hit`) | Lets the client show a "Matched from shared database" tag |

## Open question for backend

The kitchen-setup scan endpoint already returns `library_match` per item
(`smart_kitchen_setup_datasource.dart`, `ScannedItemEntity.libraryMatch`). Is that already
"matched from the shared ingredient cache, AI call skipped"? If yes, mirroring the same
field onto `/api/scan_recipt` covers most of this ask. If it means something else (e.g.
icon linking only), the cache-hit signal above is still missing and needs its own field.

## Mobile-side integration point once fields ship

- `lib/features/pantry/data/model/scan_receipt_item_model.dart` — parse `confidence` /
  `currency` / `source`
- `lib/features/pantry/domain/entities/scan_receipt_item.dart` — add the fields, mirroring
  the existing pattern in `lib/features/smart_kitchen_setup/domain/entities/scanned_item.dart`
- The `>95%` threshold gate and the decision to store a record stay server-side — mobile
  only displays what the backend returns, it never writes to the shared ingredient DB
  directly.
