# flutter_ci.yml — Line-by-Line Explanation

This document provides a comprehensive line-by-line explanation of the `flutter_ci.yml` GitHub Actions workflow. Each line is annotated with its purpose, syntax, and behavior.

---

## Top-level workflow configuration

```yaml
name: Flutter CI/CD Pipeline
```
**Line 1:** The `name` field sets the human-readable name for this workflow. This name appears in the GitHub Actions UI, pull request checks, and workflow run lists.

---

```yaml
on:
```
**Line 3:** The `on` keyword defines the events that trigger this workflow. It accepts one or more event types.

```yaml
  push:
```
**Line 4:** The workflow triggers on `push` events (when commits are pushed to the repository).

```yaml
    branches:
```
**Line 5:** Filters the `push` event to only specific branches.

```yaml
      - main
      - staging
```
**Lines 6-7:** The workflow runs only when pushes occur to the `main` or `staging` branches. Pushes to other branches are ignored.

```yaml
  pull_request:
```
**Line 8:** The workflow also triggers on `pull_request` events (when PRs are opened, synchronized, or reopened).

```yaml
    branches:
```
**Line 9:** Filters the `pull_request` event to only PRs targeting specific branches.

```yaml
      - main
      - staging
```
**Lines 10-11:** The workflow runs only for PRs targeting `main` or `staging` branches.

---

## Permissions

```yaml
permissions:
```
**Line 13:** The `permissions` key defines what the `GITHUB_TOKEN` (automatically provided to workflows) can access.

```yaml
  contents: write
```
**Line 14:** Grants write access to repository contents. Required for creating releases, pushing tags, and committing changes.

```yaml
  pull-requests: write
```
**Line 15:** Grants write access to pull requests. Allows the workflow to create/update PRs, add comments, labels, etc. (not actively used in this workflow but provided for future use).

---

## Job 1: validate-version

```yaml
jobs:
```
**Line 17:** The `jobs` section defines one or more jobs that run as part of this workflow. Jobs run in parallel by default unless dependencies are specified with `needs`.

```yaml
  validate-version:
```
**Line 18:** Declares a job with the ID `validate-version`. This ID is used to reference the job in `needs` and conditions.

```yaml
    name: Validate Version
```
**Line 19:** Sets a human-readable display name for the job (shown in the GitHub Actions UI).

```yaml
    runs-on: ubuntu-latest
```
**Line 20:** Specifies the runner (virtual machine) to execute this job. `ubuntu-latest` is a GitHub-hosted Ubuntu Linux runner (currently Ubuntu 22.04).

```yaml
    # Only run on main branch pushes - staging skips this completely
```
**Line 21:** Comment explaining the conditional logic below.

```yaml
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```
**Line 22:** 
- github.event_name: the event that triggered the workflow (e.g., `push`, `pull_request`, `workflow_dispatch`).
- github.ref: the full Git ref for the event (examples: `refs/heads/main`, `refs/heads/staging`, `refs/tags/v1.2.3`, `refs/pull/123/merge`).

Conditional expression. The job runs only if:
- `github.event_name == 'push'` — the event is a push (not a PR)
- AND `github.ref == 'refs/heads/main'` — the push is to the `main` branch

This prevents version validation on staging pushes and PR events.

---

```yaml
    steps:
```
**Line 24:** The `steps` array defines the sequential actions/commands to execute within this job.

```yaml
      - name: Checkout repository
```
**Line 25:** Human-readable name for this step.

```yaml
        uses: actions/checkout@v4
```
**Line 26:** Uses a reusable action from the GitHub Actions marketplace. `actions/checkout@v4` checks out the repository code into the runner's workspace.

```yaml
        with:
```
**Line 27:** The `with` block provides input parameters to the action.

```yaml
          fetch-depth: 0
```
**Line 28:** Fetches the full git history (all commits, branches, and tags). The default is `1` (shallow clone). Setting `0` is necessary for git operations that require history (e.g., `git tag`, `git describe`).

```yaml
          token: ${{ secrets.GITHUB_TOKEN }}
```
**Line 29:** Uses the automatically provided `GITHUB_TOKEN` for authentication. `${{ ... }}` is GitHub Actions expression syntax for accessing context variables.

---

```yaml
 - name: Check version against last release
```
**Line 31:** Name for the version validation step.

```yaml
  run: |
```
**Line 32:** The `run` keyword executes shell commands. The `|` (pipe) indicates a multi-line shell script block.

