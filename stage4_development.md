# Stage 4 — Agile Development & MVP Implementation
## Haven — Anti-Bullying Reporting Platform

---

## Project Overview

**Application:** Haven — A confidential incident reporting application for victims of bullying in educational institutions. Students can report harassment anonymously, track the progress of their reports, and access emotional support resources. Staff members can view and manage reports for their school.

**Tech Stack:**
- Frontend: Flutter (Android/iOS)
- Backend: Next.js 14 (App Router) + TypeScript
- Database: PostgreSQL via Prisma ORM
- Version Control: Git / GitHub — https://github.com/Alistair31/Portfolio-Project

**State at the start of Stage 4 — Already implemented:**

| Feature | Status |
|---|---|
| Authentication (login, register, RGPD consent) | ✅ Done |
| Onboarding flow (3 screens) | ✅ Done |
| School validation on registration | ✅ Done |
| Report submission form + `POST /api/reports` | ✅ Done |
| Chatbot decision tree (guidance + emergency cards) | ✅ Done |
| Session management (`SessionService` + `SharedPreferences`) | ✅ Done |
| Security audit fixes (anonymization, error leak) | ✅ Done |
| Logout and account deletion | ✅ Done |

**Remaining MVP scope:**

| Feature | Status |
|---|---|
| Student tracking tab (view own reports + tracking code) | ❌ Pending |
| Victim / Witness mode in report form | ❌ Pending |
| Staff interface (list & manage reports) | ❌ Pending |
| Follow-up creation by staff (status updates) | ❌ Pending |
| Mood check-in UI | ❌ Pending |
| Integration testing & final QA | ❌ Pending |

---

## Team Roles & Responsibilities

| Member | Role | Responsibilities |
|---|---|---|
| Gabriel | Developer — Flutter (Frontend) | UI implementation, widget development, navigation, Flutter services |
| Alistair | SCM + Developer — Next.js (Backend) | Git branch management, pull request reviews, API endpoints, database migrations |
| [PM name] | Project Manager | Sprint planning, stand-ups facilitation, progress tracking, deviation management |
| [QA name] | Quality Assurance | Test plan design, manual testing, bug reporting, acceptance criteria validation |

---

## 0. Plan and Define Sprints

### Sprint Duration and Calendar

| Sprint | Period | Focus |
|---|---|---|
| Sprint 1 | Week 1 – Week 2 | Student-facing feature completion |
| Sprint 2 | Week 3 – Week 4 | Staff interface and report management |
| Sprint 3 | Week 5 – Week 6 | Integration, QA, and final polish |

---

### MoSCoW Prioritization

#### Sprint 1 — Student Core Experience

| Priority | Task | Assigned to | API Dependency |
|---|---|---|---|
| **Must Have** | Suivi tab: fetch and display student's own reports | Gabriel | `GET /api/reports/mine` ✅ |
| **Must Have** | Display tracking code in post-submission confirmation dialog | Gabriel | `POST /api/reports` (add field to response) |
| **Must Have** | Add Victim / Witness mode selector in report form | Gabriel | `POST /api/reports` (add `mode` field) |
| **Should Have** | Report detail page from Suivi tab | Gabriel | `GET /api/reports/mine/[id]` ✅ |
| **Should Have** | Pull-to-refresh on Suivi tab | Gabriel | — |
| **Could Have** | Mood check-in widget on Accueil tab | Gabriel | `POST /api/mood` ✅ |
| **Won't Have** | Staff interface | — | — |
| **Won't Have** | Push notifications | — | — |

#### Sprint 2 — Staff Interface

| Priority | Task | Assigned to | API Dependency |
|---|---|---|---|
| **Must Have** | Role-based routing on login (staff vs student) | Gabriel | `POST /api/auth/login` ✅ (role in JWT) |
| **Must Have** | Staff reports list view (school-filtered, anonymization respected) | Gabriel | `GET /api/reports` ✅ |
| **Must Have** | Report detail view for staff | Gabriel | `GET /api/reports/[id]` ✅ |
| **Must Have** | Follow-up creation (status update + notes) | Gabriel + Alistair | `POST /api/reports/[id]/followup` ❌ new endpoint |
| **Should Have** | Filter reports by status / type / gravity | Gabriel | query params on `GET /api/reports` |
| **Should Have** | Admin user management screen | Gabriel | `GET /api/admin/users` ✅ |
| **Could Have** | Mood history chart (7-day view) | Gabriel | `GET /api/mood` ✅ |
| **Won't Have** | Push notifications | — | — |

#### Sprint 3 — Integration, QA & Polish

