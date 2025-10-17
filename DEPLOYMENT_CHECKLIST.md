# CI/CD Pipeline Checklist

## ✅ Pre-Flight Checklist

Before pushing to trigger the CI/CD pipeline, ensure:

### Local Checks

- [ ] All tests pass locally: `flutter test`
- [ ] Code is properly formatted: `dart format .`
- [ ] No analysis issues: `flutter analyze`
- [ ] Dependencies are up to date: `flutter pub get`
- [ ] Git branch is correct (`main` or `staging`)
- [ ] All changes are committed

### Version Management (Main Branch Only)

- [ ] Version updated in `pubspec.yaml` (for production releases)
- [ ] Version follows semantic versioning (X.Y.Z+BUILD)
- [ ] CHANGELOG.md updated (optional but recommended)
- [ ] Version bump type is correct:
    - **Patch** (1.2.3 → 1.2.4): Bug fixes only
    - **Minor** (1.2.3 → 1.3.0): New features, backward compatible
    - **Major** (1.2.3 → 2.0.0): Breaking changes

### Repository Settings

- [ ] GitHub Actions enabled
- [ ] Workflow permissions set to "Read and write"
    - Settings → Actions → General → Workflow permissions
- [ ] Branches exist: `main` and `staging`

## 🚀 Deployment Checklist

### For Staging Release

```bash
# 1. Switch to staging
git checkout staging

# 2. Make changes
# ... your code changes ...

# 3. Run tests
flutter test

# 4. Commit and push (auto-versioning)
git add .
git commit -m "test: your changes"
git push origin staging

# 5. Monitor pipeline
# https://github.com/d-bhakta/test_ci_cd/actions
```

### For Production Release

```bash
# 1. Switch to main
git checkout main

# 2. Update version (choose one method)

# Method A: Using helper script (Windows)
.\bump_version.ps1 patch  # or minor, major

# Method B: Using helper script (Linux/Mac)
./bump_version.sh patch  # or minor, major

# Method C: Manual edit pubspec.yaml
# Change: version: 1.2.3+1
#      to: version: 1.2.4+1

# 3. The script handles commit and push
# Or manually:
git add pubspec.yaml
git commit -m "chore: bump version to 1.2.4"
git push origin main

# 4. Monitor pipeline
# https://github.com/d-bhakta/test_ci_cd/actions

# 5. Verify release
# https://github.com/d-bhakta/test_ci_cd/releases
```

## 🔍 Pipeline Verification

### Check Pipeline Status

1. Go to: https://github.com/d-bhakta/test_ci_cd/actions
2. Find your workflow run
3. Check each job status:
    - ✅ Version Management
    - ✅ Test & Code Quality
    - ✅ Build Android
    - ✅ Release (staging or production)
    - ✅ Build Summary

### Check Release

1. Go to: https://github.com/d-bhakta/test_ci_cd/releases
2. Verify:
    - **Main**: Look for `v1.2.3+45.a3f7b2c` (production release)
    - **Staging**: Look for `staging-v1.2.3-staging+127.b5e9f1a` (pre-release)
3. Download and test APK/AAB

## 🐛 Troubleshooting

### Pipeline Fails on Version Management

**Problem**: Version calculation fails
**Solution**:

```bash
# Ensure pubspec.yaml has valid format
version: 1.0.0+1  # ✅ Correct format
version: 1.0.0    # ❌ Missing build number
```

### Pipeline Fails on Tests

**Problem**: Tests fail in CI but pass locally
**Solution**:

```bash
# Run tests with same flags as CI
flutter test --coverage --reporter expanded

# Check for environment-specific issues
# Ensure no hardcoded paths or local dependencies
```

### Pipeline Fails on Build

**Problem**: Build fails in CI
**Solution**:

```bash
# Run clean build locally
flutter clean
flutter pub get
flutter build apk --release

# Check gradle files for issues
# Verify Flutter SDK version matches CI (3.24.0)
```

### Release Not Created

**Problem**: Build succeeds but no release
**Solution**:

1. Check workflow permissions:
    - Settings → Actions → General
    - Set "Read and write permissions"
2. Verify GITHUB_TOKEN has access
3. Check branch condition matches (main or staging)

### Build Number Not Incrementing

**Problem**: Same build number on multiple builds
**Solution**:

```bash
# Fetch full git history
git fetch --unshallow

# Verify commit count
git rev-list --count HEAD
```

## 📊 Monitoring Dashboard

### Key Metrics to Monitor

- ✅ **Build Success Rate**: Target >95%
- ✅ **Test Coverage**: Target >80%
- ✅ **Build Time**: Monitor for increases
- ✅ **Artifact Size**: APK/AAB file sizes

### Regular Maintenance

- [ ] Weekly: Review failed builds
- [ ] Weekly: Check test coverage trends
- [ ] Monthly: Update Flutter SDK version
- [ ] Monthly: Update dependencies
- [ ] Quarterly: Review and optimize pipeline

## 🎯 Best Practices

### Do's ✅

- ✅ Always test on staging before production
- ✅ Use semantic versioning correctly
- ✅ Write meaningful commit messages
- ✅ Keep CHANGELOG updated
- ✅ Monitor pipeline execution
- ✅ Test downloaded artifacts before distribution

### Don'ts ❌

- ❌ Don't push directly to main without testing
- ❌ Don't skip version updates on main
- ❌ Don't ignore pipeline failures
- ❌ Don't commit sensitive data
- ❌ Don't bypass code quality checks
- ❌ Don't merge unreviewed code to main

## 🔐 Security Checklist

- [ ] No API keys in code
- [ ] No passwords in repository
- [ ] Secrets stored in GitHub Secrets only
- [ ] Signing keys not committed
- [ ] Environment variables used for config
- [ ] Dependencies regularly updated
- [ ] Security scanning enabled (optional)

## 📈 Release Cadence

### Recommended Schedule

```
Staging: Multiple times per day (as needed)
   ↓
Testing: 1-3 days
   ↓
Production: Weekly or bi-weekly
   ↓
Hotfixes: As needed (expedited process)
```

### Release Types

| Type            | Branch    | Frequency        | Example             |
|-----------------|-----------|------------------|---------------------|
| **Development** | feature/* | Continuous       | -                   |
| **Staging**     | staging   | Daily/On-demand  | `1.2.3-staging+127` |
| **Production**  | main      | Weekly/Bi-weekly | `1.2.3+45`          |
| **Hotfix**      | main      | Emergency        | `1.2.4+46`          |

## 📝 Post-Release Checklist

After successful release:

- [ ] Verify release artifacts are downloadable
- [ ] Test APK installation on device
- [ ] Verify app launches and core features work
- [ ] Check crash reporting (if integrated)
- [ ] Update documentation if needed
- [ ] Communicate release to team
- [ ] Monitor user feedback
- [ ] Track crash rates and performance

## 🎉 Success Criteria

A successful release includes:

- ✅ All pipeline jobs passed
- ✅ Artifacts generated and available
- ✅ GitHub release created with notes
- ✅ APK/AAB tested on devices
- ✅ No critical bugs reported
- ✅ Version correctly tagged in git

---

**Next Steps**:

1. Review this checklist before each release
2. Add items specific to your project
3. Keep this document updated with lessons learned