```yaml
CURRENT_VERSION=$(awk -F':[[:space:]]*' '/^[[:space:]]*version:/ {print $2; exit}' pubspec.yaml)
```
**Line 34:** Shell command that get current version:

The awk shell command template `awk -F'SEPARATOR' 'PATTERN { ACTION }' file`

This `-F':[[:space:]]*'` sets the field separator to `:` followed by any amount of optional whitespace.
-F in awk stands for Field Separator.
It tells awk how to split each input line into fields (columns).

→ $1 = version
→ $2 = 1.2.3+4

This `/^[[:space:]]*version:/` regex pattern matches any line that may start with spaces followed by `version:`

`{print $2; exit}` outputs the version value (everything after the colon and optional spaces).

---

```yaml
echo "🔍 Validating release version..."
```
**Line 36:** Prints a message to the job log.

```yaml
LAST_RELEASE_TAG=$(git tag -l "v*" --sort=-version:refname | head -n 1 || echo "")
```
**Line 40:** Shell command that:
The `|` takes the output of the previous command and give it as input to the next command
- `git tag -l "v*"` — lists all tags starting with `v` (we use `v` as starting of our release version)
- `--sort=-version:refname` — sorts tags by version in descending order
- `head -n 1` — takes the first (most recent) tag
- `|| echo ""` — if no tags exist, returns empty string
- Result assigned to `LAST_RELEASE_TAG`

---

```yaml
if [ -n "$LAST_RELEASE_TAG" ]; then
```
**Line 42:** Shell `if` statement. `-n` tests if the string is non-empty (i.e., a tag was found).

```yaml
LAST_RELEASE_VERSION=${LAST_RELEASE_TAG#v}
```
**Line 43:** Bash parameter expansion. `${LAST_RELEASE_TAG#v}` removes the leading `v` from the tag name (e.g., `v1.2.3` becomes `1.2.3`).

---

```yaml
if [ "$CURRENT_VERSION" = "$LAST_RELEASE_VERSION" ]; then
```
**Line 47:** Nested `if` statement. Tests if the current version equals the last release version.

```yaml
echo "❌ ERROR: Version conflict detected!"
```
**Line 48:** Error message printed if versions match.

```yaml
exit 1
```
**Line 63:** Exits the shell script with status code `1` (failure), which fails the entire job and blocks downstream jobs. else Success messages.

```yaml
            fi
```
**Line 67:** Closes the inner `if` statement.

```yaml
          fi
```
**Line 71:** Closes the outer `if` statement.

---

## Job 2: version-management

```yaml
  version-management:
```
**Line 73:** Job ID: `version-management`.

```yaml
name: Version Management
```
**Line 74:** Display name.

```yaml
runs-on: ubuntu-latest
```
**Line 75:** Runs on Ubuntu.

```yaml
if: github.event_name == 'push'
```
**Line 77:** Conditional: only runs on `push` events (not PRs).

```yaml
outputs:
```
**Line 78:** The `outputs` section defines job-level outputs that downstream jobs can access via `needs.version-management.outputs.<name>`.

```yaml
version_name: ${{ steps.version.outputs.version_name }}
```
**Line 79:** Exposes `version_name` output from the step with ID `version`. Expression syntax: `${{ steps.<step-id>.outputs.<output-name> }}`.

---

```yaml
steps:
```
**Line 86:** Steps for this job.

---

```yaml
        run: |
```
**Line 95:** Multi-line shell script.

```yaml
          BRANCH=${GITHUB_REF#refs/heads/}
```
**Line 97:** Extracts branch name from `GITHUB_REF` environment variable (e.g., `refs/heads/main` becomes `main`).

```yaml
          if [ "$BRANCH" = "main" ]; then
            BRANCH_TYPE="release"
          else
            BRANCH_TYPE="staging"
          fi
```
**Lines 98-102:** Shell conditional. If branch is `main`, set `BRANCH_TYPE` to `release`, otherwise `staging`.

```yaml
          echo "branch_type=$BRANCH_TYPE" >> $GITHUB_OUTPUT
```
**Line 103:** Writes the output `branch_type` to the special `$GITHUB_OUTPUT` file, making it available to downstream jobs via `needs.version-management.outputs.branch_type`.

---

```yaml
          # Get project name from pubspec.yaml
```
**Line 105:** Comment.

```yaml
          PROJECT_NAME=$(grep '^name:' pubspec.yaml | sed 's/name: //' | tr -d ' ')
```
**Line 106:** Extracts project name from `pubspec.yaml` (similar to version extraction).

