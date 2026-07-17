#  Kitchen's Guardian — QA Testing Checklist

Only items that can be verified through the app UI or as an end user — no backend, database, logs, or API-level checks.

---

## 1\. Onboarding Redesign (UC-01, UC-02, UC-03)

- [ ] After account registration, user lands on the **Kitchens** page (not fridge scan or Home).  
- [ ] User can create a new kitchen.  
- [ ] User can join an existing kitchen.  
- [ ] Fridge scanning flow is inaccessible until a kitchen is created or joined.  
- [ ] After kitchen setup, user is taken to the fridge scanning step.  
- [ ] Onboarding screens appear while the fridge scan is still processing (spinner/progress visible on Home afterward confirms it was running in background).  
- [ ] Onboarding screens are fully navigable while scan processing runs in the background.  
- [ ] Navigating back/forward through onboarding screens doesn't visibly interrupt or restart the scan.  
- [ ] "Skip" option is available on the fridge scan step.  
- [ ] Informational text "You can always do this later in the app." appears directly below the Skip button.  
- [ ] After skipping and reopening the app, user sees a reminder to scan.  
- [ ] Reminder no longer appears after the user completes the scan.  
- [ ] When onboarding finishes **and** scan is complete → redirect to Home with detected pantry items summary.  
- [ ] When onboarding finishes **before** scan completes → an appropriate loading/pending state is shown (not a broken screen or error).  
- [ ] Loading state transitions correctly once scan results become available.  
- [ ] No dead ends / broken navigation at any step of onboarding (back button, close app, kill app mid-flow, reopen).

## 2\. Unit Selector — Metric / Imperial (UC-03, UC-04)

- [ ] Unit preference (Metric/Imperial) is selectable during kitchen creation.  
- [ ] A second user who joins the same kitchen sees the same unit system (no separate per-user setting).  
- [ ] Preference persists after logout/login and app restart.  
- [ ] Preference can be changed later via Settings.  
- [ ] Changing preference triggers automatic conversion of existing measurements.  
- [ ] Converted values look correct (spot-check a few known conversions).  
- [ ] Conversion is reflected consistently across: Pantry, Recipes, Grocery Lists, Receipt items.  
- [ ] "Piece" is renamed to "Unit" everywhere visible in the app (labels, dropdowns, recipes, receipts).  
- [ ] Switching units back and forth doesn't visibly corrupt quantities or lose data.  
- [ ] Items with no unit / unit-less counts still display correctly after conversion.

## 3\. Receipt Scanning (UC-05, UC-06, UC-07)

