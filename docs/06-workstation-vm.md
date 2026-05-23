# Workstation VM (Optional — for the Portfolio/Git Track)

> **You only need this VM if you're doing the [GitHub Primer](03-github-primer.md) + [PORTFOLIO.md](../PORTFOLIO.md) track.** The labs themselves run entirely inside `labvm` and fetch their scripts from this public repo with `curl` — no git or `gh` required.

If you've decided to keep your work in a personal GitHub repo (recommended for resume/portfolio purposes — see [PORTFOLIO.md](../PORTFOLIO.md)), do this setup once in the first week. Every student on the portfolio track does the git/SSH work inside the same pre-built **workstation** VM, regardless of whether their laptop is macOS, Windows, or Linux. The only thing that lives on your laptop is **Multipass** (for managing the VMs) and a terminal.

> **Why a separate workstation VM?** Because the tools the portfolio track needs (`git`, `gh`, `ssh-keygen`, `scp`, `nano`, etc.) install differently — and sometimes badly — on every host OS. Workstation comes up the same way, with the same tools at the same paths, every time.

---

## The optional two-VM model

If you're on the portfolio track, this course uses **two Multipass VMs** that play different roles:

| VM | Role | What you do there |
| --- | --- | --- |
| **`labvm`** | Lab target (required) | Run lab `setup-*.sh` / `check-*.sh` scripts, do the actual exercises (fetched with `curl`) |
| **`workstation`** | Dev box (optional) | Edit files, configure git, run `gh`, commit your notes/writeups, `ssh`/`scp` if a lab calls for it |

A few labs add a third VM (Module 13-adv adds `fileserver`; Module 13-cloud adds `cloudvm`). Workstation, if you launched it, is always there with the same tools.

> **You only run Multipass commands on your host computer.** Inside any VM, there's no Multipass — that's a host concept. The workstation VM does *not* manage other VMs; it just gives you a uniform place to run developer tools.

---

## Part 1 — Launch the workstation VM (once)

This is a one-time setup. After this, you'll just `multipass shell workstation` to enter it.

From your computer's terminal, fetch the cloud-init straight from the course repo and feed it to Multipass via stdin — this works on macOS, Linux, and PowerShell with no per-OS line-continuation quirks:

```
curl -fsSL https://raw.githubusercontent.com/opseval/itsc1316-linux-labs/main/scripts/workstation/cloud-init.yaml | multipass launch 22.04 --name workstation --cpus 1 --memory 1G --disk 5G --cloud-init -
```

(Equivalent single-line form: `multipass launch 22.04 --name workstation --cpus 1 --memory 1G --disk 5G --cloud-init https://raw.githubusercontent.com/opseval/itsc1316-linux-labs/main/scripts/workstation/cloud-init.yaml`.)

This downloads Ubuntu 22.04 LTS (the first time) and runs cloud-init on first boot — installing `git`, `gh`, `ssh-keygen`, `scp`, `nano`, `vim`, `curl`, and the GitHub CLI keyring. Total time on a typical connection: 2–4 minutes.

Confirm both VMs are up:

```
multipass list
```

You should see `workstation` and `labvm`, each `Running` with an IP.

Enter your workstation:

```
multipass shell workstation
```

Your prompt changes to `ubuntu@workstation:~$`. You're inside. From here on, almost everything you do for the portfolio track — git, gh, editing your notes files, committing — happens here.

> **Wait for cloud-init.** If you opened a shell immediately after launching and packages aren't there yet (e.g., `gh --version` says "command not found"), wait 30 seconds and try again. You can also check `cloud-init status --long` to see if first-boot setup is finished.

---

## Part 2 — First-time configuration inside workstation

Run these **inside workstation** (after `multipass shell workstation`).

### Configure git identity