```yaml
          echo "project_name=$PROJECT_NAME" >> $GITHUB_OUTPUT
```
**Line 107:** Writes output.

---

```yaml
          # Get current date (YYYY-MM-DD format)
```
**Line 109:** Comment.

```yaml
          CURRENT_DATE=$(date +%Y-%m-%d)
```
**Line 110:** Runs the `date` command to get the current date in `YYYY-MM-DD` format.

```yaml
          echo "current_date=$CURRENT_DATE" >> $GITHUB_OUTPUT
```
**Line 111:** Writes output.

---

```yaml
          # Extract base version from pubspec.yaml
```
**Line 113:** Comment.

```yaml
          CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | tr -d ' ')
```
**Line 114:** Extracts full version string from `pubspec.yaml`.

```yaml
          BASE_VERSION=$(echo $CURRENT_VERSION | cut -d'+' -f1 | cut -d'-' -f1)
```
**Line 115:** Extracts base version:
- `cut -d'+' -f1` — takes the part before `+` (e.g., `1.2.3+45` becomes `1.2.3`)
- `cut -d'-' -f1` — takes the part before `-` (e.g., `1.2.3-staging` becomes `1.2.3`)

---

```yaml
          # Get git commit info
```
**Line 117:** Comment.

```yaml
          COMMIT_COUNT=$(git rev-list --count HEAD)
```
**Line 118:** Counts total commits in the current branch history.

```yaml
          COMMIT_HASH=$(git rev-parse --short HEAD)
```
**Line 119:** Gets the short commit hash (7 characters) of the current HEAD.

---

```yaml
          if [ "$BRANCH" = "main" ]; then
```
**Line 121:** Conditional for `main` branch logic.

```yaml
            # MAIN BRANCH: Manual version control
            # Format: X.Y.Z+BUILD (e.g., 1.2.3+45)
```
**Lines 122-123:** Comments explaining the version format for production releases.

```yaml
            VERSION_CODE=$(echo $CURRENT_VERSION | cut -d'+' -f2)
```
**Line 124:** Extracts the build number after `+` (e.g., `1.2.3+45` becomes `45`).

---

```yaml
            # Validate version format
```
**Line 126:** Comment.

```yaml
            if [ -z "$BASE_VERSION" ] || [ -z "$VERSION_CODE" ]; then
```
**Line 127:** Tests if `BASE_VERSION` or `VERSION_CODE` is empty (`-z` tests for empty string). Uses `||` (OR) operator.

```yaml
              echo "❌ Error: Invalid version format in pubspec.yaml"
              echo "Expected format: version: X.Y.Z+BUILD (e.g., version: 1.2.3+45)"
              exit 1
```
**Lines 128-130:** Error messages and exit with failure if version format is invalid.

```yaml
            fi
```
**Line 131:** Closes validation `if`.

---

```yaml
            VERSION_NAME="$BASE_VERSION"
```
**Line 133:** For production, `version_name` is just the base version (e.g., `1.2.3`).

```yaml
            FULL_VERSION="${BASE_VERSION}+${VERSION_CODE}"
```
**Line 134:** Reconstructs the full version string (e.g., `1.2.3+45`).

```yaml
            echo "🚀 Production Release (Manual Control)"
            echo "Version Name: $VERSION_NAME"
            echo "Version Code: $VERSION_CODE"
```
**Lines 136-138:** Logs version info for the production build.

---

```yaml
          else
```
**Line 140:** Shell `else` clause for staging branch.

```yaml
            # STAGING BRANCH: Automatic incremental version
            # Format: X.Y.Z-staging+BUILD.HASH (e.g., 1.2.3-staging+127.b5e9f1a)
```
**Lines 141-142:** Comments explaining staging version format.

```yaml
            STAGING_BUILD_COUNT=$(git rev-list --count origin/staging 2>/dev/null || echo $COMMIT_COUNT)
```
**Line 143:** Counts commits in `origin/staging` branch. If the command fails (`2>/dev/null` suppresses errors), falls back to total commit count.

```yaml
            VERSION_CODE=$STAGING_BUILD_COUNT
```
**Line 144:** Uses staging commit count as the version code.

---

```yaml
            VERSION_NAME="${BASE_VERSION}-staging"
```
**Line 146:** Appends `-staging` to the base version (e.g., `1.2.3-staging`).

```yaml
            FULL_VERSION="${BASE_VERSION}-staging+${STAGING_BUILD_COUNT}.${COMMIT_HASH}"
```
**Line 147:** Constructs full staging version with commit count and hash (e.g., `1.2.3-staging+127.b5e9f1a`).

