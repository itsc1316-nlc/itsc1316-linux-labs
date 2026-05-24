# Module 5 Lab: Linux Filesystem Management — Storage Monitoring (Multipass)

**Hands-on lab — runs on your own `labvm`. Replaces the former written assignment on filesystem usage.**

## Lab Overview

A disk that fills to 100% is one of the most common causes of a Linux server falling over: services stop, logs can't be written, and databases corrupt. A good administrator does not wait for that — they *monitor* storage, know how to read usage at both the filesystem and the directory level, and can quickly answer the question "what is eating my disk, and what should I do about it?" In this lab you investigate a system whose storage is being consumed by a planted "disk hog," locate the culprit using the standard monitoring tools, and write a short storage report with a recommendation — exactly the kind of triage an on-call admin does before touching anything.

|  |  |
| --- | --- |
| **Estimated Time** | 35–55 minutes |
| **Environment** | Your Multipass `labvm` (Ubuntu 22.04) |
| **Scripts** | `setup-storage.sh`, `check-storage.sh` (pulled into `labvm` from the public repo with curl — see Setup Guide) |
| **Deliverable** | A 60–90 second Zoom screen recording (webcam off) showing `check-storage.sh` passing, plus your written **storage report** (`~/module5-storage-report.txt`) |
| **Key Location** | `~/bigdata` |

## Outcomes

By the end of this lab you will be able to:

- Explain *why* storage monitoring is critical to system stability.
- Read and interpret filesystem usage with `df -h` and `df -hT` (which mount is root, how full it is, what filesystem type it uses).
- Compare filesystem-level reporting (`df`) with directory-level reporting (`du`) and decide which one answers a given question.
- Find the biggest space consumers under a directory and locate large files safely with `find -size`.
- Apply storage awareness to a real scenario and recommend an action **without recklessly deleting** system files.

---

## Start the Lab Environment

From your computer's terminal, start `labvm` and shell into it:

```
multipass start labvm
multipass shell labvm
```

Then **inside `labvm`**, pull this lab's two scripts straight from the public course repo, eyeball them, and build the scenario:

```
curl -fsSLO https://raw.githubusercontent.com/itsc1316-nlc/itsc1316-linux-labs/main/labs/module-05-storage-monitoring/setup-storage.sh
curl -fsSLO https://raw.githubusercontent.com/itsc1316-nlc/itsc1316-linux-labs/main/labs/module-05-storage-monitoring/check-storage.sh
bash setup-storage.sh
```

The setup script plants a realistic "disk hog" under your home directory: one large file and a directory packed with many small files. It does **not** require sudo and it does **not** touch any system files — everything it creates lives under `~/bigdata`. Re-running it is safe; it cleans up its old scenario first.

> **Tip — snapshot before you experiment.** This lab is read-only investigation, so it is low-risk, but snapshots are a good habit. From inside the VM type `exit`, then from your computer's terminal:
>
> ```
> multipass stop labvm
> multipass snapshot --name pre-mod05 labvm
> multipass start labvm
> multipass shell labvm
> ```

---

## The Scenario

A teammate messages you: *"The lab box feels low on space — can you take a look before it fills up?"* You have not been told where the problem is. Your job is to investigate with the monitoring tools, identify what is consuming the space, and recommend an action — all documented in a short report. You are creating that report file as you go, so most steps end with you appending real output from *your* VM into `~/module5-storage-report.txt`.

A quick way to start the report and stamp it with your identity:

```
hostname > ~/module5-storage-report.txt
echo "Investigator: <your name>" >> ~/module5-storage-report.txt
echo "Date: $(date)" >> ~/module5-storage-report.txt
```

