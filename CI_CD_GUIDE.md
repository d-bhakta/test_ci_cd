# Flutter CI/CD Pipeline Guide

## 🎯 Overview

This repository uses a production-ready CI/CD pipeline with **combined versioning strategy**:

- **Main Branch**: Manual version control (production releases)
- **Staging Branch**: Auto-increment build numbers (testing releases)

## 📋 Version Format

### Main Branch (Production)

```
Format: X.Y.Z+BUILD.HASH
Example: 1.2.3+45.a3f7b2c

X.Y.Z = Manually controlled version
BUILD = Auto-incremented build number
HASH = Git commit hash (for traceability)
```

### Staging Branch

```
Format: X.Y.Z-staging+BUILD.HASH
Example: 1.2.3-staging+127.b5e9f1a

X.Y.Z = Base version from pubspec.yaml
-staging = Suffix to identify staging builds
BUILD = Auto-incremented based on staging commits
HASH = Git commit hash
```

## 🚀 How to Use

### For Production Release (Main Branch)

1. **Update Version in pubspec.yaml** (Manual Control)
   ```yaml
   # pubspec.yaml
   version: 1.3.0+1  # Update the X.Y.Z part manually
   ```

2. **Commit and Push to Main**
   ```bash
   git checkout main
   git add pubspec.yaml
   git commit -m "feat: new feature for v1.3.0"
   git push origin main
   ```

3. **Pipeline Automatically**:
    - ✅ Runs tests and code analysis
    - ✅ Auto-increments build number (1 → 2)
    - ✅ Adds commit hash: `1.3.0+2.a3f7b2c`
    - ✅ Builds APK and AAB
    - ✅ Creates GitHub Release with tag `v1.3.0+2.a3f7b2c`
    - ✅ Uploads artifacts

4. **Result**: Production release with your manually controlled version!

### For Staging Release (Staging Branch)

1. **No Manual Version Update Needed**
    - Keep the base version in pubspec.yaml as is
    - Build number auto-increments automatically

2. **Just Push to Staging**
   ```bash
   git checkout staging
   git add .
   git commit -m "test: testing new feature"
   git push origin staging
   ```

3. **Pipeline Automatically**:
    - ✅ Runs tests and code analysis
    - ✅ Auto-calculates build number from commit count
    - ✅ Adds `-staging` suffix
    - ✅ Adds commit hash
    - ✅ Builds APK and AAB
    - ✅ Creates GitHub Pre-release with tag `staging-v1.2.3-staging+127.b5e9f1a`
    - ✅ Uploads artifacts

4. **Result**: Staging release with auto-versioning!

## 📦 Pipeline Jobs

### 1. Version Management

- Calculates version based on branch
- Main: Uses manual version + auto build number
- Staging: Auto-increments build + adds suffix

### 2. Test & Code Quality

- Format verification
- Code analysis (`flutter analyze`)
- Unit and widget tests
- Coverage report generation

### 3. Build Android

- Builds APK for distribution
- Builds AAB for Play Store
- Names artifacts with version and branch

### 4. Release

- **Staging**: Creates pre-release with staging tag
- **Production**: Creates full release with changelog

### 5. Build Summary

- Generates summary in GitHub Actions UI

## 🎨 Version Bump Guide (Main Branch Only)

When to bump which version number:

| Change Type      | Example                        | Version Bump              |
|------------------|--------------------------------|---------------------------|
| Breaking changes | Complete redesign, API changes | `2.0.0` → `3.0.0` (MAJOR) |
| New features     | New screens, functionality     | `1.2.3` → `1.3.0` (MINOR) |
| Bug fixes        | Crash fixes, UI tweaks         | `1.2.3` → `1.2.4` (PATCH) |

### Example Workflow