```
git config --global user.name "Your Real Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

Use the same email you'll use on GitHub.

### Log in to the GitHub CLI

```
gh auth login
```

Pick:
- **GitHub.com**
- **HTTPS**
- **Yes, authenticate Git with your GitHub credentials**
- **Login with a web browser**

It will print a code and a URL. **Copy the URL and open it in your laptop's browser** (workstation has no GUI). Paste the code, click Authorize. The CLI will detect it and finish login.

Verify:

```
gh auth status
```

### Clone your portfolio repo

(Walked through fully in the [GitHub Primer](03-github-primer.md). The short version, inside workstation:)

```
gh repo clone YOUR-USERNAME/itsc1316-labs-yourname
cd itsc1316-labs-yourname
```

You're now ready to keep your notes and writeups in git. The cloned repo lives at `/home/ubuntu/itsc1316-labs-yourname/` inside workstation. **This is your portfolio workspace, not where the labs run** — the lab scripts themselves are pulled into `labvm` with `curl` (see the [Setup Guide](01-multipass-setup-guide.md)).

---

## Part 3 — Reaching `labvm` from workstation (one-time SSH bootstrap)

**Do this in the first week, before any lab.** Every lab from Module 1 onward assumes workstation can `scp` and `ssh` into `labvm`. Multipass puts every VM on the same virtual network, so the connection itself works — but Multipass only authorizes *its own* daemon key on each VM, not workstation's. You have to authorize workstation's key on `labvm` once, then everything else (scp/ssh from workstation) just works.

This is a three-step handshake. Two short commands run on your host because that's where `multipass` lives; one runs inside workstation.

### Step 1 — Inside workstation, generate an SSH key

```
multipass shell workstation
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

(`-N ""` skips the passphrase prompt, which is fine for a lab VM.) Confirm the key exists:

```
ls ~/.ssh/id_ed25519*
```

You should see `id_ed25519` (private) and `id_ed25519.pub` (public).

### Step 2 — From your host terminal, stage workstation's public key on labvm

Open a **second** terminal on your host computer (leave the workstation shell open in the first one). The host is where `multipass` lives, so this is where the file-staging happens. Multipass does **not** support direct VM-to-VM transfers — you have to copy the key out of workstation to your host, then push the host's temp file into labvm:

```
multipass transfer workstation:/home/ubuntu/.ssh/id_ed25519.pub /tmp/ws.pub
multipass transfer /tmp/ws.pub labvm:/tmp/ws.pub
multipass exec labvm -- bash -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat /tmp/ws.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && rm /tmp/ws.pub'
rm /tmp/ws.pub
```

### Step 3 — Get labvm's IP and verify SSH works

Still in your host terminal, look up labvm's IP:

```
multipass list
```

Copy labvm's IPv4 address (it looks like `10.x.x.x`). Then back in your workstation shell, paste it in:

```
ssh ubuntu@10.x.x.x        # replace with your real labvm IP
```

You should land in `ubuntu@labvm:~$` with no password prompt. Type `exit` to return to workstation.

> **Keep that IP handy.** Multipass assigns it from DHCP on the same private subnet, and it stays the same as long as labvm isn't deleted/recreated — but if you ever can't connect, your first step is `multipass list` from your host to confirm the IP hasn't changed. The pattern for every lab is: get the IP once at the start of your session, paste it into your scp/ssh commands.

> **Why bootstrap from the host?** Multipass adds *its own* daemon key to each VM but doesn't trust workstation's key — workstation isn't a Multipass-managed identity, just another VM. The host-side `multipass transfer` + `multipass exec` is the one-time handshake; after that, workstation talks to lab VMs over plain SSH.

> **If you launch `fileserver` (Module 13-adv) or `cloudvm` (Module 13-cloud) later**, repeat Step 2 and Step 3 against that VM name. The key in workstation is already created; you only need to authorize it on each new target.

---

## Part 4 — Daily workflow with the portfolio track

If you're using workstation, here's the end-to-end pattern for one lab:

