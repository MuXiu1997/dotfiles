---
name: git-commit-workflow
description: Chezmoi dotfiles repository Git commit workflow. Use this skill whenever the user asks to commit changes, commit staged changes, commit added files, write a commit message, or submit the current staged work in this repository. This skill is project-specific: it preserves the repository's English commit style, only commits staged content by default, and runs commits through mise so hooks use the pinned toolchain.
---

# Git Commit Workflow

This skill is for commits in this chezmoi dotfiles source repository. Its goal is to create precise, repository-style English commits while avoiding accidental inclusion of unstaged or unrelated user changes.

## Repository Commit Style

Use English commit messages matching the existing repository style.

Prefer a concise subject line in sentence case with an imperative or action-oriented verb:

```text
Add repository agent instructions
Update Homebrew packages list
Consolidate Claude Code hooks into hooks/ directory
Implement tag-based SSH key switching with age encryption
Refactor Lazygit custom scripts and optimize imports
```

Do not use Conventional Commit prefixes such as `feat:`, `fix:`, or `chore:` unless the user explicitly requests them. This repository's existing history does not use that style.

## Commit Message Format

Use this format for most commits:

```text
<English subject>
```

Use a body only when the subject alone does not explain the change clearly, especially when the commit contains multiple related changes or a non-obvious reason:

```text
<English subject>

- <Describe one concrete change, reason, or effect>
- <Describe another concrete change, reason, or effect>
```

Guidelines:

- Keep the subject concise and specific.
- Start the subject with an action verb such as `Add`, `Update`, `Remove`, `Refactor`, `Fix`, `Consolidate`, `Implement`, or `Apply`.
- Prefer describing the intent or resulting behavior over listing file names.
- Use body bullets for meaningful details, not for restating the file list.
- Do not add a trailing period to the subject.
- Body bullets may use normal English punctuation.
- Avoid vague subjects such as `Update files`, `Modify config`, `Fix issues`, or `Improve setup`.

## Staged-Only Commit Workflow

When the user says `commit`, `commit staged`, `commit added`, `commit the staged changes`, or asks to submit current work, commit only already staged content by default.

### 1. Inspect Status And Staged Changes

Run:

```bash
git status --short
git diff --cached --stat
git diff --cached --numstat
```

Then:

- If there are no staged changes, stop and tell the user there is nothing staged to commit.
- Base the commit message only on `git diff --cached`.
- Mention unstaged or untracked files if relevant, but do not include them in the commit.
- Do not run `git add` unless the user explicitly changes the task to staging files.

### 2. Read Staged Diff As Needed

For simple changes, the stat and numstat output may be enough.

For non-trivial changes, inspect the staged diff:

```bash
git diff --cached -- <file>
```

Use the diff to identify the main intent of the commit. Avoid deriving the message only from paths or file names.

### 3. Choose The Commit Message

Choose a subject that summarizes the staged change as a single coherent action.

Examples:

```text
Update Homebrew packages list
```

```text
Consolidate Claude Code hooks into hooks/ directory
```

```text
Implement tag-based SSH key switching with age encryption
```

```text
Apply automatic fixes from pre-commit hooks
```

If the staged changes combine unrelated intents, stop and ask whether the user wants to split them into separate commits.

### 4. Execute Commit Through mise

This repository uses `mise` to provide tools needed by hooks, such as `shfmt`, `shellcheck`, `ruff`, and `prek`. Always run the commit through `mise exec`.

For a subject-only commit:

```bash
mise exec -- git commit -m "$(cat <<'COMMIT_MSG'
<English subject>
COMMIT_MSG
)"
```

For a commit with a body:

```bash
mise exec -- git commit -m "$(cat <<'COMMIT_MSG'
<English subject>

- <English body bullet>
- <English body bullet>
COMMIT_MSG
)"
```

Use the HEREDOC form even for simple commits. It keeps quoting stable and works consistently for multiline messages.

If the commit fails because a hook modified files or reported issues:

- Read the hook output.
- Inspect the resulting worktree status.
- Do not automatically stage hook-modified files unless the user asked you to handle the full commit process.
- If the fix is safe and directly related, apply or stage only what is necessary after explaining the situation.
- Retry the commit only after the staged content is correct.

### 5. Confirm Result

After committing, run:

```bash
git status
```

Report:

- The new commit hash.
- The commit subject.
- Whether there are remaining unstaged or untracked changes.

## Safety Rules

- Do not commit unstaged files.
- Do not run `git add` unless the user explicitly asks to stage files.
- Do not modify git config.
- Do not use `--no-verify`, `--no-gpg-sign`, or any hook-skipping option unless the user explicitly requests it.
- Do not use destructive git commands such as `git reset --hard`, `git checkout -- <file>`, or force push.
- Do not amend commits unless the user explicitly asks.
- Do not include secrets or decrypted plaintext material in commits.
