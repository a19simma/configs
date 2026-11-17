---
name: secrets
description: Store, use and verify credentials with fnox, mise exec and premade mise tasks. Use when a command needs a token, password or key, when a user pastes a secret, or when adding a recurring authenticated command to a repo.
---

# Secrets

A secret lives encrypted in the repo that uses it. A command that needs one runs through `fnox exec --`, so fnox injects the value into that process only. Prefix `mise exec --` to get the repo's pinned fnox. Each recurring command gets a premade `mise` task, and agents run the task.

Facts come from fnox docs ([age provider](https://fnox.jdx.dev/providers/age), [fnox set](https://fnox.jdx.dev/cli/set), [fnox exec](https://fnox.jdx.dev/cli/exec), [mise integration](https://fnox.jdx.dev/guide/mise-integration)) and from the run that proved them (fnox 1.35.2). Recheck a flag with `fnox <cmd> --help` before relying on it.

## Rules

- Keep secret values inside fnox. A value never appears in a file, a commit, an `export`, a subagent brief or a task body.
- Name a secret by its variable and a task by its name, in every brief and report.
- Report a missing secret to the user. Leave `~/.config/fnox/age.txt`, `~/.ssh` private keys, `.env` files and `fnox get`, `fnox list --values`, `fnox export` unread and unrun.
- Task bodies read the variable and never echo it.
- A secret shown in a chat or log is burned: tell the user to revoke and reissue it once the work is done.

## Set up a repo

Pick one identity. Both give a `fnox.toml` that is safe to commit, since it holds public recipients and ciphertext.

**SSH key** (no new key file): the user's `~/.ssh/id_ed25519.pub` is the recipient. fnox does not fall back to `~/.ssh` on its own, so name the private key with `key_file` inside the provider table. Put the line directly under `recipients`: a line appended to the end of the file lands in `[secrets]` and fails to parse. A passphrase-protected SSH key is unsupported.

```toml
default_provider = "age"

[providers.age]
type = "age"
recipients = ["ssh-ed25519 AAAA..."]
key_file = "~/.ssh/id_ed25519"
```

**Age key**: the user runs `! age-keygen -o ~/.config/fnox/age.txt` and shares the printed `age1...` public key. fnox then needs no `key_file`. Use this when the SSH key has a passphrase.

Done when `mise exec -- fnox list` loads the file and `fnox.toml` names one recipient.

## Add a secret

`fnox set NAME` reads a hidden prompt, or piped stdin with surrounding whitespace trimmed. No `--stdin` flag exists.

- User-typed: `! fnox set NAME` in the session.
- User pasted the value and asked the agent to store it: pipe it on stdin and pass the output through `sed` to redact it. The value is already in the transcript, so tell the user to rotate it.

```sh
printf '%s' "$VALUE" | mise exec -- fnox set NAME
```

After any `fnox set`, check that the new entry in `fnox.toml` carries `value =`. With fnox 1.35.2, `printf v | mise exec -- fnox set NAME -d desc` stored an entry with only a description. A non-secret value, such as a URL, goes in as an argument: `fnox set NAME <value>`.

## Verify

`fnox check --all` exits 0 when decryption fails and prints only warnings. Count it as a pass only when the output has no `failed to resolve` line. The decisive probe prints lengths:

```sh
mise exec -- fnox exec --only NAME -- sh -c 'echo ${#NAME}'
```

Done when each length matches the issuer's format (a token shorter than the issuer documents is truncated). `fnox list` shows names and ciphertext only.

## Run a command

```sh
mise exec -- fnox exec --only NAME --if-missing error -- <cmd>
```

`--if-missing error` makes an absent secret fail. The default `warn` exits 0 and prints nothing.

## Premade tasks

One `[tasks.<name>]` per recurring command in the repo's `mise.toml`. The task fixes the secret, the endpoint and the method, so the agent decides none of them.

```toml
[tasks.api-status]
description = "Fetch service status from the API"
run = """
fnox exec --only API_TOKEN --if-missing error -- sh -c 'curl --fail --silent --show-error -H "Authorization: Bearer $API_TOKEN" "https://api.example.com/v1/status"'
"""
```

Run it as `mise run -q api-status`. Without `-q` mise prints a `[task] $ ...` line to the output stream and breaks a pipe into `jq`.

Build a request body with `jq -n '{data: env.NAME}' | curl --data @-`, so the value stays off the command line.

## Plain `mise exec` exports nothing

`mise exec -- <cmd>` never loads `fnox.toml`. `$NAME` stays unset in `<cmd>`, and the CLI's missing-variable error reads like a wrong token. Wrap the command in `fnox exec --`, in a task or inline.

- **Hook**: `fnox exec` in a task is the documented route. The `_.fnox-env` plugin is "an experiment and doesn't support all fnox features" ([official docs](https://github.com/jdx/fnox/blob/main/docs/guide/mise-integration.md)), its repo shows `archived: true` ([source code](https://api.github.com/repos/jdx/mise-env-fnox), checked 2026-11-10), and no source confirms it under `mise exec`. `fnox activate` hooks interactive shells only.
- **Public repo**: store non-secret settings the CLI needs, such as a server URL, in `fnox.toml` too, so the ciphertext keeps the host out of tracked files. An untracked `mise.local.toml` `[env]` block is the fallback when fnox cannot decrypt in the agent's session.
- **Unreadable identity** (`Failed to read age identity file: <path>`): every secret resolves to "not found", for the user's shell and the agent's alike. Compare the `recipients` public key in `fnox.toml` with `~/.ssh/*.pub` and list `ls -l` on the `key_file` path. A recipient from another machine and a missing `key_file` mean this machine cannot decrypt the file: add this machine's public key as a recipient and re-set each secret with `! fnox set NAME`. Never read the private key.

## Lookup

fnox searches the current directory, then parents, for `fnox.toml`, `.fnox.toml` and `.config/fnox.toml`. `FNOX_PROFILE` or `-P` picks a profile. A profile is no security boundary: anyone holding the key decrypts all of them.
