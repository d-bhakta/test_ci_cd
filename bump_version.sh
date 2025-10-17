#!/bin/bash

# Flutter Version Bump Helper Script
# Usage: ./bump_version.sh [major|minor|patch]

set -e

VERSION_FILE="pubspec.yaml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current version
get_current_version() {
    grep '^version:' $VERSION_FILE | sed 's/version: //' | tr -d ' ' | cut -d'+' -f1 | cut -d'-' -f1
}

# Display usage
usage() {
    echo -e "${BLUE}Flutter Version Bump Helper${NC}"
    echo ""
    echo "Usage: $0 [major|minor|patch]"
    echo ""
    echo "Examples:"
    echo "  $0 patch   # 1.2.3 → 1.2.4 (bug fixes)"
    echo "  $0 minor   # 1.2.3 → 1.3.0 (new features)"
    echo "  $0 major   # 1.2.3 → 2.0.0 (breaking changes)"
    echo ""
    exit 1
}

# Validate we're on main branch
validate_branch() {
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_BRANCH" != "main" ]; then
        echo -e "${RED}❌ Error: You must be on 'main' branch to bump version${NC}"
        echo -e "   Current branch: ${YELLOW}$CURRENT_BRANCH${NC}"
        echo -e "   Run: ${GREEN}git checkout main${NC}"
        exit 1
    fi
}

# Check for uncommitted changes
check_git_status() {
    if [[ -n $(git status -s) ]]; then
        echo -e "${RED}❌ Error: You have uncommitted changes${NC}"
        echo -e "   Please commit or stash your changes first"
        git status -s
        exit 1
    fi
}

# Bump version
bump_version() {
    local bump_type=$1
    local current=$(get_current_version)
    
    IFS='.' read -r major minor patch <<< "$current"
    
    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo -e "${RED}❌ Invalid bump type: $bump_type${NC}"
            usage
            ;;
    esac
    
    new_version="${major}.${minor}.${patch}"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📦 Version Bump${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Current: ${YELLOW}$current${NC}"
    echo -e "  New:     ${GREEN}$new_version${NC}"
    echo -e "  Type:    ${BLUE}$bump_type${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Confirmation
    read -p "Continue with version bump? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⚠️  Version bump cancelled${NC}"
        exit 0
    fi
    
    # Update pubspec.yaml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version: .*/version: ${new_version}+1/" $VERSION_FILE
    else
        # Linux
        sed -i "s/^version: .*/version: ${new_version}+1/" $VERSION_FILE
    fi
    
    echo -e "${GREEN}✅ Updated $VERSION_FILE${NC}"
    
    # Show the change
    echo ""
    echo -e "${BLUE}Changed line:${NC}"
    grep "^version:" $VERSION_FILE
    echo ""
    
    # Git commit
    read -p "Commit and push changes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add $VERSION_FILE
        
        # Suggest commit message
        case $bump_type in
            major)
                commit_msg="chore: bump version to $new_version (major release)"
                ;;
            minor)
                commit_msg="chore: bump version to $new_version (feature release)"
                ;;
            patch)
                commit_msg="chore: bump version to $new_version (patch release)"
                ;;
        esac
        
        echo -e "${BLUE}Commit message:${NC} $commit_msg"
        git commit -m "$commit_msg"
        
        echo ""
        echo -e "${GREEN}✅ Changes committed${NC}"
        echo ""
        echo -e "${YELLOW}Ready to push to main branch?${NC}"
        echo -e "  This will trigger the CI/CD pipeline"
        echo ""
        read -p "Push to origin main? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin main
            echo ""
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${GREEN}🚀 Successfully pushed to main!${NC}"
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${BLUE}📊 Monitor the pipeline:${NC}"
            echo -e "   https://github.com/d-bhakta/test_ci_cd/actions"
            echo ""
            echo -e "${BLUE}📦 Release will be created at:${NC}"
            echo -e "   https://github.com/d-bhakta/test_ci_cd/releases"
            echo ""
        else
            echo -e "${YELLOW}⚠️  Not pushed. Run manually:${NC}"
            echo -e "   ${GREEN}git push origin main${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Not committed. Review changes:${NC}"
        echo -e "   ${GREEN}git diff $VERSION_FILE${NC}"
        echo ""
        echo -e "${YELLOW}To commit manually:${NC}"
        echo -e "   ${GREEN}git add $VERSION_FILE${NC}"
        echo -e "   ${GREEN}git commit -m \"$commit_msg\"${NC}"
        echo -e "   ${GREEN}git push origin main${NC}"
    fi
}

# Main
main() {
    # Check arguments
    if [ $# -eq 0 ]; then
        usage
    fi
    
    echo ""
    echo -e "${BLUE}🔍 Validating environment...${NC}"
    
    # Validate
    validate_branch
    check_git_status
    
    echo -e "${GREEN}✅ All checks passed${NC}"
    echo ""
    
    # Bump version
    bump_version $1
}

main "$@"
