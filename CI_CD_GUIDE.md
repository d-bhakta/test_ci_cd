# Flutter CI/CD Pipeline - Full Manual Control Guide

## 🎯 Overview

This CI/CD pipeline provides **100% manual control** over version name and version code. You decide
when and how to update versions in `pubspec.yaml`.

## 📋 Version Control Strategy

### Full Manual Control

```yaml
# In pubspec.yaml
version: 1.2.3+45

# 1.2.3 = Version Name (YOU control this)
# 45    = Version Code (YOU control this)
```

**Both version name AND version code are fully manual!**

### Artifact Naming Convention
```
Format: {version}-{projectname}-{release/staging}-{date}.apk

Examples:
- 1.2.3-test_ci_cd-release-2024-10-17.apk
- 1.2.3-test_ci_cd-staging-2024-10-17.apk
- 1.2.3-test_ci_cd-release-2024-10-17.aab (release only)
```

## 🏗️ Build Strategy

### Main Branch (Production/Release)

- ✅ **APK** - Always built
- ✅ **AAB** - Always built (for Play Store)
- ✅ **Auto-tagging** - Creates git tag `v{version_name}`
- ✅ **GitHub Release** - Full release (not pre-release)

### Staging Branch

- ✅ **APK** - Always built
- ❌ **AAB** - NOT built (staging doesn't need Play Store bundle)
- ✅ **Auto-tagging** - Creates git tag `staging-v{version_name}`
- ✅ **GitHub Release** - Pre-release for testing

## 🚀 How to Use

### For Production Release (Main Branch)

1. **Update both version name AND version code in pubspec.yaml**:
   ```yaml
   # pubspec.yaml
   version: 1.3.0+46  # Update BOTH parts manually
   ```

2. **Commit and push**:
   ```bash
   git checkout main
   git add pubspec.yaml
   git commit -m "release: v1.3.0 with new features"
   git push origin main
   ```

3. **Pipeline automatically**:
    - ✅ Reads version: `1.3.0` (name) and `46` (code)
    - ✅ Runs tests and analysis
    - ✅ Builds APK: `1.3.0-test_ci_cd-release-2024-10-17.apk`
    - ✅ Builds AAB: `1.3.0-test_ci_cd-release-2024-10-17.aab`
    - ✅ Creates tag: `v1.3.0`
    - ✅ Creates GitHub Release with artifacts
    - ✅ Release appears at: `https://github.com/d-bhakta/test_ci_cd/releases/tag/v1.3.0`

### For Staging Build

1. **NO version update needed** (or update if you want):
   ```yaml
   # pubspec.yaml
   version: 1.3.0+46  # Can keep same as main or update
   ```

2. **Just push to staging**:
   ```bash
   git checkout staging
   git add .
   git commit -m "test: testing new feature"
   git push origin staging
   ```

3. **Pipeline automatically**:
    - ✅ Reads version from pubspec.yaml
    - ✅ Runs tests and analysis
    - ✅ Builds APK ONLY: `1.3.0-test_ci_cd-staging-2024-10-17.apk`
    - ✅ Creates tag: `staging-v1.3.0`
    - ✅ Creates GitHub Pre-release
    - ✅ Pre-release appears at releases page (marked as pre-release)

## 📦 Pipeline Jobs

### 1. Version Management

- Extracts version name and code from `pubspec.yaml`
- Gets project name from `pubspec.yaml`
- Determines branch type (release/staging)
- Gets current date for artifact naming

### 2. Test & Code Quality

- `dart format --check` - Code formatting
- `flutter analyze` - Static analysis
- `flutter test --coverage` - Unit/widget tests
- Coverage report upload

### 3. Build Android

- **APK**: Always built for both branches
- **AAB**: Only built for main (release) branch
- Artifacts named: `{version}-{project}-{type}-{date}.{ext}`

### 4. Release

- **Main**: Creates full GitHub release with tag `v{version}`
- **Staging**: Creates pre-release with tag `staging-v{version}`
- Auto-generates changelog from git commits

### 5. Build Summary

- Displays build info in GitHub Actions UI
- Shows artifact names
- Shows job results

## 🎨 Version Bump Strategy

Since you have full manual control, you decide when to bump:

| Change Type   | Example           | What to Update          |
|---------------|-------------------|-------------------------|
| Major feature | Complete redesign | `1.2.3+45` → `2.0.0+46` |
| New feature   | Add screen        | `1.2.3+45` → `1.3.0+46` |
| Bug fix       | Fix crash         | `1.2.3+45` → `1.2.4+46` |
| Rebuild       | No code change    | `1.2.3+45` → `1.2.3+46` |

**Remember**: Always increment version code for each build!

### Version Code Best Practices

```
Initial Release:     1.0.0+1
Bug Fix:             1.0.1+2
Feature:             1.1.0+3
Another Feature:     1.2.0+4
Major Release:       2.0.0+5
```

**Never reuse a version code!** Google Play Store requires each upload to have a unique version
code.

## 🔍 Viewing Releases

### Production Releases
```
URL: https://github.com/d-bhakta/test_ci_cd/releases
Tag: v1.2.3
Files:
  - 1.2.3-test_ci_cd-release-2024-10-17.apk
  - 1.2.3-test_ci_cd-release-2024-10-17.aab
```

### Staging Releases
```
URL: https://github.com/d-bhakta/test_ci_cd/releases
Tag: staging-v1.2.3
Badge: Pre-release
Files:
  - 1.2.3-test_ci_cd-staging-2024-10-17.apk
```

## 📊 Complete Workflow Example

### Scenario: Release Version 1.5.0

```bash
# 1. Start from main
git checkout main
git pull origin main

# 2. Update version in pubspec.yaml
# Change: version: 1.4.0+44
# To:     version: 1.5.0+45

# 3. Commit version bump
git add pubspec.yaml
git commit -m "release: bump version to 1.5.0"

# 4. Push to trigger pipeline
git push origin main

# 5. Monitor pipeline
# Go to: https://github.com/d-bhakta/test_ci_cd/actions

# 6. Check release (after ~5-10 minutes)
# Go to: https://github.com/d-bhakta/test_ci_cd/releases/tag/v1.5.0

# 7. Download and test artifacts:
# - 1.5.0-test_ci_cd-release-2024-10-17.apk
# - 1.5.0-test_ci_cd-release-2024-10-17.aab
```

## 🛠️ Helper Scripts

### PowerShell (Windows)

```powershell
# Update version in pubspec.yaml
.\bump_version.ps1 patch    # 1.2.3+45 → 1.2.4+46
.\bump_version.ps1 minor    # 1.2.3+45 → 1.3.0+46
.\bump_version.ps1 major    # 1.2.3+45 → 2.0.0+46
```

### Bash (Linux/Mac)
```bash
# Update version in pubspec.yaml
./bump_version.sh patch    # 1.2.3+45 → 1.2.4+46
./bump_version.sh minor    # 1.2.3+45 → 1.3.0+46
./bump_version.sh major    # 1.2.3+45 → 2.0.0+46
```

**Note**: These scripts automatically increment version code!

## 🎯 Key Differences from Auto-Versioning

| Feature        | This Pipeline   | Auto-Versioning  |
|----------------|-----------------|------------------|
| Version Name   | ✅ Manual        | ❌ Auto-generated |
| Version Code   | ✅ Manual        | ❌ Auto-generated |
| Control        | 100% You        | Pipeline decides |
| Flexibility    | Maximum         | Limited          |
| Predictability | High            | Medium           |
| Best For       | Production apps | Dev/testing      |

## 🔐 GitHub Settings Required

### Enable Actions

1. Go to: Repository Settings → Actions → General
2. Enable: "Allow all actions and reusable workflows"

### Workflow Permissions

1. Go to: Repository Settings → Actions → General
2. Scroll to "Workflow permissions"
3. Select: "Read and write permissions"
4. Check: "Allow GitHub Actions to create and approve pull requests"

### Branch Protection (Optional but Recommended)

```
Main Branch:
✅ Require pull request reviews
✅ Require status checks to pass
✅ Require branches to be up to date
```

## 📝 Troubleshooting

### Problem: Pipeline fails on version extraction

```
Solution: Ensure pubspec.yaml has correct format:
version: 1.2.3+45  ✅ Correct
version: 1.2.3     ❌ Missing version code
version:1.2.3+45   ❌ Missing space after colon
```

### Problem: No AAB generated for staging

```
Solution: This is expected! AAB is only built for main (release) branch.
Staging builds only generate APK.
```

### Problem: Tag already exists

```
Solution: Either:
1. Delete the tag: git tag -d v1.2.3 && git push origin :refs/tags/v1.2.3
2. Bump to a new version: Update version in pubspec.yaml
```

### Problem: Release not created

```
Solution: Check workflow permissions (see GitHub Settings above)
```

## 🎉 Success Indicators

After pipeline completes:

✅ **GitHub Actions**: All jobs green  
✅ **Artifacts**: Named correctly with date  
✅ **Tag**: Created in repository  
✅ **Release**: Visible on releases page  
✅ **Files**: APK (always) + AAB (release only)

## 📚 Additional Resources

- [GitHub Releases](https://github.com/d-bhakta/test_ci_cd/releases)
- [GitHub Actions](https://github.com/d-bhakta/test_ci_cd/actions)
- [Semantic Versioning](https://semver.org/)
- [Android Version Codes](https://developer.android.com/studio/publish/versioning)

---

**Pipeline Status
**: [![Flutter CI/CD Pipeline](https://github.com/d-bhakta/test_ci_cd/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/d-bhakta/test_ci_cd/actions/workflows/flutter_ci.yml)
