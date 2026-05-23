# Grading Rubric (All Labs)

This is the **single rubric** every lab in this course is graded against. It is intentionally short, specific, and observable: each level is something the grader can verify in seconds, and you can self-grade yourself against the same words before you submit.

> **For students.** If a level says "all four `<...>` placeholders replaced," that means: open the file, search for `<`, see if any remain. Not "looks good." If you can't tell yourself which level you're at, ask in the Q&A board before the deadline.
>
> **For graders.** Use these exact levels. If a submission falls between two levels, score the lower one and note in the comment which criterion's wording isn't met. Don't invent intermediate levels.

---

## How scoring works

Every lab has **4 criteria**, each scored on a **0–3 scale** (4 levels). Maximum raw score is **12 / 12**.

| Criterion | Weight |
| --- | --- |
| 1 — Check Script Results | × 3 |
| 2 — Screen Recording | × 2 |
| 3 — Written Component | × 4 |
| 4 — Submission Hygiene & Integrity | × 3 |

Weighted total out of **36**, which is then scaled to the Canvas point value for that lab. The capstone (Module 15) is the only exception — see the **Capstone overrides** at the bottom.

> The Written Component is weighted highest on purpose: **a passing check script with no reasoning is not learning.** The recording proves the work happened on your machine; the writeup proves you understood it.

---

## Criterion 1 — Check Script Results

What the grader runs: opens your screen recording and looks at the `check-*.sh` output.

| Score | Standard (objective — count the FAILs) |
| --- | --- |
| **3** | The check script ran to completion and **every check is PASS** (zero FAIL lines). |
| **2** | One single FAIL line, **everything else PASS**. (Near-complete.) |
| **1** | Two or more FAILs, but at least one PASS. (Substantial attempt.) |
| **0** | The check script wasn't run, the recording doesn't show its output, or every check FAILed. |

---

## Criterion 2 — Screen Recording

What the grader looks for: a single recording file or link in the Canvas submission.

| Score | Standard (all conditions must hold for the higher score) |
| --- | --- |
| **3** | One continuous take recorded with the lab's primary or backup tool (see [Screen Recording Guide](05-screen-recording-guide.md)); the recording **shows, on screen**, the output of `hostname`, the output of `whoami`, and the `check-*.sh` run with its final PASS lines. |
| **2** | All three on-screen items above are present, but the take is stitched/edited together OR one of the three (`hostname` or `whoami`) is missing. |
| **1** | A recording is present but the `check-*.sh` PASS lines aren't visible on screen, OR it was made with a tool not listed in the Screen Recording Guide, OR it is so short / fragmented the grader can't follow the work. |
| **0** | No recording submitted, the link is broken or restricted, or the file is unreadable. |

> **Why "on screen, in the recording"?** Anyone can paste check output into a text file. The point of the recording is that the check script ran *on your machine, just now*, with *your* hostname.

---

## Criterion 3 — Written Component

What "written component" means depends on the lab: a written reflection (M1, M6), a report file (M2, M3, M5, M9, M10, M11, M12, M15), a writeup (M13-adv, M13-cloud), or an incident report (M14). Every lab's README spells out its specific written deliverable; this criterion grades whatever that lab requires.

| Score | Standard |
| --- | --- |
| **3** | All required sections present; **zero `<...>` placeholders or `TODO`/`FIXME` markers remain**; the answers reference the student's own evidence (real hostname, real IP, real output) rather than generic descriptions; each required question is answered in its own complete sentences. |
| **2** | All sections present and placeholders replaced, **but** reasoning is shallow (one-line answers where multi-sentence is asked for) OR one section uses generic prose instead of evidence from the student's own VM. |
| **1** | The component was submitted but is **missing one or more required sections**, OR contains leftover `<placeholder>` text, OR is just pasted command output with no written explanation. |
| **0** | The written component is missing entirely. |

> The check scripts already verify "no placeholders left, hostname appears, sections exist" mechanically — so a level-3 written component is essentially: passes the check, *plus* the prose sounds like a person who did the work, not a person typing what they think the grader wants to read.

---

## Criterion 4 — Submission Hygiene & Integrity

What the grader looks at: the Canvas submission as a whole, plus any AI disclosure.

| Score | Standard |
| --- | --- |
| **3** | All required artifacts (recording + written component, per the lab's "Submission Requirement" block) are attached; if the lab is **AI-OPEN** or **AI-REQUIRED**, a one-line AI-use disclosure is included; submission is on time. |
| **2** | All artifacts attached, **but** missing the AI disclosure (when required), OR submitted late but within the lab's stated grace window. |
| **1** | One required artifact is missing (e.g. the writeup was submitted but no recording was attached). |
| **0** | More than one artifact is missing, **OR** there is evidence of an academic-integrity violation — the recording shows a different machine than the writeup describes, the hostname in the report doesn't match the one in the recording, identical text was submitted by multiple students, or the recording was reused from another semester. Academic-integrity violations are **always a 0**; they do not partial-credit. |

> **AI disclosure expectation, in one line:** "Used <tool> to <ask what>; verified <how> on my own VM." That's the whole bar. The check scripts make most AI shortcuts visible anyway (the hostname / kernel / IP cannot be faked), but the disclosure is what the academic-integrity scoring relies on. If the lab is **AI-FREE**, no disclosure is needed (and AI use is itself the violation).

---

## Capstone overrides (Module 15 only)

The capstone is worth more and grades reasoning heaviest:

| Criterion | Weight |
| --- | --- |
| 1 — Check Script Results | × 4 |
| 2 — Screen Recording | × 2 |
| 3 — Written Component (Handover Report) | × 6 |
| 4 — Submission Hygiene & Integrity | × 3 |

Weighted total out of **45**. Otherwise the level definitions above apply unchanged — the handover report just has more written sections (State Found / Actions Taken / Disk Usage / Network / Reasoning / What I'd Check Next).

---

## Worked example — Module 6 submission

A student submits:
- A Zoom Cloud link, 78 seconds, continuous take, shows `hostname` → `whoami` → `bash check-users.sh` ending in "Passed: 4  Failed: 0".
- A text file with both reflection questions answered, ~3 sentences each, no `<...>` placeholders, references "avery" by name.
- Attached on Canvas before the deadline.
- The lab is AI-OPEN; the student included: "Asked Claude to explain the difference between 660 and 640 for the file mode; verified by running `sudo su - avery` and trying to edit `meeting-highlights.txt` myself."

Grading:
- Criterion 1: **3** (all PASS).
- Criterion 2: **3** (continuous take with hostname/whoami/passing check visible).
- Criterion 3: **3** (both sections present, no placeholders, references real lab evidence).
- Criterion 4: **3** (all artifacts, AI disclosure present, on time).

Score: (3·3) + (3·2) + (3·4) + (3·3) = **36 / 36**. Scaled to whatever the lab is worth in Canvas.

---

## How to self-grade before you submit

Run through these in order; if you can't say "yes" to all of them, fix the gap first:

- [ ] **Crit 1.** I just ran `bash check-*.sh` (or `sudo bash check-*.sh` if the lab says so) and saw **0 FAILs**.
- [ ] **Crit 2.** My recording is a single continuous take. In it you can see `hostname`, `whoami`, and the check ending in PASS — all without me pausing or editing.
- [ ] **Crit 3.** My written file has every section the lab asked for, zero `<...>` placeholders, and at least one reference to my own VM's specific output (hostname, IP, file path, etc.).
- [ ] **Crit 4.** I attached both the recording (or link) and the written file. If AI was permitted and I used it, I added the one-line disclosure.

If all four are checked, you'd give yourself a 12 / 12. The grader will too.
