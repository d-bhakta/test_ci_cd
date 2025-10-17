# 🚀 CI/CD Pipeline Quick Reference

## 📊 Version Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         FULL MANUAL CONTROL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pubspec.yaml format:
version: X.Y.Z+CODE

Example:
version: 1.2.3+45

X.Y.Z = Version Name (Manual)
CODE  = Version Code (Manual)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 📦 Artifact Naming

```
Format:
{version}-{projectname}-{release/staging}-{date}.apk

Examples:
✅ 1.2.3-test_ci_cd-release-2024-10-17.apk
✅ 1.2.3-test_ci_cd-release-2024-10-17.aab
✅ 1.2.3-test_ci_cd-staging-2024-10-17.apk
```

## 🏗️ Build Matrix

```
┌──────────────────────────────────────────────┐
│           MAIN BRANCH (Release)              │
├──────────────────────────────────────────────┤
│ ✅ APK  - Always built                       │
│ ✅ AAB  - Always built                       │
│ ✅ Tag  - v{version}                         │
│ ✅ Release - Full release                    │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│          STAGING BRANCH (Testing)            │
├──────────────────────────────────────────────┤
│ ✅ APK  - Always built                       │
│ ❌ AAB  - NOT built                          │
│ ✅ Tag  - staging-v{version}                 │
│ ✅ Release - Pre-release                     │
└──────────────────────────────────────────────┘
```

## ⚡ Quick Commands

### Production Release

```bash
# 1. Update version in pubspec.yaml
#    version: 1.2.3+45 → version: 1.3.0+46

# 2. Commit and push
git checkout main
git add pubspec.yaml
git commit -m "release: v1.3.0"
git push origin main

# Result:
# ✅ Tag: v1.3.0
# ✅ Files: 1.3.0-test_ci_cd-release-{date}.apk
#          1.3.0-test_ci_cd-release-{date}.aab
```

### Staging Build

```bash
# 1. Just push (version optional)
git checkout staging
git add .
git commit -m "test: new feature"
git push origin staging

# Result:
# ✅ Tag: staging-v1.3.0
# ✅ Files: 1.3.0-test_ci_cd-staging-{date}.apk
```

### Using Helper Scripts

```powershell
# Windows
.\bump_version.ps1 patch    # +0.0.1
.\bump_version.ps1 minor    # +0.1.0
.\bump_version.ps1 major    # +1.0.0
```

```bash
# Linux/Mac
./bump_version.sh patch
./bump_version.sh minor
./bump_version.sh major
```

## 🎯 Version Bump Guide

```
┌─────────────┬──────────────┬─────────────────┐
│ Change Type │ Bump Type    │ Example         │
├─────────────┼──────────────┼─────────────────┤
│ Bug Fix     │ PATCH        │ 1.2.3 → 1.2.4   │
│ New Feature │ MINOR        │ 1.2.3 → 1.3.0   │
│ Breaking    │ MAJOR        │ 1.2.3 → 2.0.0   │
│ Rebuild     │ CODE ONLY    │ 1.2.3+45 → +46  │
└─────────────┴──────────────┴─────────────────┘

⚠️  ALWAYS increment version code for each build!
```

## 📍 Important Links

```
GitHub Actions:
https://github.com/d-bhakta/test_ci_cd/actions

GitHub Releases:
https://github.com/d-bhakta/test_ci_cd/releases

Repository Settings:
https://github.com/d-bhakta/test_ci_cd/settings
```

## 🔄 Complete Workflow

```
┌──────────────────────────────────────────────┐
│ 1. Update version in pubspec.yaml           │
│    version: 1.3.0+46                         │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│ 2. Commit and push to main/staging          │
│    git push origin main                      │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│ 3. Pipeline runs automatically               │
│    • Version Management                      │
│    • Test & Code Quality                     │
│    • Build Android (APK + AAB*)              │
│    • Create Release                          │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│ 4. Check releases page                       │
│    Download artifacts with date in name      │
└──────────────────────────────────────────────┘

* AAB only for main branch
```

## 🎨 Pipeline Jobs

```
┌─────────────────────────────────────────────┐
│ Job 1: Version Management                   │
│ • Extract version name & code               │
│ • Get project name                          │
│ • Determine branch type                     │
│ • Get current date                          │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Job 2: Test & Code Quality                  │
│ • dart format --check                       │
│ • flutter analyze                           │
│ • flutter test --coverage                   │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Job 3: Build Android                        │
│ • Build APK (always)                        │
│ • Build AAB (release only)                  │
│ • Rename with date                          │
│ • Upload artifacts                          │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Job 4: Release                              │
│ • Create git tag                            │
│ • Generate changelog                        │
│ • Create GitHub release                     │
│ • Attach artifacts                          │
└─────────────────────────────────────────────┘
```

## 🚨 Common Issues

```
Issue: Invalid version format
Fix:   version: 1.2.3+45  ✅
       version: 1.2.3     ❌ (missing code)

Issue: No AAB for staging
Fix:   Expected! AAB only for main branch

Issue: Tag already exists
Fix:   Bump version in pubspec.yaml

Issue: Release not created
Fix:   Check workflow permissions:
       Settings → Actions → "Read & write"
```

## 📊 Artifact Examples

```
Production (main branch):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 1.5.0-test_ci_cd-release-2024-10-17.apk
✅ 1.5.0-test_ci_cd-release-2024-10-17.aab
Tag: v1.5.0
Type: Full Release

Staging (staging branch):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 1.5.0-test_ci_cd-staging-2024-10-17.apk
Tag: staging-v1.5.0
Type: Pre-release
```

## ✅ Success Checklist

```
After push:
□ Pipeline starts in GitHub Actions
□ All jobs turn green
□ Tag created in repository
□ Release appears on releases page
□ Artifacts named with date
□ APK available for download
□ AAB available (main only)
```

## 🎓 Version Code Rules

```
Rule 1: NEVER reuse a version code
Rule 2: ALWAYS increment for new builds
Rule 3: Version code must be integer
Rule 4: Play Store requires unique codes

Example progression:
1.0.0+1   Initial
1.0.1+2   Bug fix
1.1.0+3   Feature
1.1.1+4   Bug fix
2.0.0+5   Major
```

## 📚 Documentation

```
Full Guide:           CI_CD_GUIDE.md
Deployment Checklist: DEPLOYMENT_CHECKLIST.md
README:               README.md
Testing Guide:        BLOC_TESTING_DOC.md
```

## 🔧 Required Settings

```
✅ Enable GitHub Actions
✅ Set workflow permissions: "Read & write"
✅ Allow Actions to create releases
✅ Branches: main & staging must exist
✅ Valid version in pubspec.yaml
```

## ⚡ One-Liners

```bash
# Check current version
grep "^version:" pubspec.yaml

# View recent tags
git tag -l | tail -5

# View pipeline status
gh run list --limit 3

# Full validation
flutter clean && flutter test && flutter analyze
```

---

**Pro Tip**: Bookmark this page for quick access! 🚀

**Pipeline
**: [![CI/CD](https://github.com/d-bhakta/test_ci_cd/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/d-bhakta/test_ci_cd/actions/workflows/flutter_ci.yml)