```
# On your HOST computer's terminal:
multipass start labvm workstation        # if either is stopped

# === Do the lab in labvm (same as non-portfolio students) ===
multipass shell labvm
# inside labvm:
curl -fsSLO https://raw.githubusercontent.com/opseval/itsc1316-linux-labs/main/labs/module-XX/setup-NAME.sh
curl -fsSLO https://raw.githubusercontent.com/opseval/itsc1316-linux-labs/main/labs/module-XX/check-NAME.sh
sudo bash setup-NAME.sh                   # see per-lab README for sudo / no-sudo
# ...fix things, edit notes/report file with `nano`...
bash check-NAME.sh                        # or `sudo bash check-NAME.sh` per the README
exit                                       # back to host

# === Get your notes/writeup file off labvm so you can commit it ===
# From your HOST terminal:
multipass transfer labvm:/home/ubuntu/moduleXX-notes.txt /tmp/moduleXX-notes.txt
multipass transfer /tmp/moduleXX-notes.txt workstation:/home/ubuntu/itsc1316-labs-yourname/labs/module-XX/
rm /tmp/moduleXX-notes.txt

# === Commit your work from workstation ===
multipass shell workstation
cd ~/itsc1316-labs-yourname
git status
git add labs/module-XX/moduleXX-notes.txt PORTFOLIO.md
git commit -m "Module XX: notes + portfolio entry"
git push

# === On your HOST: record your screen showing labvm's final check run ===
# (see docs/05-screen-recording-guide.md), then upload the recording + notes to Canvas.
```

The host gets used for: launching/stopping VMs, ferrying the notes file between labvm and workstation, and screen recording. The lab itself runs entirely inside `labvm`; workstation is purely the git/portfolio surface.

> **Non-portfolio students** skip the workstation steps entirely and just upload the notes file directly from host: `multipass transfer labvm:/home/ubuntu/moduleXX-notes.txt .` then attach it to the Canvas submission.

---

## Part 5 — Resource sizing & turning workstation off

Workstation is small (1 CPU, 1 GB RAM, 5 GB disk). Even with `workstation` + `labvm` + `fileserver` all running at once (the Module 13-adv setup), total memory pressure is around 4 GB — comfortable on any laptop with 8 GB RAM.

When you're done for the session, stop both to free resources:

```
multipass stop workstation labvm
```

The next session: `multipass start workstation labvm && multipass shell workstation`.

> **Don't delete `workstation`** until the course is over. Your cloned repo, your SSH keys, and your `gh` authentication all live inside it — recreating that takes 20 minutes.

---

## Part 6 — When things go wrong

| Symptom | Fix |
| --- | --- |
| `multipass launch --cloud-init https://...` fails to fetch the URL | Pipe the file in instead: `curl -fsSL <url> \| multipass launch ... --cloud-init -`. Some older Multipass builds don't follow HTTPS for `--cloud-init`. |
| `gh: command not found` inside workstation right after launch | cloud-init is still finishing. Wait 30s and try again, or check `cloud-init status --long`. |
| `ssh: connect to host labvm port 22: Connection refused` from workstation | Did you do the Part 3 bootstrap from the host? Without it, workstation can't authenticate to labvm. |
| `getent hosts labvm` returns nothing inside workstation | Multipass VMs aren't auto-registered as DNS names. Use the IP from `multipass list` (from host) directly: `ssh ubuntu@10.x.x.x`. |
| Workstation VM stuck in `Starting` after a host sleep | Same fix as labvm: `multipass stop workstation && multipass start workstation`. See [Multipass Troubleshooting Guide](02-multipass-troubleshooting.md). |
| I need to rebuild workstation from scratch | `multipass delete --purge workstation` then re-run the launch command. You'll lose your cloned repo and gh auth — back up anything important first. |

If something here doesn't cover it, the [Multipass Troubleshooting Guide](02-multipass-troubleshooting.md) applies to workstation exactly the same way it applies to labvm.

---

## Why this is optional (the design rationale, for the curious)

The labs themselves don't need this VM — they fetch every script directly from this public repo into `labvm` with `curl`, so the host OS difference (Windows / macOS / Linux) never matters. That keeps the on-ramp for the labs themselves as small as possible: install Multipass, launch one VM, follow the README.

The portfolio track is a different shape of work — `git`, `gh`, an editor, SSH keys — and there `brew install` on macOS, `winget` on Windows, `apt`/`dnf` on Linux each have their own gotchas, path quirks, and line-ending traps. **For students who want a portfolio**, an optional workstation VM costs one extra `multipass launch` and ~1 GB of RAM, and in return:

- Every portfolio-track student sees the same prompt, the same tools, the same paths.
- The instructor's git/gh demos work for everyone byte-for-byte.
- A working SSH/git/gh stack is one `multipass launch` away from any laptop that can run Multipass at all.
- You build the "host is for managing VMs; real work happens in a VM" mental model that real cloud admins live in.

Students who don't want a portfolio just skip the whole thing.
