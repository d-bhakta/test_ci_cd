# 🚀 CI/CD Pipeline Quick Reference

## 📊 Version Format Reference

```
┌─────────────────────────────────────────────────────────────┐
│                    PRODUCTION (main)                         │
│                                                              │
│   Format:  X.Y.Z+BUILD.HASH                                 │
│   Example: 1.2.3+45.a3f7b2c                                 │
│                                                              │
│   X.Y.Z  = Manual (Developer controlled)                    │
│   BUILD  = Auto-increment                                    │
│   HASH   = Git commit hash                                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    STAGING (staging)                         │
│                                                              │
│   Format:  X.Y.Z-staging+BUILD.HASH                         │
│   Example: 1.2.3-staging+127.b5e9f1a                        │
│                                                              │
│   X.Y.Z     = Base version from pubspec.yaml                │
│   -staging  = Environment suffix                             │
│   BUILD     = Auto-increment                                 │
│   HASH      = Git commit hash                                │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Command Cheat Sheet

### Production Release (Main Branch)

```powershell
# Windows PowerShell
.\bump_version.ps1 patch    # Bug fixes:    1.2.3 → 1.2.4
.\bump_version.ps1 minor    # New features: 1.2.3 → 1.3.0
.\bump_version.ps1 major    # Breaking:     1.2.3 → 2.0.0
```

```bash
# Linux/Mac
./bump_version.sh patch     # Bug fixes:    1.2.3 → 1.2.4
./bump_version.sh minor     # New features: 1.2.3 → 1.3.0
./bump_version.sh major     # Breaking:     1.2.3 → 2.0.0
```

### Staging Release

```bash
# Just push - auto-versioning handles the rest!
git checkout staging
git add .
git commit -m "test: feature testing"
git push origin staging
```

## 🔄 Complete Workflow

### Option 1: Feature Development → Staging → Production

```bash
# 1. Create feature branch
git checkout -b feature/new-calculator
# ... develop feature ...
git commit -m "feat: add scientific calculator"
git push origin feature/new-calculator

# 2. Merge to staging for testing
git checkout staging
git merge feature/new-calculator
git push origin staging
# ✅ CI builds: 1.2.3-staging+200.x

# 3. Test staging build, then merge to main
git checkout main
git merge staging

# 4. Update version for production
.\bump_version.ps1 minor    # 1.2.3 → 1.3.0
# or edit pubspec.yaml manually

# 5. Push to trigger production build
git push origin main
# ✅ CI builds: 1.3.0+46.y
```

### Option 2: Hotfix on Production

```bash
# 1. Create hotfix from main
git checkout main
git checkout -b hotfix/login-crash

# 2. Fix the bug
# ... fix code ...
git commit -m "fix: resolve login crash"

# 3. Merge back to main
git checkout main
git merge hotfix/login-crash

# 4. Bump patch version
.\bump_version.ps1 patch    # 1.3.0 → 1.3.1

# 5. Push immediately
git push origin main
# ✅ CI builds: 1.3.1+47.z

# 6. Also merge to staging
git checkout staging
git merge main
git push origin staging
```

## 📦 Pipeline Flow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│  PUSH TO BRANCH                                              │
│  (main or staging)                                           │
└────────────────┬─────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────┐
│  JOB 1: VERSION MANAGEMENT                                   │
│  • Detect branch (main/staging)                              │
│  • Calculate version                                          │
│  • Update pubspec.yaml                                        │
│  • Upload versioned pubspec                                   │
└────────────────┬─────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────┐
│  JOB 2: TEST & CODE QUALITY                                  │
│  • dart format --check                                        │
│  • flutter analyze                                            │
│  • flutter test --coverage                                    │
│  • Upload coverage report                                     │
└────────────────┬─────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────┐
│  JOB 3: BUILD ANDROID                                        │
│  • Download versioned pubspec                                 │
│  • flutter build apk --release                                │
│  • flutter build appbundle --release                          │
│  • Rename artifacts with version                              │
│  • Upload APK & AAB                                           │
└────────────────┬─────────────────────────────────────────────┘
                 │
                 ▼
         ┌───────┴────────┐
         │                │
         ▼                ▼
┌──────────────┐  ┌──────────────┐
│  STAGING     │  │  PRODUCTION  │
│  RELEASE     │  │  RELEASE     │
│              │  │              │
│ • Pre-release│  │ • Full       │
│ • Tag:       │  │   release    │
│   staging-v* │  │ • Tag: v*    │
│ • APK + AAB  │  │ • APK + AAB  │
│ • Changelog  │  │ • Changelog  │
└──────────────┘  └──────────────┘
```