```yaml
            echo "🔧 Staging Build (Auto-increment)"
            echo "Version Name: $VERSION_NAME"
            echo "Version Code: $VERSION_CODE"
            echo "Full Version: $FULL_VERSION"
```
**Lines 149-152:** Logs staging version info.

```yaml
          fi
```
**Line 153:** Closes branch type conditional.

---

```yaml
          echo "version_name=$VERSION_NAME" >> $GITHUB_OUTPUT
          echo "version_code=$VERSION_CODE" >> $GITHUB_OUTPUT
          echo "full_version=$FULL_VERSION" >> $GITHUB_OUTPUT
```
**Lines 155-157:** Writes version outputs to `$GITHUB_OUTPUT`.

---

```yaml
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo "📦 Version Information"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo "Project:      $PROJECT_NAME"
          echo "Version:      $FULL_VERSION"
          echo "Branch Type:  $BRANCH_TYPE"
          echo "Date:         $CURRENT_DATE"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```
**Lines 159-166:** Pretty-printed summary box for the job log.

---

## Job 3: test-and-analyze

```yaml
  test-and-analyze:
```
**Line 168:** Job ID: `test-and-analyze`.

```yaml
    name: Test & Code Quality
```
**Line 169:** Display name.

```yaml
    runs-on: ubuntu-latest
```
**Line 170:** Ubuntu runner.

```yaml
    # Test runs on all events (push and pull_request), no dependency on validate-version
```
**Line 171:** Comment — this job runs for both pushes and PRs (no `if` condition at job level).

---

```yaml
    steps:
```
**Line 173:** Steps array.

```yaml
      - name: Checkout repository
        uses: actions/checkout@v4
```
**Lines 174-175:** Checks out code. Note: no `fetch-depth: 0` here (shallow clone is fine for testing).

---

```yaml
      # Enhanced caching for pub dependencies
```
**Line 177:** Comment.

```yaml
      - name: Cache pub dependencies
```
**Line 178:** Step name.

```yaml
        uses: actions/cache@v4
```
**Line 179:** Uses the GitHub Actions cache action to cache files between workflow runs.

```yaml
        with:
```
**Line 180:** Input parameters.

```yaml
          path: |
            ~/.pub-cache
            .dart_tool
```
**Lines 181-183:** Multi-line list of paths to cache. `~/.pub-cache` is Flutter's global pub cache, `.dart_tool` is the local project cache.

```yaml
          key: pub-deps-${{ runner.os }}-${{ hashFiles('**/pubspec.lock') }}
```
**Line 184:** Cache key. Unique key composed of:
- `pub-deps-` — prefix
- `${{ runner.os }}` — operating system (e.g., `Linux`)
- `${{ hashFiles('**/pubspec.lock') }}` — hash of `pubspec.lock` file(s). Cache invalidates when dependencies change.

```yaml
          restore-keys: |
            pub-deps-${{ runner.os }}-
```
**Lines 185-186:** Fallback keys. If exact key isn't found, the cache action tries these prefixes to restore a partial match.

---

```yaml
      - name: Setup Flutter
```
**Line 188:** Step name.

```yaml
        uses: subosito/flutter-action@v2
```
**Line 189:** Third-party action that installs Flutter SDK.

```yaml
        with:
          flutter-version: '3.32.8'
```
**Line 191:** Specifies Flutter version to install.

```yaml
          channel: 'stable'
```
**Line 192:** Uses the stable Flutter channel.

```yaml
          cache: true
```
**Line 193:** Enables the action's built-in caching mechanism.

```yaml
          cache-key: flutter-${{ runner.os }}-3.32.8
```
**Line 194:** Custom cache key for Flutter SDK caching.

---

```yaml
      - name: Install dependencies
```
**Line 196:** Step name.

```yaml
        run: flutter pub get
```
**Line 197:** Runs `flutter pub get` to install Dart/Flutter dependencies from `pubspec.yaml`.

---

```yaml
      - name: Verify formatting
```
**Line 199:** Step name.

```yaml
        run: dart format --set-exit-if-changed .
```
**Line 200:** Runs Dart formatter. `--set-exit-if-changed` makes the command exit with non-zero status if any files need formatting. `.` means format all files in the current directory recursively.

```yaml
        continue-on-error: true
```
**Line 201:** Prevents this step's failure from failing the entire job. The job continues even if formatting fails.

---

```yaml
      - name: Analyze code
```
**Line 203:** Step name.