| Priority | Task | Assigned to |
|---|---|---|
| **Must Have** | End-to-end integration testing (auth → report → staff view) | QA |
| **Must Have** | Critical bug fixes from Sprint 1 & 2 | Gabriel + Alistair |
| **Must Have** | Final QA pass on all MVP features | QA |
| **Should Have** | In-app notification display | Gabriel + Alistair |
| **Should Have** | Mood history chart (if not completed in Sprint 2) | Gabriel |
| **Could Have** | FCM push notifications | Alistair |
| **Won't Have** | Analytics dashboard | — |
| **Won't Have** | Dark mode | — |

---

### Task Dependencies

```
Sprint 1:
  Tracking code display
    └─ requires: POST /api/reports returns trackingCode in response

  Victim/Witness mode
    └─ requires: mode field added to POST /api/reports body

Sprint 2:
  Staff role routing
    └─ requires: role field present in JWT (already the case)

  Follow-up creation
    └─ requires: new endpoint POST /api/reports/[id]/followup (Alistair)
    └─ blocks: status update UI (Gabriel)

  Filter reports
    └─ requires: staff list view completed first
```

---

## 1. Execute Development Tasks

### Git Branching Strategy

The project follows a **feature branch** model:

```
main
└── dev
    ├── feature/suivi-tab          (Sprint 1 — Gabriel)
    ├── feature/report-mode        (Sprint 1 — Gabriel)
    ├── feature/tracking-code      (Sprint 1 — Gabriel)
    ├── feature/staff-view         (Sprint 2 — Gabriel)
    ├── feature/followup-api       (Sprint 2 — Alistair)
    └── feature/mood-chart         (Sprint 2 — Gabriel)
```

**Rules enforced by SCM (Alistair):**
- All work happens on feature branches — no direct commits to `main` or `dev`.
- Pull requests are required to merge into `dev`. Alistair reviews each PR before approval.
- Merges into `main` happen only at the end of a sprint, after QA validation.
- Branch names follow the format: `feature/<short-description>` or `fix/<short-description>`.

### Coding Standards

**Flutter (Gabriel):**
- One widget per file; file name matches widget name in `snake_case`.
- Use `const` constructors wherever possible.
- Always check `if (!mounted) return;` after `await` in `StatefulWidget`.
- No hardcoded strings — use the constant maps already established in `report_page.dart`.

**Next.js / TypeScript (Alistair):**
- All handlers follow the existing pattern: `extractUser()` → role check → try/catch → `console.error` on failure.
- No raw error details exposed in responses (cf. security audit S4).
- Zod used for all request body validation.
- New Prisma migrations named descriptively (`add_followup_endpoint`, etc.).

### QA Process per Sprint

For each completed feature:
1. Developer creates a pull request with a short description of what was implemented.
2. SCM (Alistair) reviews the code for standards compliance and merges into `dev`.
3. QA tests the feature against its acceptance criteria (defined below).
4. Bugs are logged in the bug tracker with reproduction steps, severity, and assigned developer.
5. Fix is delivered on a `fix/` branch and re-tested before the sprint closes.

---

### Acceptance Criteria per Feature

**Suivi tab:**
- Authenticated student opens the Suivi tab → list of their reports appears, sorted by date descending.
- Each card shows: report type, gravity level, current status (PENDING / IN_PROGRESS / CLOSED), creation date, and tracking code.
- Empty state is shown if no reports exist.
- Pull-to-refresh reloads the list from the API.

**Tracking code display:**
- After submitting a report, the confirmation dialog shows the tracking code (e.g., `HAV-XXXXXXXX`).
- The tracking code matches the one stored in the database for that report.

**Victim / Witness mode:**
- Report form shows a two-option selector: "Je suis victime" / "Je suis témoin".
- Selected mode is sent in the `POST /api/reports` body as `mode: "VICTIM"` or `mode: "WITNESS"`.
- The field is required; submitting without a selection shows a validation error.

**Staff reports list:**
- A staff user (role `TEACHER`, `DIRECTOR_CPE`, or `RECTORAT`) logs in and is redirected to the staff dashboard (not the student home).
- The list shows only reports targeting their role level, from their school.
- Anonymization is applied: reports with `FULLY_ANONYMOUS` show masked author info.

**Follow-up creation:**
- Staff taps a report → detail view → "Add follow-up" button.
- Form accepts: notes (text, required, min 10 chars) and new status.
- After submission, the report's status updates in the list view.

---

## 2. Monitor Progress and Adjust

### Daily Stand-Up Format

Each working day, the team conducts a brief stand-up (max 15 minutes) structured around three questions:

1. **What did I complete since the last stand-up?**
2. **What will I work on today?**
3. **Are there any blockers?**

Blockers are escalated to the PM immediately and resolved the same day when possible. If a blocker persists more than one day, the sprint plan is adjusted.

