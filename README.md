# MedicalApp: Hospital Hygiene & Compliance Tracker

MedicalApp is a specialized mobile application built with Flutter to digitize and automate hygiene tracking in hospital environments. Designed to replace manual, paper-based workflows, the app streamlines data entry for sanitation audits and automatically generates statistical insights to ensure hospital compliance standards are met.

## The Problem & Solution
**The Problem:** Hospital administrators and infection control staff often rely on tedious paper surveys to track hand hygiene compliance, stock levels of sanitization resources, and staff technique. This manual process makes statistical analysis time-consuming and error-prone. 
**The Solution:** MedicalApp provides an intuitive, offline-first digital interface for logging observations. It instantly processes entry data to generate visual compliance dashboards and automated PDF reports, saving administrative time and providing immediate visibility into hospital hygiene metrics.

## Key Features
* **Role-Based Access Control:** Secure authentication system supporting initial Admin setup and Regular User accounts, utilizing BCrypt password hashing for security.
* **Resource Auditing:** Multi-step observation forms to track critical resources across hospital sections and salons, including running water, liquid soap, paper towels, and disinfectant availability.
* **Handwashing Technique Evaluation:** Built-in 7-step technical handwash surveys to evaluate staff compliance with standardized hygiene protocols.
* **Automated Analytics:** Dynamic statistical dashboards that calculate and visualize compliance percentages over custom time periods (e.g., 7 days, 30 days, 1 year).
* **PDF Report Generation:** One-click automated PDF export of monthly hygiene observations, formatted for official record-keeping.
* **Offline-First Architecture:** Completely functional without an active internet connection by utilizing local SQLite database storage for all surveys and user data.

## Tech Stack
* **Framework:** Flutter / Dart
* **State Management:** Provider
* **Local Database:** SQLite via `sqflite` package
* **Security:** `bcrypt` for local password encryption
* **PDF Export:** `pdf` and `printing` packages
* **Styling:** Custom theming utilizing `google_fonts`
