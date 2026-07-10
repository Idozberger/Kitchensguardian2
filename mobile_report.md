# Unit Selector (Metric / Imperial) — Mobile Delivery Summary

The app now lets each kitchen work in the measurement system its users actually think in. A kitchen in Europe sees grams and litres; a kitchen in the US sees ounces, pounds and cups. The choice belongs to the kitchen, not to the person — so everyone sharing a kitchen sees the same numbers.

All quantities are stored once, in a single canonical form, and presented in whichever system the kitchen prefers. Nothing is duplicated, and switching the preference never rewrites or risks the underlying data.

---

## KG-9 — "Piece" renamed to "Unit", and choosing the system when creating a kitchen

### "Piece" renamed to "Unit"

**What was asked.** The label for countable items (eggs, cans, apples) read *"Piece"*, which felt inconsistent with the rest of the product.

**What we delivered.** Every place in the app that shows a countable quantity now reads **"Unit"** — pantry cards, item details, consumption history, recipe ingredients, shopping lists, item requests, the shared grocery text, and push notifications.

We also made the app tolerant of older data. Items saved before this change, or produced by receipt scanning, may still carry the old wording internally; the app recognises all of those variants and displays them consistently as **"Unit"**. Nothing had to be migrated, and no historical item shows the old label.

### Choosing the system when creating a kitchen

While checking the delivered work against the business requirements document, we found that a required capability had no ticket and did not exist in the app: **the user was never asked which system they wanted.** Every kitchen created from the app silently defaulted to metric, and there was no way to get an imperial kitchen at all.

**What we delivered.** The "create kitchen" dialog now asks for the measurement system alongside the name, and the choice is applied immediately — the very first screen after creation already shows the right units. This was implemented in both places in the app where a kitchen can be created.

---

## KG-7 — The preference applies everywhere

**What was asked.** A kitchen's measurement system should be respected across the whole product, not just one screen.

**What we delivered.** Every place where a user picks a unit now offers the units of the active kitchen's system:

- adding an item by hand
- editing an existing pantry item
- reviewing items detected from a scanned receipt
- reviewing items detected from a kitchen photo
- adding a custom item to the shopping list
- requesting an item
- editing a recipe ingredient

Switching between a metric kitchen and an imperial one changes all seven of these instantly. There is no screen left behind showing the wrong system.

---

## KG-8 — The preference is remembered

**What was asked.** The choice must survive closing and reopening the app.

**What we delivered.** Each kitchen's preference is stored on the device alongside the copy held on the server. When the app opens, the correct system is applied **before the first screen is drawn** — the user never sees a flash of the wrong units. The app then quietly confirms with the server in the background, so a change made on another device is picked up without the user doing anything.

Because the preference is kept per kitchen, a user who belongs to a metric kitchen and an imperial one gets the right system in each, and switching between them is instant.

---

## KG-6 — Metric ↔ Imperial conversion

**What was asked.** Real conversion between the two systems, not a placeholder.

**What we delivered.** Quantities are converted centrally on the server, so the phone and any future client always agree. The app was aligned to speak exactly the same vocabulary of units the server understands, and it deliberately performs **no arithmetic of its own** — a design choice that removes an entire class of rounding and drift bugs.

The result is that conversions read naturally rather than literally:

| Entered | Shown |
|---|---|
| 3 teaspoons | **1 tablespoon** |
| 16 ounces | **1 pound** |
| 1500 grams | **1.5 kg** |
| 2000 ml | **2 litres** |

The system picks the unit a cook would actually say out loud, instead of "0.983 cups".