### Progress Metrics

| Metric | Definition | Target |
|---|---|---|
| Sprint Velocity | Number of tasks completed per sprint | ≥ 80% of planned tasks |
| Task Completion Rate | (Completed tasks / Planned tasks) × 100 | ≥ 80% |
| Bug Count | Bugs reported during QA per sprint | Track and reduce sprint-over-sprint |
| Bug Resolution Rate | Bugs fixed / Bugs reported | ≥ 100% for critical bugs |
| PR Review Time | Time between PR creation and SCM merge | ≤ 1 business day |

### Adjustment Rules

- If a task is blocked for more than 2 days, it is reassigned or moved to the next sprint.
- If the velocity falls below 60% by mid-sprint, a scope reduction is discussed in the stand-up.
- New bugs discovered during a sprint are prioritized as **critical** (fix in current sprint) or **non-critical** (backlog for next sprint).

### Sprint 1 — Mid-Sprint Checkpoint (End of Week 1)

| Task | Expected State | Actual State |
|---|---|---|
| Suivi tab (list view) | In progress or done | _to be filled_ |
| Tracking code display | Done | _to be filled_ |
| Victim/Witness mode | Done | _to be filled_ |
| Report detail page | In progress | _to be filled_ |

---

## 3. Conduct Sprint Reviews and Retrospectives

### Sprint Review Format

At the end of each sprint, the team demonstrates completed features to stakeholders. Each demo follows this structure:

1. **Summary of completed tasks** vs. planned tasks.
2. **Live demo** of each completed feature on the emulator or a test device.
3. **Metrics review:** velocity, bug count, PR review time.
4. **Backlog update:** move incomplete tasks to the next sprint backlog.

---

### Sprint 1 Review — *(to be completed at end of Sprint 1)*

**Sprint Goal:** Complete the student-facing MVP experience.

| Task | Planned | Completed | Notes |
|---|---|---|---|
| Suivi tab | ✅ | _TBD_ | |
| Tracking code in dialog | ✅ | _TBD_ | |
| Victim/Witness mode | ✅ | _TBD_ | |
| Report detail page | ✅ | _TBD_ | |
| Pull-to-refresh | ✅ | _TBD_ | |
| Mood check-in widget | Optional | _TBD_ | |

**Velocity:** _X / Y tasks completed_

---

### Sprint 1 Retrospective — *(to be completed at end of Sprint 1)*

**What went well?**
- _To be filled by team_

**What didn't go well?**
- _To be filled by team_

**What will we improve for Sprint 2?**
- _To be filled by team_

---

### Sprint 2 Review — *(to be completed at end of Sprint 2)*

**Sprint Goal:** Deliver a working staff interface with report management.

| Task | Planned | Completed | Notes |
|---|---|---|---|
| Role-based routing on login | ✅ | _TBD_ | |
| Staff reports list | ✅ | _TBD_ | |
| Report detail (staff) | ✅ | _TBD_ | |
| Follow-up API endpoint | ✅ | _TBD_ | |
| Follow-up UI | ✅ | _TBD_ | |
| Report filters | ✅ | _TBD_ | |
| Admin user management | ✅ | _TBD_ | |
| Mood history chart | Optional | _TBD_ | |

**Velocity:** _X / Y tasks completed_

---

### Sprint 2 Retrospective — *(to be completed at end of Sprint 2)*

**What went well?**
- _To be filled by team_

**What didn't go well?**
- _To be filled by team_

**What will we improve for Sprint 3?**
- _To be filled by team_

---

### Sprint 3 Review — *(to be completed at end of Sprint 3)*

**Sprint Goal:** Validate the complete MVP through integration testing and fix all critical bugs.

| Task | Planned | Completed | Notes |
|---|---|---|---|
| End-to-end integration tests | ✅ | _TBD_ | |
| Critical bug fixes | ✅ | _TBD_ | |
| Final QA pass | ✅ | _TBD_ | |
| In-app notifications | ✅ | _TBD_ | |
| Mood history chart | ✅ | _TBD_ | |

**Velocity:** _X / Y tasks completed_

---

### Sprint 3 Retrospective — *(to be completed at end of Sprint 3)*

**What went well?**
- _To be filled by team_

**What didn't go well?**
- _To be filled by team_

**What would we do differently if starting over?**
- _To be filled by team_

---

## 4. Final Integration and QA Testing

### Integration Test Plan

The goal is to verify that the Flutter frontend, the Next.js backend, and the PostgreSQL database work together correctly end-to-end. All tests are performed against the staging environment.

---

### Test Suite 1 — Authentication Flow

