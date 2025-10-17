# Flutter Version Bump Helper Script (PowerShell)
# Usage: .\bump_version.ps1 [major|minor|patch]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('major','minor','patch')]
    [string]$BumpType
)

$VersionFile = "pubspec.yaml"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Get current version
function Get-CurrentVersion {
    $content = Get-Content $VersionFile
    $versionLine = $content | Select-String -Pattern "^version:"
    if ($versionLine) {
        $version = $versionLine.ToString() -replace "version:\s*", ""
        $version = $version.Split('+')[0].Split('-')[0].Trim()
        return $version
    }
    return $null
}

# Validate we're on main branch
function Test-MainBranch {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    if ($currentBranch -ne "main") {
        Write-ColorOutput Red "❌ Error: You must be on 'main' branch to bump version"
        Write-Host "   Current branch: " -NoNewline
        Write-ColorOutput Yellow $currentBranch
        Write-ColorOutput Green "   Run: git checkout main"
        exit 1
    }
}

# Check for uncommitted changes
function Test-GitStatus {
    $status = git status --short
    if ($status) {
        Write-ColorOutput Red "❌ Error: You have uncommitted changes"
        Write-Host "   Please commit or stash your changes first"
        git status --short
        exit 1
    }
}

# Bump version
function Update-Version {
    param([string]$Type)
    
    $current = Get-CurrentVersion
    if (-not $current) {
        Write-ColorOutput Red "❌ Error: Could not read version from $VersionFile"
        exit 1
    }
    
    $parts = $current.Split('.')
    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]
    
    switch ($Type) {
        'major' {
            $major++
            $minor = 0
            $patch = 0
        }
        'minor' {
            $minor++
            $patch = 0
        }
        'patch' {
            $patch++
        }
    }
    
    $newVersion = "$major.$minor.$patch"
    
    Write-Host ""
    Write-ColorOutput Cyan "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-ColorOutput Green "📦 Version Bump"
    Write-ColorOutput Cyan "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "  Current: " -NoNewline
    Write-ColorOutput Yellow $current
    Write-Host "  New:     " -NoNewline
    Write-ColorOutput Green $newVersion
    Write-Host "  Type:    " -NoNewline
    Write-ColorOutput Cyan $Type
    Write-ColorOutput Cyan "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host ""
    
    # Confirmation
    $confirm = Read-Host "Continue with version bump? (y/n)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-ColorOutput Yellow "⚠️  Version bump cancelled"
        exit 0
    }
    
    # Update pubspec.yaml
    $content = Get-Content $VersionFile
    $newContent = $content -replace "^version:.*", "version: ${newVersion}+1"
    $newContent | Set-Content $VersionFile
    
    Write-ColorOutput Green "✅ Updated $VersionFile"
    
    # Show the change
    Write-Host ""
    Write-ColorOutput Cyan "Changed line:"
    Get-Content $VersionFile | Select-String -Pattern "^version:"
    Write-Host ""
    
    # Git commit
    $commitConfirm = Read-Host "Commit and push changes? (y/n)"
    if ($commitConfirm -eq 'y' -or $commitConfirm -eq 'Y') {
        git add $VersionFile
        
        # Suggest commit message
        $commitMsg = switch ($Type) {
            'major' { "chore: bump version to $newVersion (major release)" }
            'minor' { "chore: bump version to $newVersion (feature release)" }
            'patch' { "chore: bump version to $newVersion (patch release)" }
        }
        
        Write-ColorOutput Cyan "Commit message: $commitMsg"
        git commit -m $commitMsg
        
        Write-Host ""
        Write-ColorOutput Green "✅ Changes committed"
        Write-Host ""
        Write-ColorOutput Yellow "Ready to push to main branch?"
        Write-Host "  This will trigger the CI/CD pipeline"
        Write-Host ""
        
        $pushConfirm = Read-Host "Push to origin main? (y/n)"
        if ($pushConfirm -eq 'y' -or $pushConfirm -eq 'Y') {
            git push origin main
            
            Write-Host ""
            Write-ColorOutput Green "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            Write-ColorOutput Green "🚀 Successfully pushed to main!"
            Write-ColorOutput Green "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            Write-Host ""
            Write-ColorOutput Cyan "📊 Monitor the pipeline:"
            Write-Host "   https://github.com/d-bhakta/test_ci_cd/actions"
            Write-Host ""
            Write-ColorOutput Cyan "📦 Release will be created at:"
            Write-Host "   https://github.com/d-bhakta/test_ci_cd/releases"
            Write-Host ""
        } else {
            Write-ColorOutput Yellow "⚠️  Not pushed. Run manually:"
            Write-ColorOutput Green "   git push origin main"
        }
    } else {
        Write-ColorOutput Yellow "⚠️  Not committed. Review changes:"
        Write-ColorOutput Green "   git diff $VersionFile"
        Write-Host ""
        Write-ColorOutput Yellow "To commit manually:"
        Write-ColorOutput Green "   git add $VersionFile"
        Write-ColorOutput Green "   git commit -m `"$commitMsg`""
        Write-ColorOutput Green "   git push origin main"
    }
}

# Main
Write-Host ""
Write-ColorOutput Cyan "🔍 Validating environment..."

Test-MainBranch
Test-GitStatus

Write-ColorOutput Green "✅ All checks passed"
Write-Host ""

Update-Version -Type $BumpType
