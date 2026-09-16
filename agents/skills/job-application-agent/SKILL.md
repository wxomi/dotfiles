---
name: job-application-agent
description: Apply to jobs on the user's behalf from one or more job links using Browser Use and a saved Anshul.md profile as the only source of personal details. Use when the user asks Codex to apply for jobs, fill job application forms, submit applications, answer employer screening questions, reuse saved personal/career details, or maintain a job-application memory file. The skill must ask the user for any required answer that is not explicitly available in Anshul.md and must not invent or assume personal, legal, salary, availability, authorization, demographic, disability, veteran, sponsorship, relocation, or background-check information.
---

# Job Application Agent

## Operating Rule

Apply only with facts present in `Anshul.md` or explicitly supplied by the user in the current conversation. Do not infer missing personal details, preferences, legal answers, eligibility answers, salary numbers, dates, or screening-question responses.

## Profile File

Use `/Users/anshulsaini/.codex/skills/job-application-agent/references/Anshul.md` as the canonical profile and memory file.

Before applying:

1. Read `Anshul.md`.
2. If the file is missing, create it from `references/Anshul.template.md`.
3. Treat empty fields, placeholders, and ambiguous notes as unknown.
4. When the user answers a missing question, update `Anshul.md` immediately so future applications do not ask again.

## Workflow

1. Parse the user's job links and process one application at a time.
2. Open each link with Browser Use. Prefer the browser-use plugin for navigation, inspection, clicking, typing, file upload, and screenshots.
3. Identify the company, role title, location, job description, required fields, required attachments, screening questions, and final submit behavior.
4. Map form fields to `Anshul.md` facts exactly. Use the closest explicit value only when the meaning is unambiguous.
5. Stop and ask the user when a required question has no exact saved answer. Ask concise questions grouped by application, and clearly name the company/role and field label.
6. After receiving answers, write them into the relevant section of `Anshul.md`, then continue.
7. Do not submit the final application until either:
   - the user explicitly asked to fully submit applications without per-application review, or
   - the user confirms the final review step for that application.
8. After submission, record the application in the `Application Log` section of `Anshul.md`.

## Browser Behavior

Use Browser Use for all job-site interactions. If a site requires login, MFA, captcha, payment, phone verification, or manual identity confirmation, pause and ask the user to complete that step or provide direction.

Do not bypass anti-bot controls, captchas, account security, paywalls, or terms-gated flows. Do not create new accounts unless the user explicitly asks and provides the required account details.

## Answering Rules

Use exact saved values for:

- Name, email, phone, location, links, and work history.
- Resume, cover letter, portfolio, GitHub, LinkedIn, and website paths.
- Work authorization, sponsorship, visa, relocation, notice period, and availability.
- Salary expectations and compensation preferences.
- Education, certifications, skills, and years of experience.
- Diversity, disability, veteran, gender, race, caste, background-check, and legal declarations.

If a form asks for a generated short answer or cover-letter-style response:

1. Draft using only verified facts from `Anshul.md` and the job description.
2. Keep the response concise and role-specific.
3. Ask for approval before submitting if the answer contains new positioning, claims, or subjective preferences not already saved.

## Missing Information Protocol

When required information is missing, ask in this format:

```text
I need these saved before I can continue with <company> - <role>:
1. <Exact field/question label> - <why it is required>
2. <Exact field/question label> - <why it is required>
```

After the user answers, update `Anshul.md` with:

- The exact question label if it is a screening question.
- The user's exact answer unless normalization is clearly mechanical.
- The date the answer was added when useful for future review.

## Review And Submission

Before final submit, provide a compact review:

- Company and role.
- Job link.
- Attachments selected.
- Notable screening answers.
- Any answers newly added to `Anshul.md`.
- Any fields left blank because they were optional.

Ask for confirmation unless the user explicitly authorized direct submission for the whole batch.

## Application Log

After applying, append a log entry to `Anshul.md` with:

- Date.
- Company.
- Role.
- Job URL.
- Status: submitted, blocked, needs user action, or skipped.
- Portal/account used if relevant.
- Notes about confirmation number or email if visible.

## Failure Handling

If an application cannot be completed, report the blocker and preserve progress. Do not guess answers just to get past a form. If a site loses progress, summarize the fields already filled and the exact next manual action needed.
