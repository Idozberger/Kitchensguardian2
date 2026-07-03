**Kitchen'sGuardian — Priority Based Scope of Work (Pre-Launch)** 

**1\. Onboarding Redesign** 

Update and polish the current onboarding flow. Screens have already been designed but may require minor edits and implementation adjustments. Key addition: on the kitchen scanning screen, add a line under the Skip button that reads "You can always do this later in the app" so users understand they are not permanently skipping this step. 

**Deliverables:** 

● Updated onboarding screens matching provided designs 

● "Do this later" line implemented under kitchen scan skip button 

● Smooth flow from account creation through to home screen 

**2\. Unit Selector (Metric / Imperial)** 

When a user creates a new kitchen, they will be prompted to select their preferred measurement system — metric or imperial. This preference will be tied to their kitchen and applied universally across the entire app experience. 

**Deliverables:** 

● Unit preference prompt added to the kitchen creation flow 

● All ingredient quantities, scanned receipt items, and recipe measurements displayed in the user's selected system 

● Preference stored and persisted — does not reset between sessions ● All existing unit fields updated to reflect the selected system (scanning, manual entry, recipe suggestions, grocery lists) 

● Rename the current "Piece" unit to "Unit" across all screens and database entries for clarity 

**3\. Icon Caching** 

Currently the app generates and fetches a new icon every single time an ingredient is displayed. This results in unnecessary AI calls, higher costs, and slower load times at scale. The goal is to generate each icon once and reuse it indefinitely. 

**Deliverables:** 

● Icon generated once per unique ingredient and stored in the database ● All future instances of the same ingredient across all users serve the cached icon  
● If a cached icon already exists for an item, no new AI call is made 

● Icons consistent across users (e.g. all users with "milk" see the same icon) ● Significant reduction in image generation API costs 

**4\. Receipt Scanning Improvements** 

Receipt scanning is the core feature of Kitchen'sGuardian and must be rebuilt to handle scale. The current implementation was not designed for high volume and needs to be optimized for accuracy, reliability, and performance. 

**Deliverables:** 

● Scanning rebuilt to handle high user volume without degradation or crashes ● Improved prompt accuracy — canned goods should display weight alongside count (e.g. "Diced Tomatoes, 1 can \~350g" instead of "1 count") 

● Consistent item recognition across different receipt formats and retailers ● Graceful error handling when scanning fails or confidence is low 

**5\. Recipe Caching** 

Currently every recipe request triggers a new AI generation call regardless of whether a similar recipe has already been generated. The goal is to build a caching layer that serves existing recipes when the request is similar enough, reducing cost and improving speed. 

**Deliverables:** 

● Recipe caching database built and integrated 

● When a user requests a recipe matching a previously generated one, the cached version is served instead of a new AI call 

● Similar keyword matching logic implemented to determine cache hits ● Measurable reduction in OpenAI recipe generation costs 

● Recipe load times improved for cached results 

**6\. Ingredient & Receipt Item Caching** 

Build a shared ingredient database that stores high-confidence scanned items over time. As the database grows, scanning becomes faster, cheaper, and more accurate — eventually near-instant for commonly purchased items. 

**Deliverables:** 

● High-confidence scanned items (AI certainty \>95%) stored in a shared database ● User's currency stored alongside each scanned item for localization accuracy  
● On future scans, database is checked first before making a new AI call ● Over time, common items are resolved instantly from cache with no AI cost ● Database structured to scale — designed to handle millions of entries efficiently