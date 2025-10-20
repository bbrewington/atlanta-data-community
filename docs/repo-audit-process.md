# Repository Audit Process

A comprehensive guide for auditing GitHub repositories to identify cleanup opportunities and maintain a healthy repository portfolio.

## Overview

This process helps you:
- Identify inactive or unnecessary repositories
- Categorize repositories by type and value
- Make data-driven decisions about deletion, archival, or maintenance
- Create actionable cleanup plans

**Recommended frequency:** Annually, or when repository count exceeds comfortable management threshold.

---

## Prerequisites

### Required Tools
```bash
# Install GitHub CLI
brew install gh  # macOS
# or see: https://cli.github.com/

# Authenticate
gh auth login

# Optional: jq for JSON processing
brew install jq
```

### Permissions
- Must have admin access to repositories you want to audit
- For organization repos, need appropriate organization permissions

---

## Phase 1: Data Gathering

### Step 1.1: Get Repository List

```bash
# List all your repositories with key metadata
gh repo list YOUR_USERNAME --limit 1000 --json name,description,pushedAt,stargazerCount,forkCount,isFork,isArchived,primaryLanguage,visibility

# Save to file for analysis
gh repo list YOUR_USERNAME --limit 1000 --json name,description,pushedAt,stargazerCount,forkCount,isFork,isArchived,primaryLanguage,visibility > repos.json
```

### Step 1.2: Get Detailed Repository Information

Create a script to gather detailed info for each repository:

```bash
#!/bin/bash
# save as: gather-repo-details.sh

USERNAME="$1"
OUTPUT_FILE="${2:-repo-details.json}"

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 USERNAME [OUTPUT_FILE]"
  exit 1
fi

echo "Gathering detailed repository information for ${USERNAME}..."
echo "This may take a while..."

# Get list of all repos
REPOS=$(gh repo list ${USERNAME} --limit 1000 --json name --jq '.[].name')

# Create JSON array
echo "[" > "$OUTPUT_FILE"
FIRST=true

for repo in $REPOS; do
  if [ "$FIRST" = false ]; then
    echo "," >> "$OUTPUT_FILE"
  fi
  FIRST=false

  echo "Processing ${USERNAME}/${repo}..."

  # Get comprehensive repo data
  gh api repos/${USERNAME}/${repo} --jq '{
    name: .name,
    description: .description,
    html_url: .html_url,
    created_at: .created_at,
    updated_at: .updated_at,
    pushed_at: .pushed_at,
    size: .size,
    stargazers_count: .stargazers_count,
    watchers_count: .watchers_count,
    forks_count: .forks_count,
    open_issues_count: .open_issues_count,
    is_fork: .fork,
    is_archived: .archived,
    is_private: .private,
    language: .language,
    topics: .topics,
    license: .license.spdx_id,
    default_branch: .default_branch,
    has_wiki: .has_wiki,
    has_pages: .has_pages,
    has_downloads: .has_downloads
  }' >> "$OUTPUT_FILE"

  sleep 0.5  # Rate limiting
done

echo "" >> "$OUTPUT_FILE"
echo "]" >> "$OUTPUT_FILE"

echo "✓ Done! Data saved to ${OUTPUT_FILE}"
```

**Usage:**
```bash
chmod +x gather-repo-details.sh
./gather-repo-details.sh YOUR_USERNAME repo-details.json
```

### Step 1.3: Check Fork Activity

For repositories that are forks, check if you have any custom commits:

```bash
#!/bin/bash
# save as: check-fork-activity.sh

USERNAME="$1"
REPO="$2"

# Get fork info
IS_FORK=$(gh api repos/${USERNAME}/${REPO} --jq '.fork')

if [ "$IS_FORK" = "true" ]; then
  # Get parent repo
  PARENT=$(gh api repos/${USERNAME}/${REPO} --jq '.parent.full_name')

  # Check commit count ahead of parent
  gh api repos/${USERNAME}/${REPO} --jq '.parent.full_name as $parent | "Fork of: \($parent)"'

  # Get last push date
  gh api repos/${USERNAME}/${REPO} --jq '"Last pushed: " + .pushed_at'

  # Check if you have commits not in parent
  echo "Note: To check for custom commits, compare branches manually"
  echo "View: https://github.com/${USERNAME}/${REPO}/compare"
fi
```