(The check looks for your VM's real hostname on the first line, so use the command above rather than typing it by hand.)

## Instructions

**1. Read filesystem usage with `df`.**
Run `df -h` and then `df -hT`. Find the line for the **root filesystem** (`/`). Note how full it is (the `Use%` column), how much is free, and — from `df -hT` — what **filesystem type** it is (on Ubuntu Multipass this is typically `ext4`). Append the output to your report:

```
echo "=== df -hT ===" >> ~/module5-storage-report.txt
df -hT >> ~/module5-storage-report.txt
```

> **Why `df`?** `df` reports usage *per mounted filesystem*. It answers "is my disk about to fill up?" — but it does **not** tell you *which directory* is responsible. That is the next step.

**2. Compare `df` (filesystem) with `du` (directories).**
`du` measures how much space *directories and files* use. Run `du -sh` on a few directories to feel the difference, then find the biggest consumers inside your home directory:

```
du -sh ~/bigdata
du -h --max-depth=1 ~ | sort -h
```

The `sort -h` puts the largest consumers at the bottom. Append the ranked list to your report:

```
echo "=== du -h --max-depth=1 ~ (sorted) ===" >> ~/module5-storage-report.txt
du -h --max-depth=1 ~ | sort -h >> ~/module5-storage-report.txt
```

> **Why both tools?** `df` finds *that* a filesystem is filling up; `du` finds *what inside it* is responsible. A real admin moves from `df` (the alarm) to `du` (the diagnosis).

**3. Locate the single large file with `find`.**
Inside `~/bigdata` the setup planted one deliberately large file. Use `find` with `-size` to locate files larger than 100 MB, and check its exact size with `du -h` or `ls -lh`:

```
find ~ -type f -size +100M 2>/dev/null
```

> If `find` returns nothing, you may have skipped `bash setup-storage.sh` — go back and run it. Also: `-size +100M` is a strict comparison, so `+200M` would NOT find the planted 200M file.

Record the **path and size** of the large file you found into your report:

```
echo "=== Large file located ===" >> ~/module5-storage-report.txt
find ~ -type f -size +100M -exec du -h {} \; 2>/dev/null >> ~/module5-storage-report.txt
```

> **Why inspect before deleting?** A 200 MB file might be a forgotten download — or it might be a database or a backup someone needs. `find` *locates*; it does not *judge*. The admin's job is to identify the owner and purpose before removing anything.

**4. Account for the many-small-files directory.**
The setup also created `~/bigdata/manyfiles/` containing a large *number* of small files. Notice that `du -sh ~/bigdata/manyfiles` may report a meaningful size even though no single file is large — lots of small files (and the inodes/blocks they consume) add up. Count them and append a note:

```
echo "=== Small-file directory ===" >> ~/module5-storage-report.txt
echo "File count in ~/bigdata/manyfiles: $(find ~/bigdata/manyfiles -type f | wc -l)" >> ~/module5-storage-report.txt
du -sh ~/bigdata/manyfiles >> ~/module5-storage-report.txt
```

> **Why this matters:** `df` could show a filesystem filling up with no obvious "big file" in sight. Sometimes the cause is *thousands* of small files (logs, cache, mail spools). Knowing to check counts as well as sizes is part of reading storage correctly.

**5. Write the storage report + recommendation.**
Finish `~/module5-storage-report.txt` with your written analysis and reflection. In your own words you will:

- State **what is consuming the space** (name the large file and the small-file directory).
- State **what you would check next** before acting (e.g. who owns it, when it was last modified, whether anything depends on it).
- Give a **recommended action** — and explicitly note that you would **not** delete system files blindly. (You are writing a recommendation, not running `rm` on anything system-critical.)

Open the report with `nano ~/module5-storage-report.txt` (save with **Ctrl+O** then **Enter**, exit with **Ctrl+X** — see [Setup Guide Part 5](../../docs/01-multipass-setup-guide.md) for the Mac-vs-Windows keystroke note). Scroll to the bottom and paste the block below, then replace **every angle-bracket placeholder** (`<your answer>`, `<name the large file...>`, etc.) with your real content. The check requires the three `===` section headers below and rejects any leftover `<...>` placeholder.

```
=== ANALYSIS & RECOMMENDATION ===
WHAT IS CONSUMING SPACE:
<name the large file and the small-file directory, with sizes from your VM>

WHAT I WOULD CHECK NEXT:
<who owns it / last modified / dependencies — before removing anything>

RECOMMENDED ACTION:
<your recommendation; note that you would NOT delete system files blindly>

=== REFLECTION ===
1. df vs du in a real scenario
   Describe a real situation where `df` would tell you the disk is nearly
   full but `du` on your home directory would show NOTHING large. Where
   else would you look?
   <your answer>

2. Before deleting a large file
   The large file the setup planted is 200 MB. Before deleting ANY large
   file you find on a production server, name TWO things you would verify
   first, and explain what could go wrong if you skipped them.
   <your answer>
```

---

## Evaluation (Required)

Grade your own work by running the check script inside the VM:

```
bash check-storage.sh
```

It prints PASS or FAIL for each requirement. Correct any FAILs and run it again until everything passes. This is exactly what a real administrator does: investigate, document, re-verify.

---

## Submission Requirement

Submit **two things** to Canvas:

1. A **60–90 second screen recording** made per the [Screen Recording Guide](../../docs/05-screen-recording-guide.md) (Alamo Zoom by default; one specific backup per OS if Zoom is broken) (webcam off; narration optional), showing in one continuous take: `hostname`, `whoami`, and `bash check-storage.sh` passing. Submit the **Zoom Cloud link** if available (otherwise the `.mp4`); keep your own copy for a possible portfolio.
2. Your completed **`~/module5-storage-report.txt`** — the captured `df`/`du`/`find` output *and* the analysis + reflection appended at the bottom. This is where your reasoning lives, so the recording does not need narration. (Copy it out of the VM with `multipass transfer labvm:/home/ubuntu/module5-storage-report.txt .` from your computer's terminal.)

> **AI policy for this lab: AI-OPEN.** You may ask an AI assistant to explain `df`, `du`, `find -size`, or `sort -h`, but include a one-line note of what you asked and what you verified yourself. An AI cannot see *your* VM's real `df` output or the exact size and path of the file the setup planted on *your* machine — those numbers, and the recommendation built on them, must come from your own investigation.

---

## Finish / Clean Up

You can leave the scenario in place. To free up resources between sessions without losing your work:

```
multipass stop labvm
```

If you want to reclaim the space the scenario used, you may remove the planted data — it is all under your home directory and safe to delete:

```
rm -rf ~/bigdata
```

Do **not** delete `labvm` — later labs reuse it.

---

## Final Checklist

- [ ] Ran `setup-storage.sh` to plant the disk-hog scenario
- [ ] Started `~/module5-storage-report.txt` with `hostname` on the first line
- [ ] Captured `df -hT` output and identified the root filesystem, its fullness, and its type
- [ ] Captured a sorted `du --max-depth=1 ~` listing of the biggest consumers
- [ ] Located the large file with `find -size` and recorded its path and size
- [ ] Recorded the count and size of the many-small-files directory
- [ ] Wrote the analysis + recommendation with no remaining `<...>` placeholders
- [ ] Ran `check-storage.sh` and all checks PASS
- [ ] Recorded the Zoom screen recording (webcam off; hostname + whoami + passing check)
- [ ] Wrote answers to both reflection questions
- [ ] Submitted screencast + storage report + reflection answers to Canvas

---

### On RHEL this would be…

`df`, `du`, `find`, and `sort` are core Linux tools and behave **identically** on Red Hat–family systems (RHEL, Rocky, Fedora). Two differences worth knowing for a certification exam: RHEL installations frequently use **XFS** as the default root filesystem rather than Ubuntu's `ext4` (you would see `xfs` in the `df -hT` `Type` column), and RHEL servers commonly use **LVM**, so a "disk full" problem there might be solved by *growing* a logical volume (`lvextend` + `xfs_growfs`) rather than only by deleting files. The monitoring workflow — `df` to spot it, `du` to diagnose it, `find` to locate it, verify before you delete — is the same everywhere.
