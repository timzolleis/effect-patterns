# Gap Analysis Criteria

How to identify gaps between pattern documentation and real implementations.

---

## Dimension 1: Clarity

**Question**: Would an LLM implementing this need to guess or make assumptions?

### What to look for

| Gap Type | How to detect | Example |
|----------|---------------|---------|
| Implicit decisions | Doc says "create a file" but not where | Real code is at `features/foo/repo.ts`, doc doesn't specify |
| Ambiguous terms | Terms used without definition | "the mapper" - which mapper? There are 3 |
| Missing branching logic | Doc shows one path, code has conditionals | Doc shows happy path, code handles 4 error cases |
| Assumed knowledge | References concepts not explained | "use the standard layer setup" - what's standard? |

### Comparison technique

1. Read a section of the pattern
2. Ask: "If I had never seen this codebase, what would I assume?"
3. Check real code: does it match the assumption?
4. If not → gap found

---

## Dimension 2: Self-sufficiency

**Question**: Can you implement from this doc alone without looking anything else up?

### What to look for

| Gap Type | How to detect | Example |
|----------|---------------|---------|
| Missing imports | Code has imports not shown in doc | `import { Effect } from "effect"` assumed but not shown |
| Incomplete paths | Relative paths without anchor | "in the handlers folder" - which handlers folder? |
| Partial examples | Snippet that won't compile standalone | Function body shown, but not signature or file context |
| Undefined dependencies | Code uses service/util not explained | `yield* AuthPolicy.requireAdmin()` - where's AuthPolicy from? |

### Comparison technique

1. Copy example from pattern doc
2. Try to mentally "paste" it into correct location
3. What's missing to make it compile?
4. Each missing piece → gap found

---

## Dimension 3: Recognizability

**Question**: Is the pattern's architecture immediately obvious when reading code?

### What to look for

| Gap Type | How to detect | Example |
|----------|---------------|---------|
| Naming drift | Real code uses different names than doc | Doc says `FooRepository`, code says `FooRepo` |
| Structure mismatch | File organization differs from doc | Doc shows flat structure, code uses nested folders |
| Missing visual aids | Complex flow with no diagram | 5-step process described only in prose |
| Convention undocumented | Real code has pattern doc doesn't mention | All repos use `Effect.fn("methodName")` but doc doesn't show |

### Comparison technique

1. Look at real implementation file
2. Can you immediately tell which pattern it follows?
3. What visual/naming cues helped?
4. Are those cues documented? If not → gap found

---

## Dimension 4: Conciseness

**Question**: Is the pattern short enough to be fully regarded by the model?

### What to look for

| Gap Type | How to detect | Example |
|----------|---------------|---------|
| Redundant examples | Same concept shown multiple times | 3 CRUD examples when 1 would suffice |
| Over-explanation | Prose explaining what code shows | Paragraph explaining a self-evident 2-line snippet |
| Historical cruft | Outdated alternatives still documented | "Previously we did X, now we do Y" - just show Y |
| Tangential content | Related but not essential info | Deep dive into Effect internals in a usage pattern |

### Length check

```bash
# Count lines (excluding template syntax)
grep -v '{{' pattern-file.md | wc -l
```

| Line count | Action |
|------------|--------|
| <400 | Good |
| 400-800 | Review for trimming opportunities |
| >800 | Must trim - identify sections to cut or split |

### Trimming priorities

1. **Cut first**: Redundant examples, historical notes, "why" explanations
2. **Keep**: Import statements, file paths, complete examples, error cases
3. **Consider splitting**: If pattern covers multiple distinct workflows

---

## Running the Analysis

### Step 1: Gather evidence

```
For each real implementation:
  - Note file path
  - Note any deviations from pattern
  - Note any "I had to figure this out" moments
```

### Step 2: Categorize gaps

- **Critical**: Would cause errors, wrong output, or significant rework
- **Minor**: Friction, lookup required, or suboptimal result

### Step 3: Write suggested fixes

For each gap, provide:
1. Exact location in pattern to change
2. Current text (or "missing")
3. Suggested replacement text
4. Why this fixes the gap

---

## Anti-patterns in Documentation

Patterns to avoid when writing fixes:

| Anti-pattern | Problem | Better approach |
|--------------|---------|-----------------|
| "See X for details" | Breaks self-sufficiency | Inline the essential info |
| "Usually you would..." | Ambiguous | "Always do X" or show both cases |
| Inline comments as docs | Missed in quick read | Explicit section with heading |
| Options without recommendation | Decision paralysis | State the default, mention alternatives |
| Code without file path | Where does this go? | Always show: `// path/to/file.ts` |
