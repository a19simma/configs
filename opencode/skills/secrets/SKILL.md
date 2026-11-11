---
name: secrets
description: Store, use and verify credentials with fnox, mise exec and premade mise tasks. Use when a command needs a token, password or key, when a user pastes a secret, or when adding a recurring authenticated command to a repo.
---

# Secrets

A secret lives encrypted in the repo that uses it. A command that needs one runs through `mise exec`, so fnox injects the value into the process environment. Each recurring command gets a premade `mise` task, and agents run the task.

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

## Lookup

fnox searches the current directory, then parents, for `fnox.toml`, `.fnox.toml` and `.config/fnox.toml`. `FNOX_PROFILE` or `-P` picks a profile. A profile is no security boundary: anyone holding the key decrypts all of them.
