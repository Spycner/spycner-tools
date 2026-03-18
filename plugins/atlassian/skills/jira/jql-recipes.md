# JQL Recipes Reference

Common JQL patterns for Jira queries. Use these with:

- **CLI:** `acli jira workitem search --jql '<JQL>'`
- **REST API:** `POST /rest/api/3/search/jql` with body `{"jql": "<JQL>", "maxResults": 50}`

When using the REST API, always URL-encode the JQL string if passing as a query parameter, but not when sending in a JSON body.

---

## My Issues

```jql
assignee = currentUser() AND resolution = Unresolved ORDER BY priority DESC
```
My open issues, highest priority first.

```jql
reporter = currentUser() AND resolution = Unresolved ORDER BY created DESC
```
Issues I reported that are still open.

```jql
assignee = currentUser() AND statusCategory = "In Progress"
```
Issues I am actively working on.

```jql
assignee = currentUser() AND updated >= -7d ORDER BY updated DESC
```
My issues updated in the last 7 days.

```jql
assignee was currentUser() AND assignee != currentUser()
```
Issues previously assigned to me but reassigned to someone else.

```jql
watcher = currentUser()
```
Issues I am watching.

---

## Team Issues

```jql
assignee in membersOf("team-name")
```
All issues assigned to members of a specific team. Replace `team-name` with the actual group name.

```jql
assignee in membersOf("team-name") AND resolution = Unresolved
```
Open issues for the team.

```jql
assignee in membersOf("team-name") AND statusCategory = "In Progress"
```
What the team is actively working on right now.

```jql
assignee in (user1, user2, user3) AND resolution = Unresolved
```
Issues for specific people (when a Jira group does not exist).

---

## Sprint Filters

```jql
sprint in openSprints()
```
All issues in any currently active sprint.

```jql
sprint in openSprints() AND project = "PROJ"
```
Current sprint issues for a specific project.

```jql
sprint in futureSprints()
```
Issues scheduled for upcoming sprints.

```jql
sprint in closedSprints() AND sprint not in openSprints() AND resolved >= -14d
```
Issues completed in recently closed sprints.

```jql
sprint is EMPTY AND resolution = Unresolved
```
Unresolved issues not assigned to any sprint (backlog).

```jql
sprint is EMPTY AND resolution = Unresolved AND project = "PROJ" ORDER BY priority DESC, created ASC
```
Project backlog, prioritized.

---

## Status Filters

```jql
status = "To Do"
```
Issues in To Do status. Exact status names vary by project workflow.

```jql
statusCategory = "To Do"
```
Issues in the To Do status category (matches any status mapped to that category, more portable across projects).

```jql
statusCategory = "In Progress"
```
All in-progress issues regardless of specific status name.

```jql
statusCategory = "Done"
```
All completed issues.

```jql
statusCategory != "Done"
```
All issues that are not yet done.

```jql
status changed to "In Progress" after -1d
```
Issues moved to In Progress in the last day.

```jql
status changed from "In Progress" to "Done" after -7d
```
Issues completed in the last week.

---

## Priority Filters

```jql
priority = Highest OR priority = High
```
High and highest priority issues.

```jql
priority in (Highest, High) AND resolution = Unresolved
```
Open high-priority issues.

```jql
priority = Highest AND statusCategory != "Done"
```
Unfinished critical issues.

---

## Date Filters

```jql
created >= -7d
```
Issues created in the last 7 days.

```jql
updated >= -1d
```
Issues updated in the last day.

```jql
created >= "2025-01-01" AND created <= "2025-03-31"
```
Issues created in a specific date range. Format: `YYYY-MM-DD`.

```jql
due <= 7d AND resolution = Unresolved
```
Unresolved issues due within the next 7 days.

```jql
due < now() AND resolution = Unresolved
```
Overdue issues.

```jql
resolved >= -7d
```
Issues resolved in the last 7 days.

---

## Project and Type Filters

```jql
project = "PROJ"
```
All issues in a project. Use the project key.

```jql
project in ("PROJ1", "PROJ2")
```
Issues across multiple projects.

```jql
issuetype = Bug AND resolution = Unresolved
```
Open bugs.

```jql
issuetype = Epic AND statusCategory != "Done"
```
Active epics.

```jql
issuetype in (Story, Task) AND resolution = Unresolved
```
Open stories and tasks.

```jql
parent = PROJ-123
```
Child issues (subtasks) of a specific issue.

```jql
"Epic Link" = PROJ-100
```
Issues belonging to a specific epic. Note: in next-gen projects, use `parent = PROJ-100` instead.

---

## Text Search

```jql
summary ~ "login"
```
Issues with "login" in the summary. The `~` operator does a contains/fuzzy match.

```jql
text ~ "error handling"
```
Full-text search across summary, description, and comments.

```jql
summary ~ "login" AND description ~ "SSO"
```
Combine text searches on specific fields.

---

## Labels and Components

```jql
labels = "tech-debt"
```
Issues with a specific label.

```jql
labels in ("tech-debt", "refactor")
```
Issues with any of the listed labels.

```jql
component = "Backend"
```
Issues assigned to a specific component.

```jql
labels is EMPTY AND resolution = Unresolved
```
Unlabeled open issues.

---

## Combined Patterns for Daily Workflow

### Morning standup: what am I working on?
```jql
assignee = currentUser() AND statusCategory = "In Progress" ORDER BY priority DESC
```

### What should I pick up next?
```jql
assignee = currentUser() AND statusCategory = "To Do" AND sprint in openSprints() ORDER BY priority DESC, created ASC
```

### Team sprint board overview
```jql
sprint in openSprints() AND project = "PROJ" ORDER BY statusCategory ASC, priority DESC
```

### Blockers and critical issues
```jql
priority in (Highest, High) AND statusCategory != "Done" AND sprint in openSprints()
```

### What got done this week?
```jql
statusCategory = "Done" AND resolved >= startOfWeek() AND project = "PROJ"
```

### Stale issues (no update in 30 days, still open)
```jql
updated <= -30d AND resolution = Unresolved AND assignee = currentUser()
```

### Overdue items needing attention
```jql
due < now() AND resolution = Unresolved AND assignee = currentUser() ORDER BY due ASC
```

### Unassigned issues in current sprint
```jql
assignee is EMPTY AND sprint in openSprints() AND project = "PROJ"
```

---

## Syntax Notes

- **Relative dates:** `-7d` (7 days ago), `-4w` (4 weeks ago), `-1h` (1 hour ago).
- **Date functions:** `now()`, `startOfDay()`, `startOfWeek()`, `startOfMonth()`, `startOfYear()`, `endOfDay()`, `endOfWeek()`, `endOfMonth()`, `endOfYear()`.
- **Operators:** `=`, `!=`, `~` (contains), `!~` (not contains), `in`, `not in`, `is EMPTY`, `is not EMPTY`, `was`, `changed`.
- **ORDER BY:** append `ORDER BY field ASC/DESC` to sort. Multiple fields: `ORDER BY priority DESC, created ASC`.
- **String values:** use double quotes for values with spaces: `status = "In Progress"`. Single-word values can omit quotes: `priority = High`.
- **currentUser():** resolves to the authenticated user. Works with both CLI and API when properly authenticated.
- **AND / OR:** combine clauses. AND binds tighter than OR; use parentheses to clarify: `(status = Open OR status = Reopened) AND priority = High`.
