<a id="readme-top"></a>


<h1 align=center><strong>Technical Documentation</strong></h1>

<details>
  <summary>Table of Contents</summary>
  <ul>
    <li><a href="#user-stories">User Stories</a></li>
    <li><a href="#mockups">Mockups</a></li>
	<li><a href="#architecture">Architecture</a></li>
	<li><a href="#structure">Structure</a></li>
	<li><a href="#sequence-diagram">Sequence Diagram</a></li>
	<li><a href="#api-specifications">API Specifications</a></li>
	<li><a href="#scm-and-qa-plans">SCM and QA Plans</a></li>
	<li><a href="#technical-justifications">Technical Justifications</a></li>
  </ul>
</details>

<p align="center">
    <img src="https://skillicons.dev/icons?i=flutter,nextjs,prisma,postgresql,nodejs">
</p>

<p align="center">
    <b>Flutter</b> • <b>Next.js</b> • <b>Prisma</b> • <b>PostgreSql</b> • <b>Node.js</b>
</p>

<h2 id="user-stories">User Stories</h2>

The user stories is there to briefly describe how an user will interact with the application.  
This can be separated in four categories following the MoSCoW method (Must have, Should have, Could have, Won’t have).  
<br>

<h3><strong>Must have</strong></h3>  

This section represent mandatory feature for the MVP:
<ul>
  <li>As a user, I want to be able to log in or out safely with my account.</li>
  <li>As a user, I want to access to the main feature easily.</li>
  <li>As a user, I want to post a testimony.</li>
  <li>As a user, I want to follow the post i have made.</li>
  <li>As a admin/staff, I want to retrieve testimonies for investigation.</li>
  <li>As a admin/staff, I want to access to a dashboard for data synthesis.</li>
  <li>As a admin/staff, I want to have access to all follow up.</li>
</ul>

<h3><strong>Should have</strong></h3>  

<ul>
  <li>As a user, I want to post a testimony as a witness.</li>
  <li>As a admin/staff, I want to have statistics on harassment.</li>
</ul>

<h3><strong>Could have</strong></h3>  

<ul>
  
</ul>

<h3><strong>Won’t have</strong></h3>  
  <li>As a user, I want to use a AI chatbot for helping me .</li>
<ul>
  
</ul>
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<h2 id="mockups">Mockups</h2>
PLACEHOLDER FIGMA
<iframe
  src="https://www.figma.com/embed?embed_host=share&url=TON_URL_FIGMA"
  width="100%"
  height="600"
  style="border: 0; border-radius: 12px;"
  allowfullscreen
  loading="lazy"
  title="Mockup Figma">
</iframe>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<h2 id="architecture">Architecture</h2>  


```mermaid
---
config:
  layout: fixed
---
flowchart TB
 subgraph BACKEND["Backend — Next.js API"]
        AUTH["Auth & Routing"]
        API["REST API"]
        ANON["Anonymization"]
  end
 subgraph s1["Frontend"]
        FLUTTER["📱 Flutter\nMobile App"]
        WEB["🌐 Next.js\nWeb Portal"]
  end
    FLUTTER -- login --> AUTH
    WEB -- login --> AUTH
    AUTH -- "role-based redirect" --> FLUTTER & WEB
    FLUTTER -- submit report --> ANON
    ANON -- anonymized --> API
    FLUTTER -- track report --> API
    WEB -- manage reports / stats --> API
    API -- read / write --> DB[("PostgreSQL\nvia Prisma")]
    FLUTTER <-- victim support --> CHATBOT(["🤖 AI Chatbot\n(optional)"])

    style s1 fill:#C8E6C9
    style BACKEND fill:#FFF9C4
```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<h2 id="structure">Structure</h2>

|Components            |Type|Description                                                                         |
|:---------------------|:---|:-----------------------------------------------------------------------------------|
|Login                 |Page|Users can login if they have credentials                                            |
|Home (User)           |Page|For students logged, access to features and follow up status (if any)               |
|Home (Admin)          |Page|For staff members logged, access to specific features and last report(or urgent one)|
|Report (User)         |Page|Students can post a report on incident they have been a victim or a witness         |
|Counter report (Admin)|Page|Staff members can post a follow up of the incident                                  |
|Issues tracker (User) |Page|Complete follow up of their own report                                              |
||||

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<h2 id="sequence-diagram">Sequence Diagram</h2>

For the users login:

```mermaid
sequenceDiagram
    participant User
    participant App
    participant AuthService
    participant Database

    User->>App: Opens app
    App->>App: Displays login screen
    User->>App: Enters credentials
    App->>AuthService: Sends login request
    AuthService->>Database: Queries user by email
    Database-->>AuthService: Returns user record
    AuthService->>AuthService: Validates password
    AuthService-->>App: Login successful
    App->>App: Stores session token
    App-->>User: Redirects to dashboard
```

For posting a report:

```mermaid
sequenceDiagram
    participant User
    participant App
    participant API
    participant Anonymization
    participant Database

    User->>App: Opens report page
    App-->>User: Displays report form
    User->>App: Fills form (type, gravity, anonymity level)
    User->>App: Submits report
    App->>API: POST /reports + anonymity level
    API->>Anonymization: Process report payload
    Anonymization->>Anonymization: Apply anonymity level (1 / 2 / 3)
    Anonymization-->>API: Anonymized report
    API->>Database: Store report via Prisma
    Database-->>API: Report saved + report id
    API-->>App: 201 Created + report id
    App-->>User: Confirmation + redirect to tracker
```

For an admin to get a report:

```mermaid
sequenceDiagram
    participant Admin
    participant App
    participant API
    participant Database

    Admin->>App: Opens reports dashboard
    App->>API: GET /admin/reports (JWT token)
    API->>API: Verify token + admin role
    API->>Database: Query all reports
    Database-->>API: Reports list
    API-->>App: 200 OK + reports list
    App-->>Admin: Displays reports list

    Admin->>App: Selects a report
    App->>API: GET /admin/reports/:id
    API->>Database: Query report by id
    Database-->>API: Report details
    API-->>App: 200 OK + report details
    App-->>Admin: Displays full report
```

For an admin to post a counter report after investigation:

```mermaid
sequenceDiagram
    participant Admin
    participant App
    participant API
    participant Database
    participant Student

    Admin->>App: Opens report + writes counter report
    Admin->>App: Fills investigation notes + new status
    App->>API: PATCH /admin/reports/:id
    API->>API: Verify token + admin role
    API->>Database: Update report (notes + status)
    Database-->>API: Report updated
    API->>Database: Create notification for student
    Database-->>API: Notification saved
    API-->>App: 200 OK
    App-->>Admin: Confirmation

    Database-->>Student: Push notification — report updated
    Student->>App: Opens tracker
    App->>API: GET /tracker/me
    API->>Database: Query student reports
    Database-->>API: Reports + updated status
    API-->>App: 200 OK + reports list
    App-->>Student: Displays updated report
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<h2 id="api-specifications">API Specifications</h2>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<h2 id="scm-and-qa-plans">SCM and QA Plans</h2>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<h2 id="technical-justifications">Technical Justifications</h2>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