- [ ] Receipt can be uploaded via **Camera**.  
- [ ] Receipt can be uploaded via **Gallery**.  
- [ ] Receipt can be uploaded via **File Upload** — image formats.  
- [ ] Receipt can be uploaded via **File Upload** — PDF documents.  
- [ ] Uploading an unsupported file format shows a clear error message.  
- [ ] Successfully processed receipt displays detected items for review.  
- [ ] Quantity estimation looks reasonably accurate on a few sample receipts.  
- [ ] Recognition works on receipts from different retailers (test with a few different stores).  
- [ ] Low-confidence items are visually flagged with a warning icon.  
- [ ] User is notified/prompted to verify low-confidence detections.  
- [ ] User can manually adjust/correct any detected item (name, quantity, unit, price).  
- [ ] User can highlight/flag an item as "wrong" during review.  
- [ ] Edited items save correctly and persist to pantry after leaving/returning to the screen.  
- [ ] If receipt processing fails, the app shows a clear message and lets the user continue manually (doesn't freeze or crash).

## 4\. Icon Caching (UC-08, UC-09)

- [ ] Scanning/adding the same ingredient again shows the same icon (not a newly generated one, e.g. check it appears instantly vs. with generation delay).  
- [ ] A brand-new ingredient (not seen before) gets a newly generated icon.  
- [ ] New icon appears correctly for the user who triggered it, and is also visible to another user in a different kitchen (test with two accounts).

## 5\. Recipe Caching (UC-10, UC-11)

- [ ] Recipes sourced from cache are labeled "Previously Generated" in the UI.  
- [ ] Regardless of whether a similar recipe already exists, requesting recipes always returns **at least two newly generated** recipes (not just previously generated ones).  
- [ ] Recipe suggestions still feel relevant/varied on repeated requests (no obvious staleness or repetition).

## 6\. Ingredient & Receipt Item Caching (UC-12, UC-13)

- [ ] Scanning the same item again (same store/region/currency) is recognized faster / matches previous entry rather than behaving like a brand-new item.  
- [ ] Scanning the same item with a slightly different price still matches correctly (reasonable price variation doesn't break recognition).  
- [ ] Scanning the same item with a very different price, region, or currency is treated appropriately (doesn't wrongly force a false match).

## 7\. Administration Panel (UC-14–UC-18)

**Authentication & Access**

- [ ] Authorized administrators can log in and access the panel.  
- [ ] Non-admin users cannot access the panel (including trying a direct link/URL to the admin section).  
- [ ] Admin session behaves securely (e.g., logs out after logout action, doesn't remain accessible after logging out and pressing back).

**Dashboard**

- [ ] Dashboard loads and displays available modules: Cached Icons, Cached Recipes, Shared Ingredient Database.  
- [ ] Summary statistics on the dashboard appear reasonable/consistent with what's visible in each module.  
- [ ] Navigation to each module works correctly.

**Manage Cached Icons**

- [ ] Admin can view all cached icons (scrolling/pagination works for larger sets).  
- [ ] Search and filter functions return correct results.  
- [ ] Icon preview displays correctly.  
- [ ] Admin can replace an icon; the change is reflected in the app immediately.  
- [ ] Admin can delete an icon; it no longer appears in the app afterward.

**Manage Cached Recipes**

- [ ] Admin can view all cached recipes.  
- [ ] Search by name/keyword returns correct results.  
- [ ] Admin can open and review full recipe details.  
- [ ] Admin can delete a recipe.  
- [ ] Deleted recipe no longer appears anywhere in the app (recipe list, "Previously Generated" suggestions).

**Manage Shared Ingredient Database**

- [ ] Admin can view shared ingredient records.  
- [ ] Search and filter work correctly.  
- [ ] Filtering by region works.  
- [ ] Filtering by currency works.  
- [ ] Filtering by confidence score works.  
- [ ] Filtering by status works.  
- [ ] Admin can review full ingredient record details.  
- [ ] Admin can flag a record as suspicious/low-quality.  
- [ ] Admin can delete a record.  
- [ ] Deleted record no longer shows up or gets matched during future receipt scans.  
- [ ] After making a change, refreshing the page/app shows the change persisted (didn't revert).

## 8\. Cross-Cutting Business Rules (Observable in App)

- [ ] Measurement preference is the same for all users in a kitchen (confirmed with multiple accounts).  
- [ ] AI-generated icons are visible to all users, not just the one who triggered generation.  
- [ ] Receipt uploads only accept image files and PDFs — other formats are rejected with a message.  
- [ ] Recipe requests always return at least two new recipes, even when similar ones exist in cache.

## 9\. General Reliability & UX Checks

- [ ] A failed AI request (scan, recipe, icon) doesn't crash the app or block the user from continuing.  
- [ ] Manual correction is always available when a scan result looks wrong or low-confidence.  
- [ ] Non-admin users never see admin-only screens or options anywhere in the app.  
- [ ] All admin changes (icons, recipes, ingredients) show up immediately without needing a manual refresh/re-login.

---

### Suggested Test Types to Cover

- [ ] Functional (happy path) testing for each use case above.  
- [ ] Negative/edge-case testing (invalid file formats, empty states, canceling mid-flow).  
- [ ] Regression testing after changing unit preference or editing cached data.  
- [ ] Cross-account testing for shared behavior (icons, kitchen-level unit setting, admin changes visible to all users).  
- [ ] Exploratory testing of navigation (back button, force-close app, deep links) at every step of onboarding and admin flows.