```yaml
        run: flutter analyze --fatal-infos
```
**Line 204:** Runs static analysis. `--fatal-infos` treats all issues (including info-level) as errors, failing the command if any are found.

---

```yaml
      - name: Run unit and widget tests
```
**Line 206:** Step name.

```yaml
        run: flutter test --coverage --reporter expanded
```
**Line 207:** Runs tests:
- `--coverage` — generates code coverage report
- `--reporter expanded` — uses verbose test output format

---

```yaml
      - name: Check test coverage
```
**Line 209:** Step name.

```yaml
        run: |
          if [ -f coverage/lcov.info ]; then
            echo "✅ Coverage report generated"
            # You can add coverage threshold checks here
          else
            echo "⚠️ No coverage data found"
          fi
```
**Lines 210-216:** Shell script that checks if the coverage file exists and logs a message.

---

```yaml
      - name: Upload coverage report
```
**Line 218:** Step name.

```yaml
        uses: actions/upload-artifact@v4
```
**Line 219:** Action to upload files as workflow artifacts (downloadable from GitHub Actions UI).

```yaml
        with:
          name: coverage-report
```
**Line 221:** Artifact name.

```yaml
          path: coverage/lcov.info
```
**Line 222:** Path to the file to upload.

```yaml
          retention-days: 30
```
**Line 223:** Artifacts are kept for 30 days before automatic deletion.

---

```yaml
      # Save complete workspace for build job (optimized)
      # Use always() to ensure cache is saved even if formatting check fails with continue-on-error
```
**Lines 225-226:** Comments.

```yaml
      - name: Save workspace for build job
```
**Line 227:** Step name.

```yaml
        if: always()
```
**Line 228:** Conditional expression. `always()` means this step runs regardless of previous step failures (ensures cache is saved even if tests fail).

```yaml
        uses: actions/cache/save@v3
```
**Line 229:** Explicit cache save action (normally cache is saved automatically at job end, but this gives fine-grained control).

```yaml
        with:
          path: |
            ~/.pub-cache
            .dart_tool
            build
```
**Lines 230-233:** Paths to save in cache (includes pub cache, Dart tool cache, and build artifacts).

```yaml
          key: workspace-${{ github.sha }}-${{ runner.os }}
```
**Line 234:** Cache key using commit SHA. Note: using SHA creates a unique cache per commit, limiting reuse.

---

## Job 4: build-android

```yaml
  build-android:
```
**Line 236:** Job ID: `build-android`.

```yaml
    name: Build Android (${{ needs.version-management.outputs.branch_type }})
```
**Line 237:** Dynamic display name that includes the branch type from `version-management` job output.

```yaml
    runs-on: ubuntu-latest
```
**Line 238:** Ubuntu runner.

```yaml
    needs: [ version-management, test-and-analyze ]
```
**Line 239:** Job dependency array. This job waits for both `version-management` and `test-and-analyze` to complete successfully before starting.

```yaml
    # Only run on push events when both dependencies succeeded
```
**Line 240:** Comment.

```yaml
    if: github.event_name == 'push'
```
**Line 241:** Conditional: only runs on push events (not PRs).

---

```yaml
    steps:
```
**Line 243:** Steps array.

```yaml
      - name: Checkout repository
        uses: actions/checkout@v4
```
**Lines 244-245:** Checks out code (shallow clone).

---

```yaml
      # Restore complete workspace from test job (includes Flutter SDK, pub cache, and build artifacts)
```
**Line 247:** Comment.

```yaml
      - name: Restore workspace from test job
```
**Line 248:** Step name.

```yaml
        uses: actions/cache/restore@v3
```
**Line 249:** Explicit cache restore action.

```yaml
        with:
          path: |
            ~/.pub-cache
            .dart_tool
            build
```
**Lines 250-253:** Paths to restore from cache (must match the paths saved in `test-and-analyze`).

```yaml
          key: workspace-${{ github.sha }}-${{ runner.os }}
```
**Line 254:** Cache key (must match the key used in save step).

```yaml
          fail-on-cache-miss: false
```
**Line 255:** If cache isn't found, continue anyway (don't fail the job). This provides resilience if cache is unavailable.

---

```yaml
      # Lightweight Flutter setup (reuses cached SDK)
```
**Line 257:** Comment.

```yaml
      - name: Setup Flutter (from cache)
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.8'
          channel: 'stable'
          cache: true
          cache-key: flutter-${{ runner.os }}-3.32.8
```
**Lines 258-263:** Same Flutter setup as in `test-and-analyze` — relies on caching to avoid re-downloading.