```bash
# Bug Fix Release
# Update pubspec.yaml: 1.2.3 → 1.2.4
git checkout main
sed -i 's/version: 1.2.3/version: 1.2.4/' pubspec.yaml
git commit -m "fix: resolve login crash"
git push origin main
# Pipeline creates: 1.2.4+46.c8d2e1f

# New Feature Release
# Update pubspec.yaml: 1.2.4 → 1.3.0
sed -i 's/version: 1.2.4/version: 1.3.0/' pubspec.yaml
git commit -m "feat: add dark mode"
git push origin main
# Pipeline creates: 1.3.0+47.d9e3f2g

# Breaking Change Release
# Update pubspec.yaml: 1.3.0 → 2.0.0
sed -i 's/version: 1.3.0/version: 2.0.0/' pubspec.yaml
git commit -m "feat!: new navigation system (breaking)"
git push origin main
# Pipeline creates: 2.0.0+48.e1f4g3h
```

## 📥 Artifacts

After each build, the following artifacts are available:

1. **APK Files**: For direct installation
    - `app-main-{version}.apk` (production)
    - `app-staging-{version}.apk` (staging)

2. **AAB Files**: For Play Store
    - `app-main-{version}.aab` (production)
    - `app-staging-{version}.aab` (staging)

3. **Coverage Report**: `coverage/lcov.info`

## 🔍 Viewing Releases

### Production Releases

```
https://github.com/d-bhakta/test_ci_cd/releases
Look for: v1.2.3+45.a3f7b2c (no "staging" in name)
```

### Staging Releases

```
https://github.com/d-bhakta/test_ci_cd/releases
Look for: staging-v1.2.3-staging+127.b5e9f1a (marked as pre-release)
```

## 🔧 Configuration

### Required GitHub Settings

No secrets required for basic functionality! However, for advanced features:

```yaml
# Optional secrets for Play Store deployment
GOOGLE_PLAY_SERVICE_ACCOUNT: "{ ... }"  # For auto-deployment
KEYSTORE_BASE64: "..."                   # For app signing
```

### Branch Protection (Recommended)

```
Main Branch:
✅ Require pull request reviews before merging
✅ Require status checks to pass (test-and-analyze)
✅ Require branches to be up to date
```

## 🎯 Best Practices

### For Development Team

1. **Always test on staging first**
   ```bash
   git checkout staging
   # ... make changes ...
   git push origin staging
   # Wait for staging build to succeed
   ```

2. **Only merge to main when staging is validated**
   ```bash
   git checkout main
   git merge staging
   # Update version in pubspec.yaml if needed
   git push origin main
   ```

3. **Use conventional commits** (recommended)
   ```
   feat: add new feature
   fix: resolve bug
   docs: update documentation
   test: add tests
   chore: maintenance tasks
   ```

### Version Management Strategy

```
Staging: 1.2.3-staging+200.x → 1.2.3-staging+201.y → 1.2.3-staging+202.z
                                                       ↓
                                                    (validated)
                                                       ↓
Main:    1.2.3+45.a → Update to 1.2.4 → 1.2.4+46.b (PRODUCTION RELEASE)
```

## 🐛 Troubleshooting

### Pipeline fails on version-management job

```bash
# Ensure pubspec.yaml has valid version format
version: 1.0.0+1  # ✅ Correct
version: 1.0.0    # ❌ Missing build number
```

### Build number not incrementing

```bash
# Check git history is available
git fetch --unshallow  # If using shallow clone
```

### Release not created

```bash
# Ensure GITHUB_TOKEN has write permissions
# Check repository Settings > Actions > General > Workflow permissions
# Select: "Read and write permissions"
```

## 📊 Monitoring

Check build status:

```
https://github.com/d-bhakta/test_ci_cd/actions
```

View release history:

```
https://github.com/d-bhakta/test_ci_cd/releases
```

## 🎉 Quick Reference

```bash
# Staging Release (Auto-version)
git checkout staging
git commit -m "test: feature testing"
git push origin staging
# → Creates: staging-v1.2.3-staging+X.hash

# Production Release (Manual version)
git checkout main
# Edit pubspec.yaml version: 1.2.3 → 1.2.4
git commit -m "feat: new release"
git push origin main
# → Creates: v1.2.4+Y.hash
```

---

**Pipeline Status
**: [![Flutter CI/CD Pipeline](https://github.com/d-bhakta/test_ci_cd/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/d-bhakta/test_ci_cd/actions/workflows/flutter_ci.yml)
