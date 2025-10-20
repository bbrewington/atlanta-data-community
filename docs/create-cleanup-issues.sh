#!/bin/bash
#
# Script to create GitHub issues for repository cleanup initiative
# Usage: ./docs/create-cleanup-issues.sh
#
# This script will create 5 issues:
# - 1 tracking issue
# - 3 priority-based cleanup issues
# - 1 documentation issue
#

set -e  # Exit on error

REPO="bbrewington/bbrewington"

echo "========================================"
echo "Repository Cleanup Issues Creator"
echo "========================================"
echo ""
echo "This script will create 5 issues in ${REPO}"
echo ""
echo "Issues to be created:"
echo "  0. Repository Cleanup Tracker - 2025 (tracking)"
echo "  1. Priority 1: Delete Unmodified Forks and Learning Repos"
echo "  2. Priority 2: Archive and Consolidate Stale Projects"
echo "  3. Priority 3: Improve Organization and Documentation"
echo "  4. Create Reproducible Repository Audit Documentation"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Creating issues..."
echo ""

# Issue 0: Tracking Issue
echo "Creating Issue 0: Repository Cleanup Tracker..."
ISSUE_0=$(gh issue create --repo ${REPO} \
  --title "Repository Cleanup Tracker - 2025" \
  --body "$(cat <<'EOF'
## Overview
This is the master tracking issue for cleaning up the GitHub profile repositories (143 total → target 70-80).

## Audit Results
Based on comprehensive audit of all repositories, patterns identified:
- **40-50%** are forks (many unmodified)
- **20-25%** are sandbox/learning repos
- **30-35%** are original projects
- **Career evolution**: R-dominant (2016-2017) → Python-dominant (2024+)
- **High-value projects**: data-tools (23⭐), dbt-bigquery-information-schema (7⭐), atlanta-data-community (6⭐), gaming-data (5⭐)

## Cleanup Strategy
Working through 3 priority-based phases to systematically reduce repo count while preserving valuable work.

## Related Issues
- [ ] #TBD - Priority 1: Delete Unmodified Forks and Learning Repos (~50 repos)
- [ ] #TBD - Priority 2: Archive and Consolidate Stale Projects (~25 repos)
- [ ] #TBD - Priority 3: Improve Organization and Documentation (~70 repos to update)
- [ ] #TBD - Create Reproducible Repository Audit Documentation

## Progress Metrics
- **Starting count**: 143 repositories
- **Target count**: 70-80 repositories
- **Current count**: 143
- **Repos removed**: 0
- **Repos archived**: 0
- **Repos updated**: 0

## Timeline
- **Priority 1**: Week 1 (Quick wins - deletions)
- **Priority 2**: Week 2 (Strategic cleanup - archive/consolidate)
- **Priority 3**: Week 3 (Polish - documentation/organization)

## Decisions Log
Document key decisions made during cleanup:
- [ ] Fork naming convention: TBD
- [ ] Sandbox consolidation approach: TBD
- [ ] Sports analytics consolidation: TBD
- [ ] Atlanta civic data consolidation: TBD

## Notes
- Update progress metrics as issues are completed
- Link new issues as they are created
- Document any repos kept despite initial deletion plan
EOF
)" | grep -oP 'https://github.com/.+/issues/\K\d+')

echo "✓ Created Issue #${ISSUE_0}"
echo ""