---

```yaml
      # Skip pub get - dependencies already in cache from test job!
      # This saves significant time on every build
```
**Lines 265-266:** Comments explaining optimization — no `flutter pub get` step because dependencies are already cached.

---

```yaml
      - name: Build APK (Always)
```
**Line 268:** Step name.

```yaml
        run: |
          echo "📱 Building APK for ${{ needs.version-management.outputs.branch_type }}"
          flutter build apk --release \
            --build-name=${{ needs.version-management.outputs.version_name }} \
            --build-number=${{ needs.version-management.outputs.version_code }}
```
**Lines 269-272:** Shell script that:
- Prints a message
- Runs `flutter build apk --release` to build a release APK
- `--build-name` sets the version name (displayed to users)
- `--build-number` sets the version code (integer for Play Store)
- `\` at line end continues the command on the next line

---

```yaml
      - name: Build AAB (Release Only)
```
**Line 274:** Step name.

```yaml
        if: needs.version-management.outputs.branch_type == 'release'
```
**Line 275:** Conditional: this step only runs for production releases (main branch).

```yaml
        run: |
          echo "Building AAB for Play Store"
          flutter build appbundle --release \
            --build-name=${{ needs.version-management.outputs.version_name }} \
            --build-number=${{ needs.version-management.outputs.version_code }}
```
**Lines 276-279:** Builds Android App Bundle (AAB) for Play Store uploads (only for production).

---

```yaml
      - name: Rename artifacts
```
**Line 281:** Step name.

```yaml
        run: |
          # Get variables
          PROJECT_NAME="${{ needs.version-management.outputs.project_name }}"
          FULL_VERSION="${{ needs.version-management.outputs.full_version }}"
          BRANCH_TYPE="${{ needs.version-management.outputs.branch_type }}"
          CURRENT_DATE="${{ needs.version-management.outputs.current_date }}"
```
**Lines 282-287:** Shell script that assigns job outputs to shell variables for easier use.

---

```yaml
          # Format: {projectname}-{version}-{release/staging}-{date}.apk
          APK_NAME="${PROJECT_NAME}-${FULL_VERSION}-${BRANCH_TYPE}-${CURRENT_DATE}.apk"
```
**Lines 289-290:** Constructs descriptive APK filename using variables.

```yaml
          echo "📝 Renaming APK to: $APK_NAME"
          cp build/app/outputs/flutter-apk/app-release.apk \
             build/app/outputs/flutter-apk/${APK_NAME}
```
**Lines 292-294:** Copies the built APK to a new file with the descriptive name.

---

```yaml
          # Rename AAB only for release builds
          if [ "$BRANCH_TYPE" = "release" ]; then
            AAB_NAME="${PROJECT_NAME}-${FULL_VERSION}-${BRANCH_TYPE}-${CURRENT_DATE}.aab"
            echo "📝 Renaming AAB to: $AAB_NAME"
            cp build/app/outputs/bundle/release/app-release.aab \
               build/app/outputs/bundle/release/${AAB_NAME}
          fi
```
**Lines 296-301:** Conditionally renames AAB (only for release builds).

---

```yaml
      - name: Upload APK artifact
```
**Line 303:** Step name.

```yaml
        uses: actions/upload-artifact@v4