### Step 1.4: Analyze Repository Activity

```bash
#!/bin/bash
# save as: analyze-repo-activity.sh

USERNAME="$1"
REPO="$2"

echo "Repository: ${USERNAME}/${REPO}"
echo "---"

# Get last commit info
gh api repos/${USERNAME}/${REPO}/commits?per_page=1 --jq '.[0] | "Last commit: " + .commit.author.date + " by " + .commit.author.name'

# Get total commits
COMMIT_COUNT=$(gh api repos/${USERNAME}/${REPO} --jq '.size')
echo "Approximate commits: ${COMMIT_COUNT}KB of data"

# Check for open issues/PRs
ISSUES=$(gh api repos/${USERNAME}/${REPO} --jq '.open_issues_count')
echo "Open issues/PRs: ${ISSUES}"

# Get contributors
echo "Contributors:"
gh api repos/${USERNAME}/${REPO}/contributors --jq '.[] | "  - " + .login + " (" + (.contributions|tostring) + " contributions)"' | head -5
```

---

## Phase 2: Analysis & Categorization

### Step 2.1: Categorize Repositories

Using the data gathered, categorize each repository:

#### Category 1: Forks
**Subcategories:**
- Unmodified forks (no custom commits)
- Modified forks (has custom commits)
- Active contributor forks (ongoing contributions)

**Decision framework:**
- **Delete**: Unmodified forks with no open PRs
- **Keep**: Active contributor forks or forks with significant custom work
- **Maybe**: Modified forks with minimal changes (consider upstreaming)

#### Category 2: Learning/Sandbox Repositories
**Examples:**
- Tutorial completions
- Course assignments
- Experimentation repos
- Template repositories

**Decision framework:**
- **Delete**: Completed courses/tutorials (knowledge retained elsewhere)
- **Keep**: Active sandbox repos with ongoing experiments
- **Archive**: Completed projects with reference value
- **Consolidate**: Multiple sandbox repos → single "sandbox" repo

#### Category 3: Original Projects
**Subcategories:**
- Active projects (updated within 1 year)
- Maintained projects (updated within 2 years)
- Stale projects (2-5 years since update)
- Abandoned projects (5+ years since update)

**Decision framework based on engagement:**
- High engagement (5+ stars OR 2+ forks): Keep and maintain
- Medium engagement (1-4 stars OR 1 fork): Keep or archive
- Low engagement (0 stars/forks): Evaluate personal value
  - Portfolio value: Keep
  - Learning/experimental: Consider archiving or deleting
  - Historical value: Archive

#### Category 4: Archived Repositories
**Already archived:** Review if still needed or can be deleted

### Step 2.2: Age-Based Analysis

Create a script to analyze by age:

```bash
#!/bin/bash
# save as: analyze-by-age.sh

USERNAME="$1"

echo "Repository Age Analysis"
echo "======================="
echo ""

# Get repos with last push date
gh repo list ${USERNAME} --limit 1000 --json name,pushedAt,isArchived,isFork | \
jq -r '.[] | [.name, .pushedAt, .isArchived, .isFork] | @tsv' | \
while IFS=$'\t' read -r name pushed archived fork; do
  # Calculate age
  pushed_date=$(date -d "$pushed" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$pushed" +%s 2>/dev/null)
  now=$(date +%s)
  days_old=$(( (now - pushed_date) / 86400 ))
  years_old=$(echo "scale=1; $days_old / 365" | bc)

  # Categorize
  if [ $days_old -gt 1825 ]; then  # 5+ years
    category="ANCIENT"
  elif [ $days_old -gt 730 ]; then  # 2-5 years
    category="STALE"
  elif [ $days_old -gt 365 ]; then  # 1-2 years
    category="OLD"
  else
    category="RECENT"
  fi

  fork_str=""
  if [ "$fork" = "true" ]; then
    fork_str=" [FORK]"
  fi

  archive_str=""
  if [ "$archived" = "true" ]; then
    archive_str=" [ARCHIVED]"
  fi

  echo "${category}: ${name} (${years_old} years)${fork_str}${archive_str}"
done | sort
```