# Issue 1: Priority 1
echo "Creating Issue 1: Priority 1 - Delete Unmodified Forks..."
ISSUE_1=$(gh issue create --repo ${REPO} \
  --title "Priority 1: Delete Unmodified Forks and Learning Repos" \
  --body "$(cat <<EOF
## Goal
Remove unmodified forks and completed learning repositories to reduce clutter and improve profile clarity.

## Context
Many repositories are forks where no modifications were made, or learning repositories that have served their purpose. These can be safely deleted as they:
- Have no custom commits
- Can be re-forked if needed
- Are available in the original repository
- Don't provide portfolio value

Relates to #${ISSUE_0}

## Tasks

### Unmodified dbt Forks (~8-10 repos)
- [ ] fork--dbt-coverage
- [ ] fork--dbt-expectations
- [ ] fork--dbt-date
- [ ] fork--dbt-audit-helper
- [ ] fork-dbt-completion.bash
- [ ] fork--cookiecutter-dbt
- [ ] fork--nfl-dbt
- [ ] Review: fork--docs.getdbt.com (check for contributions)

### Learning Material Forks (~5-7 repos)
- [ ] rvest
- [ ] twitteR
- [ ] rstan
- [ ] edeaR
- [ ] multidplyr
- [ ] censusr
- [ ] googleVis
- [ ] LittleBookofRTimeSeries

### GitHub Skills Courses (~3-5 repos)
- [ ] sandbox--github-skills--write-javascript-actions
- [ ] sandbox--github-skills--test-with-actions
- [ ] sandbox--github-skills--publish-packages
- [ ] fork--write-javascript-actions

### Coursera Assignments (~5-7 repos)
- [ ] Coursera-RepData-Assignment2
- [ ] Coursera-EDA-CourseProject2
- [ ] Coursera-EDA-Plotting1 (fork)
- [ ] ProgrammingAssignment2 (fork)
- [ ] RepData_PeerAssessment1 (fork)
- [ ] uci-human-activity-using-smartphones

### Other Inactive Forks (~20-30 repos)
- [ ] fork--professional-services
- [ ] fork--kubeflow--website
- [ ] fork--askui
- [ ] fork--yek
- [ ] fork--matrix-multiplication
- [ ] temp__pberkes__big_o
- [ ] fork--skimpy
- [ ] fork--PyMuPDF
- [ ] fork--spotify-mcp
- [ ] fork--data-liberation-project--www
- [ ] fork-polaris
- [ ] fork--AI-Meal-Planner
- [ ] fork--dora.dev
- [ ] fork--yahoo_fantasy_api
- [ ] fork--tweets
- [ ] courses (Data Science Specialization)
- [ ] indivisible
- [ ] early-voting (fork)
- [ ] Review remaining forks for activity

## Success Criteria
- [ ] 40-50 repositories deleted
- [ ] All forks verified to have no custom commits before deletion
- [ ] Repository count reduced from 143 to ~95

## Notes
Before deleting each fork:
1. Verify no custom commits: \\\`gh repo view OWNER/REPO --json isEmpty,forkCount\\\`
2. Check if you have any open PRs
3. Document any forks you decide to keep and why

## Commands
\`\`\`bash
# Check if fork has custom commits
gh api repos/bbrewington/REPO_NAME --jq '.fork, .pushed_at'

# Delete repository (CAREFUL!)
gh repo delete bbrewington/REPO_NAME --yes
\`\`\`
EOF
)" | grep -oP 'https://github.com/.+/issues/\K\d+')

echo "✓ Created Issue #${ISSUE_1}"
echo ""

# Issue 2: Priority 2
echo "Creating Issue 2: Priority 2 - Archive and Consolidate..."
ISSUE_2=$(gh issue create --repo ${REPO} \
  --title "Priority 2: Archive and Consolidate Stale Projects" \
  --body "$(cat <<EOF
## Goal
Archive inactive projects that have historical value but are no longer maintained, and consolidate similar projects to reduce sprawl.

## Context
Many projects from 2016-2019 are no longer actively maintained but represent valuable work that should be preserved. Rather than delete, we'll archive these. Additionally, some projects can be consolidated to reduce repository count.

Relates to #${ISSUE_0}

## Tasks

### Archive 2016-2017 Projects (~15-20 repos)
Review for archival (no activity in 7+ years):

#### Civic/Data Projects
- [ ] atlytics-opioid-project (2019)
- [ ] VA-open-data-mysandbox (2017)
- [ ] atl-2017-election-map (2017)
- [ ] usa-dashboard-crime-eda (2017)
- [ ] tinydesk-youtube (2017)
- [ ] radio1057-playlist (2017)
- [ ] renew-atlanta (2017)
- [ ] atlanta-salary-data (2017)
- [ ] country-canada (2017)
- [ ] marta-hackathon-2017 (2017)

#### Analytics/Viz Projects
- [ ] have-we-been-pwned (2017)
- [ ] us-news-hospital-honor-roll (2017)
- [ ] chess-hou-yifan (2017)
- [ ] womens-march-2017-turnout (2017)
- [ ] nyc_crime_trends (2016)
- [ ] little-book-of-r-time-series_myfiles (2016)
- [ ] purdue-notre-dame-scores (2016)
- [ ] edmunds-api-r (2016)

#### Course/Learning Projects
- [ ] cdc-body-measure (2016)
- [ ] Coursera-EDA-CourseProject2 (if not deleted in Priority 1)

### Archive 2018-2019 Projects (~5 repos)
- [ ] atlanta-finance-data (2018)
- [ ] mini-projects (2018)
- [ ] MSExcel (2024, already archived ✓)

### Consolidate Sandbox Repos (~5 repos)
Decision needed: Keep which sandbox repo(s)?

**Option A - Keep 2 sandboxes:**
- Keep: \\\`sandbox\\\` (general experimentation)
- Keep: \\\`github-actions-sandbox\\\` (GitHub Actions specific)
- Delete/merge: \\\`sandbox--dataviz\\\`, \\\`sandbox--jaffle-shop\\\`, \\\`dagster-starter\\\`, \\\`markdown-link-check-test\\\`

**Option B - Keep 1 sandbox:**
- Keep: \\\`sandbox\\\` (with subdirectories for different types)
- Delete/merge all others

### Consolidate Sports Analytics (~3 repos)
- [ ] Decision: Consolidate hockey-analytics + nhl-data?
- [ ] If yes: Merge into single \\\`sports-analytics\\\` or keep separate?

### Consolidate Atlanta Civic Data (~4 repos)
- [ ] Decision: Create single \\\`atlanta-civic-data\\\` repo?
- [ ] Candidates: atlanta-finance-data, atl-2017-election-map, renew-atlanta, atlanta-salary-data
- [ ] Keep separate: atlanta-data-community (active), atl-transit-data (active)

### Consolidate Fantasy Sports (~2 repos)
- [ ] Decision: Merge fantasy-football-stuff with gaming-data?
- [ ] Or keep separate?

## Success Criteria
- [ ] 15-25 repositories archived
- [ ] 5-10 repositories consolidated/deleted
- [ ] Repository count reduced from ~95 to ~70
- [ ] All consolidation decisions documented

## Archival Process
\`\`\`bash
# Archive a repository
gh repo archive bbrewington/REPO_NAME

# Verify archived status
gh repo view bbrewington/REPO_NAME --json isArchived
\`\`\`

## Consolidation Process
For each consolidation:
1. Create new repo or choose primary repo
2. Move code from secondary repos into subdirectories
3. Update README with consolidated project info
4. Archive or delete secondary repos
5. Update tracking issue with decision
EOF
)" | grep -oP 'https://github.com/.+/issues/\K\d+')

echo "✓ Created Issue #${ISSUE_2}"
echo ""

# Issue 3: Priority 3
echo "Creating Issue 3: Priority 3 - Improve Organization..."
ISSUE_3=$(gh issue create --repo ${REPO} \
  --title "Priority 3: Improve Organization and Documentation" \
  --body "$(cat <<EOF
## Goal
Improve discoverability and organization of remaining repositories through consistent naming, comprehensive descriptions, and proper topic tags.

## Context
After cleanup, the remaining ~70 repositories should represent your best work. Improving their organization makes your profile more professional and helps others (and yourself) find relevant projects.

Relates to #${ISSUE_0}

## Tasks

### Standardize Fork Naming Convention
Current situation: Inconsistent use of "fork--", "fork-", and no prefix

**Decision needed:** Choose one approach
- [ ] **Option A**: Use "fork--{original-name}" consistently
- [ ] **Option B**: Remove all fork prefixes (rely on GitHub's fork indicator)
- [ ] **Option C**: Keep inconsistent (not recommended)

After decision:
- [ ] Rename all forks to follow chosen convention (if keeping forks)
- [ ] Document convention in profile README

### Add Topics/Tags to Top Repositories (~20 repos)

#### Core Projects
- [ ] data-tools → \\\`python\\\`, \\\`data-engineering\\\`, \\\`dbt\\\`, \\\`r\\\`, \\\`utilities\\\`, \\\`analytics\\\`
- [ ] dbt-bigquery-information-schema → \\\`dbt\\\`, \\\`bigquery\\\`, \\\`data-engineering\\\`, \\\`sql\\\`, \\\`python\\\`
- [ ] atlanta-data-community → \\\`community\\\`, \\\`atlanta\\\`, \\\`data\\\`, \\\`directory\\\`, \\\`meetups\\\`
- [ ] gaming-data → \\\`python\\\`, \\\`gaming\\\`, \\\`data-analysis\\\`, \\\`api\\\`, \\\`tabletop-games\\\`

#### Analytics Projects
- [ ] hockey-analytics → \\\`python\\\`, \\\`hockey\\\`, \\\`analytics\\\`, \\\`sports\\\`, \\\`data-visualization\\\`
- [ ] nhl-data → \\\`python\\\`, \\\`nhl\\\`, \\\`hockey\\\`, \\\`sports-analytics\\\`, \\\`data\\\`
- [ ] atl-transit-data → \\\`python\\\`, \\\`atlanta\\\`, \\\`transit\\\`, \\\`marta\\\`, \\\`data-analysis\\\`
- [ ] peoria-il-equity-data → \\\`civic-tech\\\`, \\\`data-visualization\\\`, \\\`equity\\\`, \\\`government-data\\\`

#### Data Engineering
- [ ] havens-harvest-data → \\\`python\\\`, \\\`civic-tech\\\`, \\\`food-rescue\\\`, \\\`automation\\\`, \\\`data-engineering\\\`
- [ ] data-liberation-project-datasets → \\\`python\\\`, \\\`data-liberation\\\`, \\\`open-data\\\`, \\\`datasets\\\`

#### Legacy/Historical
- [ ] R_Reference → \\\`r\\\`, \\\`reference\\\`, \\\`learning\\\`, \\\`documentation\\\`
- [ ] echonest-r → \\\`r\\\`, \\\`api\\\`, \\\`music\\\`, \\\`data-visualization\\\`, \\\`echonest\\\`

#### Personal/Meta
- [ ] bbrewington → \\\`profile\\\`, \\\`readme\\\`
- [ ] bbrewington.github.io → \\\`portfolio\\\`, \\\`website\\\`, \\\`github-pages\\\`

#### Active Development
- [ ] chat-with-your-spotify → \\\`python\\\`, \\\`spotify\\\`, \\\`llm\\\`, \\\`ai\\\`, \\\`music\\\`
- [ ] coding-challenges → \\\`python\\\`, \\\`algorithms\\\`, \\\`learning\\\`, \\\`practice\\\`

### Add/Update Repository Descriptions (~15 repos)

Repos currently missing descriptions:
- [ ] dagster-starter → "Dagster project starter and experimentation"
- [ ] markdown-link-check-test → "Testing markdown link validation workflows"
- [ ] running-stuff → "Personal running data and analysis (Summer 2022)"
- [ ] dbt-sandbox → "dbt experimentation and testing"
- [ ] dbt-tutorial → "Learning dbt fundamentals"
- [ ] atl-2017-election-map → "Atlanta 2017 election results visualization"
- [ ] marta-hackathon-2017 → "MARTA hackathon project (2017)"
- [ ] nyc_crime_trends → "NYC crime data analysis and visualization"
- [ ] cdc-body-measure → "CDC NHANES body measurement data analysis"
- [ ] mini-projects → "Collection of small code examples and experiments"
- [ ] mapdiff → "Create comparison maps of US datasets using R"
- [ ] MITOCW_LinearAlgebra → "Scripts and notes for MIT OCW Linear Algebra course"

### Review and Update Pinned Repositories
Current pinned repos are good, but verify they're still your best work:
- [ ] Review current pinned repos
- [ ] Consider replacing echonest-r with newer project?
- [ ] Ensure pinned repos have excellent READMEs

### Update Key Project READMEs
Ensure top projects have comprehensive READMEs:
- [ ] data-tools → Verify README has: installation, usage examples, features
- [ ] dbt-bigquery-information-schema → Verify README has: setup, examples, benefits
- [ ] atlanta-data-community → Already good, keep updated
- [ ] gaming-data → Add more documentation on data sources and usage

### Profile README Enhancements
- [ ] Add section: "Repository Organization" explaining your repo structure
- [ ] Add section: "Featured Projects" highlighting key repos by category
- [ ] Consider adding: Repo count badge, language breakdown, activity stats

## Success Criteria
- [ ] All naming conventions standardized
- [ ] Top 20 repos have comprehensive topics (5+ tags each)
- [ ] All active repos have descriptions
- [ ] Pinned repos reviewed and updated
- [ ] Profile README enhanced
- [ ] Profile presents clean, professional appearance

## Notes
- Topics are case-insensitive and hyphen-separated
- Maximum 20 topics per repository
- Focus on discoverability: think about what you would search for
- Consistency matters: use same topic names across similar projects

## Commands
\`\`\`bash
# Add topics to a repository
gh repo edit bbrewington/REPO_NAME --add-topic "topic1,topic2,topic3"

# Update repository description
gh repo edit bbrewington/REPO_NAME --description "New description here"

# View current topics
gh repo view bbrewington/REPO_NAME --json repositoryTopics
\`\`\`
EOF
)" | grep -oP 'https://github.com/.+/issues/\K\d+')

echo "✓ Created Issue #${ISSUE_3}"
echo ""

# Issue 4: Documentation
echo "Creating Issue 4: Create Reproducible Repository Audit Documentation..."
ISSUE_4=$(gh issue create --repo ${REPO} \
  --title "Create Reproducible Repository Audit Documentation" \
  --body "$(cat <<EOF
## Goal
Create documentation that allows for reproducible repository audits in the future, including gh CLI scripts and process guides.

## Context
This cleanup effort should be repeatable. Future audits (yearly?) should be easier by having documented processes and scripts.

Relates to #${ISSUE_0}

## Tasks

- [ ] Create \\\`docs/repo-audit-process.md\\\` with step-by-step audit instructions
- [ ] Include gh CLI commands for gathering repository data
- [ ] Document analysis methodology (categorization, patterns, metrics)
- [ ] Add decision framework for delete vs archive vs keep
- [ ] Include example scripts for bulk operations
- [ ] Add this to profile repo for future reference
- [ ] Test documentation with a sample audit

## Deliverables

1. **docs/repo-audit-process.md**: Comprehensive guide including:
   - Data gathering commands
   - Analysis approach
   - Decision criteria
   - Common patterns to look for
   - Bulk operation scripts
   - Safety checks

2. **docs/create-cleanup-issues.sh**: Script to recreate these issues
   - Templated issue creation
   - Automated numbering and linking

3. **docs/repo-cleanup-issues.md**: Issue templates document

## Success Criteria
- [ ] Documentation is complete and tested
- [ ] Another person could follow it to audit their repos
- [ ] Scripts are working and safe
- [ ] All files committed to bbrewington/bbrewington repo

## Notes
This documentation will be valuable for:
- Annual repository audits
- Helping others clean up their GitHub profiles
- Maintaining good repository hygiene over time
EOF
)" | grep -oP 'https://github.com/.+/issues/\K\d+')

echo "✓ Created Issue #${ISSUE_4}"
echo ""

# Update tracking issue with links
echo "Updating tracking issue with actual issue numbers..."
gh issue edit ${ISSUE_0} --repo ${REPO} --body "$(cat <<EOF
## Overview
This is the master tracking issue for cleaning up the GitHub profile repositories (143 total → target 70-80).

## Audit Results
Based on comprehensive audit of all repositories, patterns identified:
- **40-50%** are forks (many unmodified)
- **20-25%** are sandbox/learning repos
- **30-35%** are original projects
- **Career evolution**: R-dominant (2016-2017) → Python-dominant (2024+)
- **High-value projects**: data-tools (23⭐), dbt-bigquery-information-schema (7⭐), atlanta-data-community (6⭐), gaming-data (5⭐)

## Cleanup Strategy
Working through 3 priority-based phases to systematically reduce repo count while preserving valuable work.

## Related Issues
- [ ] #${ISSUE_1} - Priority 1: Delete Unmodified Forks and Learning Repos (~50 repos)
- [ ] #${ISSUE_2} - Priority 2: Archive and Consolidate Stale Projects (~25 repos)
- [ ] #${ISSUE_3} - Priority 3: Improve Organization and Documentation (~70 repos to update)
- [ ] #${ISSUE_4} - Create Reproducible Repository Audit Documentation

## Progress Metrics
- **Starting count**: 143 repositories
- **Target count**: 70-80 repositories
- **Current count**: 143
- **Repos removed**: 0
- **Repos archived**: 0
- **Repos updated**: 0

## Timeline
- **Priority 1**: Week 1 (Quick wins - deletions)
- **Priority 2**: Week 2 (Strategic cleanup - archive/consolidate)
- **Priority 3**: Week 3 (Polish - documentation/organization)

## Decisions Log
Document key decisions made during cleanup:
- [ ] Fork naming convention: TBD
- [ ] Sandbox consolidation approach: TBD
- [ ] Sports analytics consolidation: TBD
- [ ] Atlanta civic data consolidation: TBD

## Notes
- Update progress metrics as issues are completed
- Link new issues as they are created
- Document any repos kept despite initial deletion plan
EOF
)"

echo "✓ Updated tracking issue with links"
echo ""

# Summary
echo "========================================"
echo "✓ All issues created successfully!"
echo "========================================"
echo ""
echo "Issues created:"
echo "  Tracking: #${ISSUE_0}"
echo "  Priority 1: #${ISSUE_1}"
echo "  Priority 2: #${ISSUE_2}"
echo "  Priority 3: #${ISSUE_3}"
echo "  Documentation: #${ISSUE_4}"
echo ""
echo "View tracking issue: https://github.com/${REPO}/issues/${ISSUE_0}"
echo ""
echo "Next steps:"
echo "  1. Review all issues"
echo "  2. Start with Priority 1 (Issue #${ISSUE_1})"
echo "  3. Update tracking issue as you progress"
echo ""