| # | Test Case | Steps | Expected Result | Status |
|---|---|---|---|---|
| T1.1 | Student registers with valid school code | POST /api/auth/register with valid data | 200 OK, account created | _TBD_ |
| T1.2 | Student registers with invalid school code | POST with unknown `schoolCode` | 400 Bad Request | _TBD_ |
| T1.3 | Student logs in with correct credentials | POST /api/auth/login | 200 OK, JWT returned | _TBD_ |
| T1.4 | Student logs in with wrong password | POST /api/auth/login | 401 Unauthorized | _TBD_ |
| T1.5 | Staff logs in and is redirected to staff dashboard | Login with TEACHER role | Staff UI displayed | _TBD_ |

---

### Test Suite 2 — Report Submission

| # | Test Case | Steps | Expected Result | Status |
|---|---|---|---|---|
| T2.1 | Student submits a complete report | Fill all fields, tap submit | 201 Created, tracking code in dialog | _TBD_ |
| T2.2 | Student submits without selecting type | Leave type empty, tap submit | Validation error shown | _TBD_ |
| T2.3 | Student submits with description < 10 chars | Short description, tap submit | Validation error shown | _TBD_ |
| T2.4 | Report appears in Suivi tab after submission | Submit → navigate to Suivi | Report visible in list with PENDING status | _TBD_ |
| T2.5 | Tracking code matches database value | Submit report, check tracking code in dialog vs DB | Codes match | _TBD_ |
| T2.6 | FULLY_ANONYMOUS report hides author for staff | Submit with `FULLY_ANONYMOUS`, view as staff | Author name shows as "Anonyme" | _TBD_ |

---

### Test Suite 3 — Staff Interface

| # | Test Case | Steps | Expected Result | Status |
|---|---|---|---|---|
| T3.1 | Staff sees only reports from their school | Staff from School A logs in | No reports from School B visible | _TBD_ |
| T3.2 | Staff adds a follow-up and changes status | Open report detail, fill follow-up, submit | Status updates to IN_PROGRESS in list | _TBD_ |
| T3.3 | Student sees status update in Suivi tab | Staff updates status, student refreshes Suivi | New status reflected | _TBD_ |
| T3.4 | RECTORAT role sees reports targeted at RECTORAT only | Login as RECTORAT | Only RECTORAT-targeted reports visible | _TBD_ |

---

### Test Suite 4 — Security

| # | Test Case | Steps | Expected Result | Status |
|---|---|---|---|---|
| T4.1 | Unauthenticated access to protected route | GET /api/reports without Authorization header | 401 Unauthorized | _TBD_ |
| T4.2 | Student cannot access staff reports | GET /api/reports with STUDENT JWT | 403 Forbidden | _TBD_ |
| T4.3 | Staff cannot access reports from another school | Decode JWT, manually change `schoolCode` in request | Reports from other school not returned | _TBD_ |
| T4.4 | Error responses do not leak internal details | Trigger a 500 error on /api/schools | Response body contains only `{ "error": "Database error" }` | _TBD_ |

---

### Test Suite 5 — Mood Check-In

| # | Test Case | Steps | Expected Result | Status |
|---|---|---|---|---|
| T5.1 | Student submits a mood check-in | POST /api/mood with level 3 | 201 Created | _TBD_ |
| T5.2 | Mood level out of range is rejected | POST /api/mood with level 6 | 400 Bad Request | _TBD_ |
| T5.3 | Mood history chart shows last 7 days | GET /api/mood | Array of mood entries within 7-day window | _TBD_ |

---

### Bug Severity Classification

| Severity | Definition | Resolution Deadline |
|---|---|---|
| **Critical** | App crashes, data loss, security vulnerability | Same day |
| **High** | Feature broken, incorrect data displayed | Before next sprint |
| **Medium** | UI issue, non-critical flow broken | Best effort in current sprint |
| **Low** | Cosmetic, minor UX friction | Backlog |

---

## 5. Deliverables

> Links marked _"to be updated"_ will be added as the sprints progress.

| Deliverable | Link / Status |
|---|---|
| Source Repository | https://github.com/Alistair31/Portfolio-Project |
| Sprint 1 Review | _to be updated_ |
| Sprint 2 Review | _to be updated_ |
| Sprint 3 Review | _to be updated_ |
| Sprint 1 Retrospective | Sections 3 of this document — _to be filled_ |
| Sprint 2 Retrospective | Sections 3 of this document — _to be filled_ |
| Sprint 3 Retrospective | Sections 3 of this document — _to be filled_ |
| Sprint Planning | Section 0 of this document |
| Bug Tracking | `rapport_bugs.md` in the repository root |
| Testing Evidence | Section 4 of this document — _to be filled as tests are executed_ |
| Production Environment | _to be updated at deployment_ |
