# FYP Implementation Plan Template

When generating the implementation plan for the user's approval, format the plan using the following template and save it directly to `FRONTEND_PLAN.md` at the project root. Log progress in `AGENTS.md`.

---

```markdown
# [Project Name] - Flutter Frontend Implementation Plan

## 1. Executive Summary & Document Review
- **Project Domain**: [e.g. Healthcare / E-commerce / EdTech / IoT Companion]
- **Target Users**: [Primary personas identified from project-docs]
- **Key Objectives**: [Primary goals of the mobile client]
- **Documents Analyzed**:
  - `project-docs/[doc1.pdf]` - [Summary of takeaways]
  - `project-docs/[doc2.md]` - [Summary of takeaways]

---

## 2. Core Feature & Screen Breakdown
List all screens discovered in the project documents, categorized by domain:

### Phase A: Authentication & Onboarding
- [ ] **Splash Screen**: Animated logo, version tag, auth state gate
- [ ] **Onboarding Carousel**: 3-slide value proposition walkthrough
- [ ] **Login Screen**: Email/phone login, password visibility, social mock buttons, validation
- [ ] **Registration Screen**: Multi-field form, terms checkbox, validation
- [ ] **Forgot Password / OTP**: Password reset flow with mock timer countdown

### Phase B: Main Navigation & Dashboard
- [ ] **Main Shell (Bottom Navigation Bar)**: Persistent tabs with badges
- [ ] **Home Dashboard**: Hero banner, quick stats cards, recent activity, action buttons
- [ ] **Notification Center**: Grouped alerts with read/unread toggles

### Phase C: Core Feature Modules ([Feature Domain])
- [ ] **Feature List / Feed**: Search bar, category filter chips, sort modal, infinite-scroll mock list
- [ ] **Item Detail Screen**: Hero image carousel, specifications, interactive action sheet
- [ ] **Create / Edit Form**: Image picker mock, multi-step stepper or input fields, form validation
- [ ] **Search & Filter Drawer**: Range sliders, multi-select tags, clear/apply actions

### Phase D: User Profile & App Settings
- [ ] **Profile Overview**: Avatar, user metadata, account stats, menu items
- [ ] **Edit Profile**: Editable fields, avatar upload mock
- [ ] **Settings Screen**: Theme toggle (Dark/Light), notifications switch, About & FAQ dialog

---

## 3. Data Models & Mock Dataset Design
Specify all data models and the realistic dummy records that will be created:

| Model Name | Key Properties | Mock Data Count | Sample Record |
|------------|----------------|-----------------|---------------|
| `UserModel` | id, name, email, avatar, role, phone | 3 profiles | "Dr. Sarah Khan, Lead Clinician" |
| `[Entity]Model` | id, title, category, status, date, rating | 10-15 records | Realistic domain-specific items |

---

## 4. Design System & Theming Specifications
- **Color Palette**:
  - Primary: `#[HEX]` ([Role description])
  - Secondary / Accent: `#[HEX]`
  - Background (Light/Dark): `#[HEX]` / `#[HEX]`
  - Surface & Card: `#[HEX]` / `#[HEX]`
  - Semantic: Success (`#10B981`), Warning (`#F59E0B`), Error (`#EF4444`)
- **Typography**: Google Fonts [Font Name] (Display, Headings, Body, Captions)
- **Component Styling**: Rounded corners (`12px-16px`), subtle drop shadows, custom elevations

---

## 5. File Creation Roadmap
List every file that will be created or modified once approved:

1. `pubspec.yaml` (Dependencies & assets)
2. `lib/core/theme/...`
3. `lib/core/widgets/...`
4. `lib/data/models/...`
5. `lib/data/mock/...`
6. `lib/data/repositories/...`
7. `lib/features/...`
8. `lib/routes/...`
9. `lib/main.dart`

---

## 6. Approval Required
> [!IMPORTANT]
> **Please review this plan.**
> If everything matches your vision, reply with **"Approve"** (or click the Proceed button) and the complete Flutter frontend will be generated immediately. If you need any additions, screen alterations, or specific styling changes, reply with your adjustments!
```
