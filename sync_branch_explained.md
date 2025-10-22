## sync_branch.yml — detailed explanation

This document explains the GitHub Actions workflow defined in `sync_branch.yml` (source file: `.github/workflows/sync_branch.yml`). It provides a line-by-line breakdown of the YAML, describes what the workflow does, points out potential pitfalls, and suggests improvements.

### Purpose

The workflow is named "Sync branch CI/CD Pipeline" and is triggered when there is a push to the `staging` branch. Its intent is to automatically merge changes from `staging` into several regional branches (example: `au`, `nz`) and push those merges to the remote repository.

### Full workflow (reference)

```yaml
name: Sync branch CI/CD Pipeline

on:
  push:
    branches:
      - staging

permissions:
  contents: write

jobs:
  sync_branches:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Configure Git
        run: |
          git config user.name "CI Bot"
          git config user.email "ci@bot.com"

      - name: Sync staging to regional branches
        run: |
          for branch in au nz; do
            git checkout $branch
            git merge --no-ff origin/staging -m "Auto-sync from staging to $branch"
            git checkout -- lib/service/base.dart
            git commit -am "Preserve base.dart" || true
            git push origin $branch
          done
```

### Line-by-line explanation

- name: Sync branch CI/CD Pipeline
  - Sets the human-readable name for the workflow shown in the Actions UI.

- on: push: branches: [staging]
  - Triggers the workflow when commits are pushed to the `staging` branch. Only pushes (not PRs) will run it.

- permissions: contents: write
  - Grants the job write access to repository contents via the GITHUB_TOKEN. Required when the workflow pushes commits back to the repo.

- jobs: sync_branches
  - Declares a job named `sync_branches`.

- runs-on: ubuntu-latest
  - Runs the job on GitHub-hosted Ubuntu runner.

- steps: - uses: actions/checkout@v4 with: fetch-depth: 0
  - Checks out the repository into the runner. `fetch-depth: 0` ensures full git history is fetched, which is necessary for merging and pushing across branches.

- Configure Git (run block)
  - Sets the commit author name and email so the merges/commits created by the runner have a sensible author.

- Sync staging to regional branches (run block)
  - This shell code iterates over a small, hard-coded list of branch names (`au` and `nz`) and performs the following for each branch:
    1. `git checkout $branch` — switch to the target branch. This will fail if the branch doesn't exist locally. `actions/checkout` by default checks out only the triggered branch, so these branches may not exist locally unless fetched.
    2. `git merge --no-ff origin/staging -m "Auto-sync from staging to $branch"` — merges the remote `origin/staging` into the current branch using a merge commit (no fast-forward). This uses the remote tracking branch rather than the local `staging` branch from the checkout.
    3. `git checkout -- lib/service/base.dart` — force-resets `lib/service/base.dart` to the version currently in the index/HEAD. The intent appears to be to preserve that file from being changed by the merge.
    4. `git commit -am "Preserve base.dart" || true` — creates a commit in case `base.dart` was staged after the checkout reset; `|| true` prevents the script from failing if there is nothing to commit.
    5. `git push origin $branch` — pushes the updated branch back to the remote.

### Important behavior notes and pitfalls

- Branch availability: `actions/checkout@v4` by default checks out the commit that triggered the workflow (here, `staging`). It does not create local copies of `au` or `nz`. Because the script runs `git checkout $branch`, it will fail unless those branches exist locally. The `fetch-depth: 0` option ensures history is available but doesn't automatically create local branch refs for `au` or `nz`. You may need to `git fetch origin $branch:$branch` or use `actions/checkout` with `ref` or additional fetch settings.

- Race conditions / concurrency: If multiple pushes to `staging` happen quickly, concurrent workflow runs may try to merge and push to the same target branches at the same time. Use the `concurrency` key to limit this and avoid conflicting pushes.

- Hard-coded branch list: The branches are hard-coded (`au` and `nz`). If you need more branches or dynamic discovery, consider reading a configuration file or using a repository input.

- Force-preserving a file: `git checkout -- lib/service/base.dart` will discard merge changes to that file and revert it back to the current HEAD version of the branch — this is non-obvious and can hide conflicts or intended updates. If the goal is to intentionally keep that file unchanged on regional branches, it might be better to document the reason or store region-specific variants in a separate path.

- Authorship: The script sets a generic `CI Bot` author. That is usually acceptable, but some teams prefer `github-actions` bot or the GITHUB_ACTOR value to reflect the user who pushed the original change.

- Error handling: The script swallows errors on `git commit -am ... || true`, which may mask problems. Other commands can also fail (checkout, merge, push) and will cause the job to fail unless captured.

### Suggested improvements

1. Ensure the target branches are fetched and created locally before checking them out. For example:

```sh
git fetch --all --prune
git checkout -B "$branch" "origin/$branch"
```

2. Add `concurrency` at the top-level job to prevent concurrent runs stepping on each other:

```yaml
concurrency:
  group: sync-branches
  cancel-in-progress: true
```

3. Add a check to skip branches that don't exist on origin to avoid checkout failures:

```sh
if git ls-remote --exit-code --heads origin "$branch"; then
  # proceed
else
  echo "branch $branch does not exist on origin, skipping"
  continue
fi
```

4. Prefer explicit git user information or use GITHUB_ACTOR and the default GITHUB_TOKEN identity if you need to preserve the actual actor.

5. Consider using `gh` or the GitHub API to create Pull Requests instead of direct merges for workflows that require review.

6. Be careful with the `git checkout -- lib/service/base.dart` step — document why it exists and consider alternatives like `.gitattributes` merge strategies or maintain separate config per branch.

### Minimal corrected example

Below is a minimal safer snippet that addresses local branch creation and existence checks (not a drop-in replacement — review before use):

```sh
git fetch --all --prune
for branch in au nz; do
  if git ls-remote --exit-code --heads origin "$branch"; then
    git checkout -B "$branch" "origin/$branch"
    git merge --no-ff origin/staging -m "Auto-sync from staging to $branch"
    git checkout -- lib/service/base.dart
    git commit -am "Preserve base.dart" || true
    git push origin "$branch"
  else
    echo "Skipping non-existent branch: $branch"
  fi
done
```

### Acceptance criteria mapping

- The file explains the workflow line-by-line: Done
- The file describes behavior and pitfalls: Done
- The file suggests improvements and safer operations: Done

### Next steps

- If you want, I can update the original workflow file to incorporate the safer changes (concurrency, fetch, branch existence checks). Let me know if you want an automatic patch.

### File provenance

Created from the provided `sync_branch.yml` file contents. Please verify branch names and repository policy before applying any automated merge/push workflow to production branches.
