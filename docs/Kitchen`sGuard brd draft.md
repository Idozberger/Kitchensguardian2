# **Kitchen's Guardian** 

## **Description**

Kitchen'sGuardian is an AI-powered kitchen management application that helps users manage pantry inventory, scan receipts, generate recipes, and reduce food waste.

This phase focuses on improving the onboarding experience, enhancing receipt scanning accuracy and scalability, introducing a configurable measurement system, optimizing AI-powered functionality through intelligent caching mechanisms, and developing a dedicated Administration Panel for managing cached data and AI-generated assets. 

## **High-Level Structure / User Flow**

1. User completes onboarding and creates an account.  
2. User creates a kitchen and selects a preferred measurement system (Metric or Imperial).  
   user then scan fridge to log in all ingredients they already have.  
3. User scans grocery receipts to automatically populate and to update pantry inventory.   
4. Application tracks ingredient quantities, low stock and expiration dates.  
5. User generates recipes based on available ingredients.  
6. User creates grocery lists for missing items, meal plan.  
7. User plans meals throughout (for the week) the week.

User Actions:

* Scan Receipt  
* Review & Edit Scanned Items (wrong items flagged)  
* Save Items to Pantry  
* Generate Recipes  
* Create Grocery Lists  
* Manage Kitchen Settings  
* plan meals

System Processes:

* Receipt Recognition (item recognition)  
* Ingredient Matching  
* Shared Ingredient Caching (only in same district)  
* Recipe Caching  
* Icon Caching  
* Unit Conversion  
* Low Confidence Detection

# **Business Rules**

* Measurement preference is stored at the kitchen level.  
* Measurement preference persists between user sessions.  
* AI-generated icons are shared across all users.  
* Ingredient cache matching considers currency and region when available.  
* Price variations within a reasonable threshold should not prevent cache matching.  
* Only high-confidence (\>95%) scan results are stored in the shared ingredient database.  
* Cached recipes are used internally to optimize AI generation but do not replace newly generated recommendations.  
* Users always receive at least two newly generated recipe suggestions.  
* Receipt uploads support image formats and PDF documents only.

## **Non-Functional Requirements**

### **Performance**

* Receipt scanning should remain responsive under high concurrent usage.  
* Cache lookup should occur before initiating AI requests.  
* Shared ingredient lookup should support large-scale datasets.

### **Scalability**

* Shared ingredient database must support millions of records.  
* Caching architecture should minimize redundant AI requests.

### **Reliability**

* Failed AI requests must not interrupt the user flow.  
* Manual correction must always be available for low-confidence scan results.

### **Security**

* Administrative functionality is accessible only to authorized administrators.  
* Administrative changes must be persisted immediately.

## **Main Functions & Deliverables**

### **Onboarding Redesign**

* Implement onboarding screens according to approved designs.  
* Add informational text below Kitchen Scan Skip button.  
* Implement reminder flow for skipped kitchen scan.  
* Improve onboarding-to-home-screen transition.

### **Unit Selector (Metric / Imperial)**

* Add unit preference selection during kitchen creation.  
* Store preference at kitchen level.  
* Allow preference changes through Settings.  
* Automatically convert existing measurements when preference changes.  
* Rename "Piece" to "Unit" across application and database.

### **Icon Caching**

* Generate ingredient icons once.  
* Reuse icons across all users.  
* Prevent duplicate AI icon generation requests.  
* Support centralized icon storage.

### **Receipt Scanning Improvements**

* Improve scalability and performance.  
* Support scanning from:  
  * Camera  
  * Gallery  
  * File Upload(Image Files and PDF Documents)   
* Improve quantity estimation.  
* Improve knowledge of what measurement to use. (sometimes it counts apples as 242 grams, or canned food like 2 piece)   
* Improve retailer-independent recognition accuracy.  
* Add low-confidence warning flow.  
* Maintain manual review and editing process.

### **Recipe Caching**

* Implement recipe cache storage.  
* Implement similarity matching logic.  
* Reuse existing recipes when applicable.  
* Continue generating at least two new recipes for each request.

### **Ingredient & Receipt Item Caching**

* Build shared ingredient database.  
* Store high-confidence scan results.  
* Match scans against existing database before AI processing.  
* Support region and currency-aware matching.  
* Implement scalable indexing and lookup mechanisms.

### **Basic Cache Administration**

* Manage cached icons.  
* Manage cached recipes.  
* Manage shared ingredient records.  
* Replace, remove, and review cached data.

# **Functional Sections**

## **1\. Onboarding Redesign**

### **Function Description**

Improve onboarding experience and provide better guidance for users who skip pantry scanning during setup.

### **Use Cases & Acceptance Criteria**

#### **UC-01 Skip Kitchen Scan**

**Acceptance Criteria**

* User can skip Kitchen Scan during onboarding.  
* Informational text "You can always do this later in the app" is displayed below the Skip button.  
* System records skipped status.  
* User receives a reminder when reopening the application.

#### **UC-02 Complete Onboarding**

**Acceptance Criteria**

* User can complete onboarding successfully.  
* User is redirected to the Home Screen. If the user scanned their fridge, when they are redirected to the home page they should see a summary of everything the AI caught.  
* No broken navigation paths exist.

## **2\. Unit Selector**

### **Function Description**

Allow users to define and manage their preferred measurement system.

### **Use Cases & Acceptance Criteria**

#### **UC-03 Select Unit System**

**Acceptance Criteria**

* User selects Metric or Imperial during kitchen creation.  
* Preference is stored successfully.  
* Preference persists between sessions.

#### **UC-04 Update Unit Preference**

**Acceptance Criteria**

* User can update preference in Settings.  
* Existing application data is automatically converted.  
* Changes are reflected across pantry, recipes, grocery lists, and receipt items.

## **3\. Receipt Scanning Improvements**

### **Function Description**

Improve receipt scanning accuracy, scalability, and user feedback.

### **Use Cases & Acceptance Criteria**

#### **UC-05 Scan Receipt**

**Acceptance Criteria**

* User can upload a receipt using camera capture, gallery selection, or file upload.(Supported file formats include image files and PDF documents.)   
* Receipt is processed successfully.  
* Detected items are displayed for review.

#### **UC-06 Low Confidence Detection**

**Acceptance Criteria**

* Low-confidence items are identified.  
* Warning icon is displayed.  
* User receives notification to verify detected information.  
* User can manually adjust results.

#### **UC-07 Review Results**

**Acceptance Criteria**

* User can edit detected items.  
* Updated values can be saved.  
* Corrected items are stored successfully.

## **4\. Icon Caching**

### **Function Description**

Reduce AI generation costs by storing and reusing ingredient icons.

### **Use Cases & Acceptance Criteria**

#### **UC-08 Retrieve Existing Icon**

**Acceptance Criteria**

* System checks cache before generating icon.  
* Existing icon is reused when available.  
* No duplicate generation request is triggered.

#### **UC-09 Generate New Icon**

**Acceptance Criteria**

* New icon is generated when no match exists.  
* Icon is stored for future use.  
* Icon becomes available across all users.

## **5\. Recipe Caching**

### **Function Description**

Reduce recipe generation costs through cache-assisted recipe retrieval while maintaining content freshness by generating new recipe suggestions for every user request.

### **Use Cases & Acceptance Criteria**

#### **UC-10 Retrieve Cached Recipe**

**Acceptance Criteria**

* System evaluates recipe similarity based on available ingredients and user keywords.  
* Cached recipes may be used internally as a reference source when a match is identified.  
* Cached recipes are marked as "Previously Generated".  
* Cache retrieval reduces AI generation requests.

#### **UC-11 Generate New Recipes**

**Acceptance Criteria**

* System generates at least two new recipes for every recipe request.  
* Users receive newly generated recipe recommendations even when a cache match exists.  
* Cached recipes may be utilized internally to support recipe generation and recommendation quality.  
* New recipes may be added to the recipe cache for future reuse.

## **6\. Ingredient & Receipt Item Caching**

### **Function Description**

Create a shared ingredient intelligence layer to improve scan speed and accuracy.

### **Use Cases & Acceptance Criteria**

#### **UC-12 Cache Matching**

**Acceptance Criteria**

* System checks existing ingredient database before AI processing.  
* Region and currency are considered during matching.  
* Reasonable price variation does not prevent matching.

#### **UC-13 Store High Confidence Results**

**Acceptance Criteria**

* Items above confidence threshold are stored.  
* Currency information is stored with records.  
* Data is available for future matching.

# **7\. Administration Panel**

## **Function Description**

Develop a new Administration Panel that provides administrators with centralized access to manage AI-generated assets and shared cached data. The panel will support monitoring, reviewing, editing, and moderating cached information to maintain data quality, improve AI output, and ensure efficient system operation.

## **Use Cases & Acceptance Criteria**

### **UC-14 Administrator Authentication**

#### **Acceptance Criteria**

* Authorized administrators can securely access the Administration Panel.  
* Unauthorized users cannot access administrative functionality.  
* Administrator sessions are securely managed.

### **UC-15 Dashboard**

#### **Acceptance Criteria**

* The Administration Panel displays a dashboard containing available management modules.  
* Administrators can navigate to Cached Icons, Cached Recipes, and Shared Ingredient Database sections.  
* Dashboard displays summary statistics for cached content.

### **UC-16 Manage Cached Icons**

#### **Acceptance Criteria**

* Admin can view all cached ingredient icons.  
* Admin can search and filter cached icons.  
* Admin can preview icon images.  
* Admin can replace incorrectly generated icons.  
* Admin can delete invalid or duplicate icons.  
* Updates are immediately reflected throughout the application.

### **UC-17 Manage Cached Recipes**

#### **Acceptance Criteria**

* Admin can view cached recipes.  
* Admin can search recipes by name or keyword.  
* Admin can review recipe details.  
* Admin can delete outdated or incorrect recipes.  
* Removed recipes are excluded from future cache retrieval.

### **UC-18 Manage Shared Ingredient Database**

#### **Acceptance Criteria**

* Admin can view shared ingredient records.  
* Admin can search and filter ingredients.  
* Admin can filter by region, currency, confidence score, or status.  
* Admin can review ingredient details.  
* Admin can flag suspicious or low-quality entries.  
* Admin can delete invalid records.  
* Deleted records are excluded from future cache matching.