### Step 2.3: Language Distribution Analysis

```bash
# Analyze primary languages
gh repo list YOUR_USERNAME --limit 1000 --json primaryLanguage,name | \
  jq -r '.[] | .primaryLanguage.name // "None"' | \
  sort | uniq -c | sort -rn

# Identify repos by language
gh repo list YOUR_USERNAME --limit 1000 --json primaryLanguage,name,pushedAt | \
  jq -r '.[] | select(.primaryLanguage.name == "LANGUAGE") | .name + " (" + .pushedAt + ")"'
```

### Step 2.4: Engagement Metrics

```bash
# High-value repos (5+ stars)
gh repo list YOUR_USERNAME --limit 1000 --json name,stargazerCount,forkCount | \
  jq -r '.[] | select(.stargazerCount >= 5) | .name + " (⭐" + (.stargazerCount|tostring) + " 🍴" + (.forkCount|tostring) + ")"'

# No engagement repos
gh repo list YOUR_USERNAME --limit 1000 --json name,stargazerCount,forkCount,isFork | \
  jq -r '.[] | select(.stargazerCount == 0 and .forkCount == 0 and .isFork == false) | .name'
```

---

## Phase 3: Decision Making

### Step 3.1: Create Decision Matrix

For each repository, evaluate:

| Criteria | Weight | Score (1-5) | Weighted Score |
|----------|--------|-------------|----------------|
| Recent activity (< 1 year) | 3 | ? | ? |
| Community engagement (stars/forks) | 2 | ? | ? |
| Portfolio value | 2 | ? | ? |
| Personal value | 2 | ? | ? |
| Documentation quality | 1 | ? | ? |
| **Total** | | | **?** |

**Decision thresholds:**
- Score ≥ 20: Keep and maintain
- Score 10-19: Keep or archive
- Score < 10: Archive or delete

### Step 3.2: Consolidation Opportunities

Look for patterns in repository names/purposes:
- Multiple repos with "sandbox", "test", "learning" → Consolidate
- Similar topics (e.g., multiple sports analytics repos) → Consider merging
- Same language/technology stack with related purposes → Merge possible

### Step 3.3: Naming and Organization Review

Evaluate consistency:
- Fork naming: Consistent prefix/pattern?
- Topic tags: Are repos properly tagged?
- Descriptions: Do all repos have clear descriptions?
- README quality: Top repos have comprehensive READMEs?

---

## Phase 4: Create Action Plan

### Step 4.1: Prioritize Actions

Create 3 priority tiers:

**Priority 1 (Quick Wins):**
- Delete unmodified forks
- Delete completed learning repos
- High impact, low risk

**Priority 2 (Strategic Cleanup):**
- Archive stale projects
- Consolidate similar projects
- Moderate effort, moderate impact

**Priority 3 (Polish):**
- Add topics/descriptions
- Improve documentation
- Standardize naming
- Lower impact, ongoing maintenance

### Step 4.2: Create Issues

Use the provided script:
```bash
./docs/create-cleanup-issues.sh
```

Or manually create issues following templates in `docs/repo-cleanup-issues.md`

### Step 4.3: Set Metrics and Goals

Define success criteria:
- Target repository count
- Minimum engagement threshold for active repos
- Documentation coverage (% of repos with descriptions and topics)
- Archival vs deletion ratio

**Example metrics:**
```markdown
## Starting State (2025-10-20)
- Total repositories: 143
- Forks: ~60 (42%)
- Learning/sandbox: ~30 (21%)
- Original projects: ~50 (35%)
- Archived: 3 (2%)

## Target State (2025-11-20)
- Total repositories: 70-80
- Forks: <10 (active contributors only)
- Learning/sandbox: 2-3 (consolidated)
- Original projects: 50-60 (active + archived)
- Archived: 15-20
- All active repos: Have descriptions and topics
```

---

## Phase 5: Execution

