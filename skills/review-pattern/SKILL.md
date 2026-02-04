---
name: review-pattern
description: Review and improve pattern documentation for completeness. Use when asked to "review pattern", "check pattern docs", or "evaluate pattern documentation".
argument-hint: <pattern-name>
allowed-tools: Read, Glob, Grep
---

# Review Pattern Skill

Analyze pattern documentation against real implementations to find gaps that would cause confusion or errors during implementation.

## Prerequisites

Run this skill from a **consuming repo** (one that uses the patterns), not from effect-patterns itself. The skill needs real code to compare against.

## Workflow

1. **Map argument to pattern file**
   - `repository` → `repository-pattern.md`
   - `http-api` or `http` → `http-api-pattern.md`
   - `error` or `error-handling` → `error-handling-pattern.md`
   - `schema` → `schema-pattern.md`
   - `testing` or `test` → `testing-pattern.md`
   - `form` → `form-pattern.md`
   - `effect-atom` or `atom` → `effect-atom-pattern.md`
   - `service` → `service-pattern.md`
   - `policy` → `http-api-pattern.md` (policies section)

2. **Read the pattern file** from the patterns location (check CLAUDE.md for path)

3. **Find 2-3 real implementations** in the current codebase
   - Use Glob/Grep to find code following this pattern
   - Pick varied examples (simple + complex cases)

4. **Perform gap analysis** using the criteria in `GAP-ANALYSIS.md`

5. **Generate improvement report** (see output format below)

## Evaluation Dimensions

Focus on these four dimensions (details in GAP-ANALYSIS.md):

| Dimension | Question |
|-----------|----------|
| **Clarity** | Would an LLM need to guess or make assumptions? |
| **Self-sufficiency** | Can you implement without looking anything else up? |
| **Recognizability** | Is the architecture immediately obvious from code? |
| **Conciseness** | Is the pattern short enough to be fully regarded? |

## Output Format

```markdown
# Gap Analysis: [pattern-name]

## Summary

- **Pattern length**: X lines (target: <800)
- **Real implementations examined**: [list files]
- **Critical gaps**: X found
- **Minor gaps**: X found

## Critical Gaps

Issues that would cause implementation errors or require significant correction.

### 1. [Gap title]

**Found in**: `path/to/real/implementation.ts:42`
**Pattern says**: [what the doc says or omits]
**Code actually does**: [what real code does]
**Suggested fix**: [specific text to add/change in pattern]

### 2. ...

## Minor Gaps

Issues that would require lookup or cause minor friction.

### 1. [Gap title]
...

## Redundancy Check

Sections that could be trimmed without losing information:
- [section name]: [why it's redundant]

## Suggested Edits

Concrete changes to make, in priority order:

1. **[Location in pattern]**: [exact change]
2. ...
```

## What Makes a Critical Gap

A gap is **critical** if any of these apply:
- Missing import would cause compile error
- Wrong file path would put code in wrong location
- Omitted step would cause runtime error
- Ambiguous instruction has multiple valid interpretations

A gap is **minor** if:
- Information exists but is hard to find
- Example works but isn't idiomatic
- Related pattern link is missing

## Length Guidelines

| Length | Status |
|--------|--------|
| <400 lines | Good - high attention density |
| 400-800 lines | Acceptable - may lose some attention |
| >800 lines | Too long - split or trim redundancy |

Count only the rendered content, not template syntax.