```
**Line 304:** Uploads artifact.

```yaml
        with:
          name: ${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-${{ needs.version-management.outputs.branch_type }}-${{ needs.version-management.outputs.current_date }}-apk
```
**Line 306:** Long artifact name composed from job outputs (must match exactly in download steps).

```yaml
          path: build/app/outputs/flutter-apk/${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-${{ needs.version-management.outputs.branch_type }}-${{ needs.version-management.outputs.current_date }}.apk
```
**Line 307:** Full path to the renamed APK file.

```yaml
      #          retention-days: 30
```
**Line 308:** Commented out retention setting (uses default).

---

```yaml
      - name: Upload AAB artifact (Release Only)
```
**Line 310:** Step name.

```yaml
        if: needs.version-management.outputs.branch_type == 'release'
```
**Line 311:** Conditional: only upload AAB for production releases.

```yaml
        uses: actions/upload-artifact@v4
        with:
          name: ${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-${{ needs.version-management.outputs.branch_type }}-${{ needs.version-management.outputs.current_date }}-aab
          path: build/app/outputs/bundle/release/${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-${{ needs.version-management.outputs.branch_type }}-${{ needs.version-management.outputs.current_date }}.aab
          retention-days: 30
```
**Lines 312-316:** Uploads AAB artifact with 30-day retention.

---

## Job 5: release-staging

```yaml
  release-staging:
```
**Line 318:** Job ID: `release-staging`.

```yaml
    name: Release to Staging
```
**Line 319:** Display name.

```yaml
    runs-on: ubuntu-latest
```
**Line 320:** Ubuntu runner.

```yaml
    needs: [ version-management, build-android ]
```
**Line 321:** Depends on version metadata and build artifacts.

```yaml
    if: github.ref == 'refs/heads/staging' && github.event_name == 'push'
```
**Line 322:** Conditional: only runs for pushes to `staging` branch.

---

```yaml
    steps:
```
**Line 324:** Steps array.

```yaml
      - name: Checkout repository
        uses: actions/checkout@v4
```
**Lines 325-326:** Checks out code.

---

```yaml
      - name: Download APK
```
**Line 328:** Step name.

```yaml
        uses: actions/download-artifact@v4
```
**Line 329:** Downloads artifact uploaded by `build-android` job.

```yaml
        with:
          name: ${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-${{ needs.version-management.outputs.branch_type }}-${{ needs.version-management.outputs.current_date }}-apk
```
**Line 331:** Artifact name (must match upload name exactly).

```yaml
          path: ./artifacts
```
**Line 332:** Downloads artifact to `./artifacts` directory.

---

```yaml
      - name: Create Staging Release
```
**Line 334:** Step name.

```yaml
        uses: softprops/action-gh-release@v2
```
**Line 335:** Third-party action for creating GitHub Releases.

```yaml
        with:
          tag_name: ${{ needs.version-management.outputs.full_version }}
```
**Line 337:** Tag name for the release (e.g., `1.2.3-staging+127.b5e9f1a`).

```yaml
          name: Staging ${{ needs.version-management.outputs.full_version }} (${{ needs.version-management.outputs.current_date }})
```
**Line 338:** Release title.

```yaml
          body: |
```
**Line 339:** Multi-line release description (Markdown format).

**Lines 340-356:** Release body content (static text mixed with dynamic expressions). Includes version info, commit SHA, and download instructions.

```yaml
          files: |
            ./artifacts/${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-staging-${{ needs.version-management.outputs.current_date }}.apk
```
**Lines 357-358:** Files to attach to the release (paths must match downloaded artifacts).

```yaml
          draft: false
```
**Line 359:** Creates a published release (not a draft).

```yaml
          prerelease: true
```
**Line 360:** Marks as a pre-release (staging builds are not production-ready).

```yaml
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
**Lines 361-362:** Provides authentication token to the action.

---

## Job 6: release-production

```yaml
  release-production:
```
**Line 364:** Job ID: `release-production`.

```yaml
    name: Release to Production
```
**Line 365:** Display name.

```yaml
    runs-on: ubuntu-latest
```
**Line 366:** Ubuntu runner.

```yaml
    needs: [ version-management, build-android ]
```
**Line 367:** Dependencies.

```yaml
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```
**Line 368:** Conditional: only runs for pushes to `main` branch.

---

```yaml
    steps:
```
**Line 370:** Steps array.

```yaml
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
```
**Lines 371-374:** Checks out full git history (needed for changelog generation).

---

```yaml
      - name: Download APK
        uses: actions/download-artifact@v4
        with:
          name: ${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-${{ needs.version-management.outputs.branch_type }}-${{ needs.version-management.outputs.current_date }}-apk
          path: ./artifacts
```
**Lines 376-380:** Downloads APK artifact.

---

```yaml
      - name: Download AAB
        uses: actions/download-artifact@v4
        with:
          name: ${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-${{ needs.version-management.outputs.branch_type }}-${{ needs.version-management.outputs.current_date }}-aab
          path: ./artifacts
```
**Lines 382-386:** Downloads AAB artifact (production builds include AAB).

---

```yaml
      - name: Generate changelog
```
**Line 388:** Step name.

```yaml
        id: changelog
```
**Line 389:** Step ID for accessing outputs.

```yaml
        run: |
          # Get commits since last release tag
          LAST_TAG=$(git describe --tags --abbrev=0 --match "v*" 2>/dev/null || echo "")
```
**Lines 390-392:** Finds the last tag starting with `v`. `git describe` finds the most recent tag reachable from HEAD.

```yaml
          if [ -z "$LAST_TAG" ]; then
            CHANGELOG=$(git log --pretty=format:"- %s (%h)" --no-merges -10)
```
**Lines 393-394:** If no previous tag exists, get last 10 commits:
- `--pretty=format:"- %s (%h)"` — formats each commit as a bullet point with subject and short hash
- `--no-merges` — excludes merge commits

```yaml
          else
            CHANGELOG=$(git log ${LAST_TAG}..HEAD --pretty=format:"- %s (%h)" --no-merges)
```
**Lines 395-396:** If a tag exists, get commits between that tag and HEAD.

```yaml
          fi
```
**Line 397:** Closes conditional.

---

```yaml
          echo "changelog<<EOF" >> $GITHUB_OUTPUT
          echo "$CHANGELOG" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT
```
**Lines 399-401:** Writes multi-line output using heredoc syntax (`EOF` delimiter). This allows the changelog to be accessed as `steps.changelog.outputs.changelog`.

---

```yaml
      - name: Create Production Release with Tag
```
**Line 403:** Step name.

```yaml
        uses: softprops/action-gh-release@v2
```
**Line 404:** Creates GitHub Release.

```yaml
        with:
          tag_name: v${{ needs.version-management.outputs.full_version }}
```
**Line 406:** Tag name with `v` prefix (e.g., `v1.2.3+45`).

```yaml
          name: Release v${{ needs.version-management.outputs.full_version }} (${{ needs.version-management.outputs.current_date }})
```
**Line 407:** Release title.

```yaml
          body: |
```
**Line 408:** Release description (Markdown).

**Lines 409-432:** Release body with version info, changelog, and download links.

```yaml
          files: |
            ./artifacts/${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-release-${{ needs.version-management.outputs.current_date }}.apk
            ./artifacts/${{ needs.version-management.outputs.project_name }}-${{ needs.version-management.outputs.full_version }}-release-${{ needs.version-management.outputs.current_date }}.aab
```
**Lines 433-435:** Attaches both APK and AAB files.

```yaml
          draft: false
```
**Line 436:** Published release.

```yaml
          prerelease: false
```
**Line 437:** Not a pre-release (this is production).

```yaml
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
**Lines 438-439:** Authentication.

---

## Job 7: build-summary

```yaml
  build-summary:
```
**Line 441:** Job ID: `build-summary`.

```yaml
    name: Build Summary
```
**Line 442:** Display name.

```yaml
    runs-on: ubuntu-latest
```
**Line 443:** Ubuntu runner.

```yaml
    needs: [ version-management, test-and-analyze, build-android, release-staging, release-production ]
```
**Line 444:** Depends on all major jobs (runs last).

```yaml
    if: always() && github.event_name == 'push'
```
**Line 445:** Conditional:
- `always()` — runs even if previous jobs failed
- `&& github.event_name == 'push'` — only on push events

---

```yaml
    steps:
```
**Line 447:** Steps array.

```yaml
      - name: Generate summary
```
**Line 448:** Step name.

```yaml
        run: |
```
**Line 449:** Shell script.

```yaml
          echo "## 📊 Build Summary" >> $GITHUB_STEP_SUMMARY
```
**Line 450:** Writes to `$GITHUB_STEP_SUMMARY` (special file that renders Markdown in the Actions UI).

**Lines 451-468:** Additional `echo` statements writing summary content (project, version, artifacts, job statuses).

```yaml
          if [ "${{ needs.version-management.outputs.branch_type }}" = "release" ]; then
            echo "🚀 **Production build completed**" >> $GITHUB_STEP_SUMMARY
          else
            echo "🔧 **Staging build completed**" >> $GITHUB_STEP_SUMMARY
          fi
```
**Lines 470-474:** Conditional message based on build type.

---

## Summary

This workflow is a sophisticated CI/CD pipeline that:
1. Validates versions (production only)
2. Computes version metadata
3. Runs tests and static analysis
4. Builds Android artifacts (APK/AAB)
5. Creates GitHub Releases (staging or production)
6. Generates build summaries

Key concepts demonstrated:
- **Job dependencies** (`needs`)
- **Job outputs** and cross-job data sharing
- **Conditional execution** (`if`)
- **Caching** for performance
- **Artifacts** for file sharing between jobs
- **Expression syntax** (`${{ ... }}`)
- **Multi-line shell scripts** (`run: |`)
- **GitHub-specific files** (`$GITHUB_OUTPUT`, `$GITHUB_STEP_SUMMARY`)

This workflow showcases advanced GitHub Actions patterns for production Flutter/Android deployments.