### Step 5.1: Safety Checklist

Before deleting any repository:

- [ ] Verify no open pull requests
- [ ] Check for any valuable code not elsewhere
- [ ] Confirm no external links/dependencies
- [ ] For forks: Ensure no custom commits
- [ ] Take screenshot/backup if historical value
- [ ] For work projects: Verify no company IP

### Step 5.2: Deletion Commands

```bash
# Preview repository details before deletion
gh repo view YOUR_USERNAME/REPO_NAME

# Delete repository (IRREVERSIBLE!)
gh repo delete YOUR_USERNAME/REPO_NAME

# Delete with confirmation bypass (DANGEROUS!)
gh repo delete YOUR_USERNAME/REPO_NAME --yes
```

### Step 5.3: Archival Commands

```bash
# Archive repository
gh repo archive YOUR_USERNAME/REPO_NAME

# Verify archived
gh repo view YOUR_USERNAME/REPO_NAME --json isArchived

# Unarchive if needed
gh repo unarchive YOUR_USERNAME/REPO_NAME
```

### Step 5.4: Bulk Operations

For multiple repositories, create a batch script:

```bash
#!/bin/bash
# save as: bulk-delete-repos.sh

USERNAME="$1"
REPO_LIST_FILE="$2"  # One repo name per line

if [ -z "$USERNAME" ] || [ -z "$REPO_LIST_FILE" ]; then
  echo "Usage: $0 USERNAME REPO_LIST_FILE"
  exit 1
fi

echo "This will DELETE the following repositories:"
cat "$REPO_LIST_FILE"
echo ""
read -p "Are you ABSOLUTELY sure? Type 'DELETE' to confirm: " confirm

if [ "$confirm" != "DELETE" ]; then
  echo "Aborted."
  exit 1
fi

while IFS= read -r repo; do
  echo "Deleting ${USERNAME}/${repo}..."
  gh repo delete "${USERNAME}/${repo}" --yes
  sleep 1  # Rate limiting
done < "$REPO_LIST_FILE"

echo "✓ Done"
```

### Step 5.5: Organization Improvements

```bash
# Add topics to repository
gh repo edit YOUR_USERNAME/REPO_NAME --add-topic "topic1,topic2,topic3"

# Update repository description
gh repo edit YOUR_USERNAME/REPO_NAME --description "New description here"

# Add/update README
gh api repos/YOUR_USERNAME/REPO_NAME/contents/README.md -X PUT \
  --field message="Update README" \
  --field content="$(base64 < README.md)"
```

---

## Phase 6: Tracking and Maintenance

### Step 6.1: Update Tracking Issue

Regularly update your tracking issue with:
- Current repository count
- Number deleted/archived/updated
- Decisions made (which consolidation approach chosen)
- Blockers or discoveries

### Step 6.2: Document Decisions

Keep a log of key decisions:
```markdown
## Decisions Log

- **2025-10-20**: Chose to keep fork naming as "fork--{name}"
- **2025-10-21**: Consolidated 5 sandbox repos into single "sandbox" repo
- **2025-10-22**: Decided to keep hockey-analytics and nhl-data separate due to different use cases
- **2025-10-23**: Archived all 2016-2017 civic data projects (historical value)
```

### Step 6.3: Verify Results

```bash
# Check final repository count
gh repo list YOUR_USERNAME --limit 1000 | wc -l

# Check archived count
gh repo list YOUR_USERNAME --limit 1000 --json isArchived | jq '[.[] | select(.isArchived == true)] | length'

# Check repos without descriptions
gh repo list YOUR_USERNAME --limit 1000 --json name,description | \
  jq -r '.[] | select(.description == null or .description == "") | .name'

# Check repos without topics
gh repo list YOUR_USERNAME --limit 1000 --json name,repositoryTopics | \
  jq -r '.[] | select(.repositoryTopics | length == 0) | .name'
```

---

## Best Practices

### DO:
✓ Start with Priority 1 (quick wins)
✓ Delete forks you haven't modified
✓ Archive rather than delete projects with historical value
✓ Consolidate similar sandbox/learning repos
✓ Add topics and descriptions to all active repos
✓ Document your decisions
✓ Take your time - this is not urgent

