# CQL Recipes Reference

CQL (Confluence Query Language) is used for searching Confluence content. **CQL is only available via the v1 REST API.** All CQL queries must use:

```
GET /wiki/rest/api/search?cql=<query>
```

The v2 API does not support CQL search.

## Basic Search

### Search by title

```
type = page AND title ~ "search term"
```

The `~` operator performs a fuzzy/contains match. Use `=` for exact title match.

### Search by title (exact)

```
type = page AND title = "Architecture Overview"
```

### Full-text search

```
type = page AND text ~ "deployment pipeline"
```

Searches page body content. Slower than title search on large instances.

## Filtering by Space

### Pages in a specific space

```
type = page AND space = "SPACEKEY"
```

Replace `SPACEKEY` with the space key (e.g., `ENG`, `PRODUCT`, `HR`).

### Pages in multiple spaces

```
type = page AND space IN ("ENG", "PRODUCT")
```

### Title search within a space

```
type = page AND space = "ENG" AND title ~ "onboarding"
```

## Filtering by User

### Pages I created

```
type = page AND creator = currentUser()
```

### Pages created by a specific user

```
type = page AND creator = "accountId"
```

Use the Atlassian account ID, not the display name.

### Pages I contributed to

```
type = page AND contributor = currentUser()
```

Includes pages where the user made any edit, not just creation.

## Date Filters

### Recently modified (after a date)

```
type = page AND lastModified > "2026-01-01"
```

Date format is `YYYY-MM-DD`.

### Modified in the last N days

```
type = page AND lastModified > now("-7d")
```

Supports `d` (days), `w` (weeks), `M` (months), `y` (years).

### Created recently

```
type = page AND created > now("-30d")
```

### Modified within a date range

```
type = page AND lastModified > "2026-01-01" AND lastModified < "2026-02-01"
```

## Page Hierarchy

### Child pages under a parent

```
type = page AND ancestor = 12345
```

The value is the numeric page ID of the ancestor. Returns all descendants, not just direct children.

### Pages with a specific label

```
type = page AND label = "architecture"
```

### Pages with multiple labels

```
type = page AND label = "architecture" AND label = "approved"
```

## Combined Patterns

### Find onboarding docs in a space

```
type = page AND space = "ENG" AND title ~ "onboarding"
```

### My recent pages in a space

```
type = page AND space = "ENG" AND creator = currentUser() AND lastModified > now("-30d")
```

### Recently updated architecture pages

```
type = page AND label = "architecture" AND lastModified > now("-7d")
```

### Search under a section, filtered by label

```
type = page AND ancestor = 12345 AND label = "runbook"
```

### Full-text search scoped to a space and date

```
type = page AND space = "OPS" AND text ~ "incident" AND lastModified > now("-90d")
```

## Sorting

Append `ORDER BY` to any query:

```
type = page AND space = "ENG" ORDER BY lastModified DESC
```

Common sort fields: `lastModified`, `created`, `title`.

## Pagination

The v1 search endpoint supports `limit` and `start` parameters:

```
GET /wiki/rest/api/search?cql=type=page AND space="ENG"&limit=25&start=0
```

Default limit is 25. Maximum depends on instance configuration (typically 200).

## Notes

- CQL only works with the **v1 API** (`/wiki/rest/api/search`). The v2 API does not have a CQL search endpoint.
- The `~` operator is case-insensitive for title and text searches.
- `currentUser()` resolves to the authenticated user making the API call.
- Page IDs for `ancestor` queries can be found in page URLs or via the content API.
- Space keys are case-sensitive and typically uppercase.
- Wrap string values in double quotes. Field names and operators are not quoted.