## 🎨 Version Bump Decision Tree

```
                     ┌─────────────┐
                     │  What type  │
                     │  of change? │
                     └──────┬──────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
            ▼               ▼               ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │   BREAKING   │ │  NEW FEATURE │ │   BUG FIX    │
    │   CHANGES    │ │   BACKWARD   │ │   BACKWARD   │
    │              │ │  COMPATIBLE  │ │  COMPATIBLE  │
    └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
           │                │                │
           ▼                ▼                ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │  BUMP MAJOR  │ │  BUMP MINOR  │ │  BUMP PATCH  │
    │  1.2.3 → 2.0.0│ │  1.2.3 → 1.3.0│ │  1.2.3 → 1.2.4│
    └──────────────┘ └──────────────┘ └──────────────┘

Examples:
• Major: Complete UI redesign, Remove features, Change API
• Minor: Add dark mode, New screen, Additional features
• Patch: Fix crash, Update text, Performance improvement
```

## 📍 Important Links

```
┌─────────────────────────────────────────────────────────────┐
│  GitHub Actions (Monitor Pipeline)                          │
│  https://github.com/d-bhakta/test_ci_cd/actions            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  GitHub Releases (Download Builds)                          │
│  https://github.com/d-bhakta/test_ci_cd/releases           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Repository Settings                                         │
│  https://github.com/d-bhakta/test_ci_cd/settings           │
└─────────────────────────────────────────────────────────────┘
```

## 🔍 Artifact Naming Convention

```
Production Build (main branch):
• APK: app-main-1.2.3+45.a3f7b2c.apk
• AAB: app-main-1.2.3+45.a3f7b2c.aab

Staging Build (staging branch):
• APK: app-staging-1.2.3-staging+127.b5e9f1a.apk
• AAB: app-staging-1.2.3-staging+127.b5e9f1a.aab
```

## ⚡ One-Liner Commands

```bash
# Quick status check
git status && flutter test && flutter analyze

# Format and commit
dart format . && git add . && git commit -m "style: format code"

# Full local validation (before push)
flutter clean && flutter pub get && flutter test --coverage && flutter analyze && flutter build apk --release

# Check current version
grep "^version:" pubspec.yaml

# View recent releases
git tag -l | tail -10

# View pipeline runs
gh run list --limit 5  # requires GitHub CLI
```

## 🎭 Environment Comparison

```
┌────────────────┬─────────────────┬────────────────────┐
│   Property     │    STAGING      │    PRODUCTION      │
├────────────────┼─────────────────┼────────────────────┤
│ Branch         │ staging         │ main               │
│ Version        │ Auto-increment  │ Manual control     │
│ Suffix         │ -staging        │ (none)             │
│ Release Type   │ Pre-release     │ Full release       │
│ Testing        │ Internal QA     │ Public users       │
│ Frequency      │ Multiple/day    │ Weekly/Bi-weekly   │
│ Rollback       │ Easy            │ Managed            │
│ Distribution   │ GitHub only     │ Play Store ready   │
└────────────────┴─────────────────┴────────────────────┘
```

## 🚨 Common Issues & Quick Fixes

```
Issue: Pipeline won't start
Fix:   Check Settings → Actions → Enable workflows

Issue: Version conflict
Fix:   Ensure pubspec.yaml format: "version: X.Y.Z+B"

Issue: Tests fail in CI
Fix:   Run locally: flutter test --reporter expanded

Issue: Build fails
Fix:   Run: flutter clean && flutter pub get

Issue: No release created
Fix:   Settings → Actions → Set "Read & write permissions"

Issue: Wrong version in build
Fix:   Download versioned pubspec from artifacts
```

## 📊 Success Indicators

```
✅ Pipeline Status:  All jobs green
✅ Test Coverage:    > 80%
✅ Build Time:       < 10 minutes
✅ Artifacts:        APK + AAB generated
✅ Release:          Created with correct tag
✅ Version:          Matches expectation
```

## 🎓 Learning Resources

```
📚 Full Documentation:       CI_CD_GUIDE.md
✅ Deployment Checklist:     DEPLOYMENT_CHECKLIST.md
📖 README:                   README.md
🧪 Testing Guide:            BLOC_TESTING_DOC.md
```

---

**Pro Tip**: Bookmark this page for quick reference during releases! 🚀