### DON'T:
✗ Rush deletions - once deleted, repos are hard to recover
✗ Delete repos with stars/forks without careful consideration
✗ Delete work projects without company approval
✗ Archive active projects just to reduce count
✗ Forget to check for open PRs before deleting forks
✗ Delete without checking for valuable code snippets

---

## Appendix: Useful Scripts

### A. Quick Repository Stats

```bash
#!/bin/bash
# save as: repo-stats.sh

USERNAME="$1"

echo "GitHub Repository Statistics for ${USERNAME}"
echo "==========================================="
echo ""

total=$(gh repo list ${USERNAME} --limit 1000 | wc -l)
echo "Total repositories: ${total}"

forks=$(gh repo list ${USERNAME} --limit 1000 --json isFork | jq '[.[] | select(.isFork == true)] | length')
echo "Forks: ${forks}"

archived=$(gh repo list ${USERNAME} --limit 1000 --json isArchived | jq '[.[] | select(.isArchived == true)] | length')
echo "Archived: ${archived}"

private=$(gh repo list ${USERNAME} --limit 1000 --json visibility | jq '[.[] | select(.visibility == "PRIVATE")] | length')
echo "Private: ${private}"

public=$((total - private))
echo "Public: ${public}"

with_stars=$(gh repo list ${USERNAME} --limit 1000 --json stargazerCount | jq '[.[] | select(.stargazerCount > 0)] | length')
echo "Repositories with stars: ${with_stars}"

total_stars=$(gh repo list ${USERNAME} --limit 1000 --json stargazerCount | jq '[.[].stargazerCount] | add')
echo "Total stars: ${total_stars}"

echo ""
echo "Top 5 repositories by stars:"
gh repo list ${USERNAME} --limit 1000 --json name,stargazerCount | \
  jq -r '.[] | "\(.stargazerCount)⭐ \(.name)"' | \
  sort -rn | head -5
```

### B. Find Inactive Forks

```bash
#!/bin/bash
# save as: find-inactive-forks.sh

USERNAME="$1"
YEARS="${2:-2}"  # Default 2 years

echo "Finding forks inactive for ${YEARS}+ years..."
echo ""

CUTOFF_DATE=$(date -d "${YEARS} years ago" +%Y-%m-%d 2>/dev/null || date -v-${YEARS}y +%Y-%m-%d)

gh repo list ${USERNAME} --limit 1000 --json name,isFork,pushedAt | \
  jq -r --arg cutoff "$CUTOFF_DATE" '.[] |
    select(.isFork == true and .pushedAt < $cutoff) |
    .name + " (last pushed: " + .pushedAt + ")"'
```

### C. Export Repository Data to CSV

```bash
#!/bin/bash
# save as: export-repos-csv.sh

USERNAME="$1"
OUTPUT="${2:-repos.csv}"

echo "Exporting repository data to ${OUTPUT}..."

gh repo list ${USERNAME} --limit 1000 --json name,description,stargazerCount,forkCount,pushedAt,isFork,isArchived,primaryLanguage | \
  jq -r '["Name","Description","Stars","Forks","Last Push","Is Fork","Is Archived","Language"],
    (.[] | [.name, .description // "", .stargazerCount, .forkCount, .pushedAt, .isFork, .isArchived, .primaryLanguage.name // ""]) |
    @csv' > "$OUTPUT"

echo "✓ Done! Data exported to ${OUTPUT}"
echo "Import into Google Sheets or Excel for analysis"
```

---

## Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [Repository Best Practices](https://docs.github.com/en/repositories)

---

## Maintenance Schedule

**Recommended audit frequency:**
- Quick review: Quarterly (check for forks to delete, obvious cleanup)
- Full audit: Annually (comprehensive review and reorganization)
- Ongoing: Add topics/descriptions when creating new repos

**Continuous practices:**
- Add description when creating new repository
- Add topics (3-5 minimum) for discoverability
- Archive projects when they become inactive
- Delete forks immediately after PR merge if no other work planned
- Consolidate sandboxes before creating new ones
