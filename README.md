# Effect Patterns

Curated Effect-TS patterns and Claude Code skills for building production applications with Effect.

**What this does:** Syncs battle-tested patterns into your project's `patterns/` directory, customized with your package names, paths, and commands. Your AI coding assistant reads these to write consistent, idiomatic Effect code.

## Quick Start

### Option 1: Agent-Guided Setup (Recommended)

Copy the agent instructions below and paste them into Claude Code, Cursor, or any AI assistant:

<details>
<summary><strong>Click to expand agent instructions</strong></summary>

```
You are an Effect Patterns setup guide. Your job is to configure this repository with Effect-TS patterns from github.com/timzolleis/effect-patterns.

## Tools

- **Todo list**: If available, use it to track progress.
- **AskUserQuestion**: If available, use for multiple choice questions.

## Checklist

- [ ] Detect everything possible
- [ ] Ask only for values that couldn't be detected
- [ ] Create patterns.config.json
- [ ] Check jq is installed
- [ ] Run sync script
- [ ] Summary

---

## Step 1: Detect Everything

Run comprehensive detection:

```bash
# Lock files, root package.json, and directory structure
ls -la bun.lock bun.lockb pnpm-lock.yaml package-lock.json yarn.lock package.json 2>/dev/null
cat package.json 2>/dev/null
ls -la packages/ apps/ src/ 2>/dev/null

# Find domain/persistence/features directories
find . -maxdepth 4 -type d \( -name "domain" -o -name "persistence" -o -name "features" \) -not -path "*/node_modules/*" 2>/dev/null

# Read all workspace package.json files for package names
find . -maxdepth 3 -path "*/package.json" -not -path "*/node_modules/*" -exec cat {} \; 2>/dev/null
```

### Detection Rules

**Package Manager** (from lock file):
| Lock file | Package manager |
|-----------|-----------------|
| `bun.lock` / `bun.lockb` | `bun` |
| `pnpm-lock.yaml` | `pnpm` |
| `yarn.lock` | `yarn` |
| `package-lock.json` | `npm` |

**isMonorepoLayout**:
- `true` → Has `packages/persistence/` or `packages/domain/`
- `false` → Has `features/[entity]/repository/` structure or `src/features/`

**domainPackage**: Read `"name"` from `packages/domain/package.json`

**persistencePackage**: Read `"name"` from `packages/persistence/package.json`

**webAppPath**: First match of `apps/web/`, `apps/frontend/`, `apps/client/`, or `src/`

**webFeaturesPath**: Find directory with feature modules, e.g.:
- `apps/web/app/features/`
- `apps/web/src/features/`
- `src/features/`

**Commands** (from root `package.json` scripts):
| Config key | Look for script named | Fallback |
|------------|----------------------|----------|
| `typecheck` | `typecheck`, `type-check`, `check`, `tsc` | `[pkg] tsc --noEmit` |
| `test` | `test` | `[pkg] vitest` |
| `testWatch` | `test:watch` | `[test command] --watch` |
| `migrate` | `migrate`, `migrate:dev`, `db:migrate` | `[pkg] prisma migrate dev` |
| `generate` | `generate`, `db:generate`, `prisma:generate` | `[pkg] prisma generate` |

For monorepos with workspace scripts like `"web": "pnpm --filter web"`, commands become `pnpm web typecheck`, etc.

---

## Step 2: Confirm Detection

Present everything you detected:

"I detected the following:
- **Package manager**: pnpm (from pnpm-lock.yaml)
- **Layout**: monorepo (packages/persistence exists)
- **domainPackage**: @myorg/domain (from packages/domain/package.json)
- **persistencePackage**: @myorg/persistence (from packages/persistence/package.json)
- **webAppPath**: apps/web
- **webFeaturesPath**: apps/web/app/features
- **Commands**:
  - typecheck: `pnpm typecheck` (from scripts.typecheck)
  - test: `pnpm test` (from scripts.test)
  - testWatch: `pnpm test --watch`
  - migrate: `pnpm prisma migrate dev` (default)
  - generate: `pnpm prisma generate` (default)

Does this look correct? [Ask about any values you couldn't detect]"

---

## Step 3: Create patterns.config.json

Write the config with detected values:

```json
{
  "source": "github:timzolleis/effect-patterns",
  "ref": "main",
  "variables": {
    "domainPackage": "@myorg/domain",
    "persistencePackage": "@myorg/persistence",
    "webAppPath": "apps/web",
    "webFeaturesPath": "apps/web/app/features",
    "isMonorepoLayout": true,
    "commands": {
      "packageManager": "pnpm",
      "typecheck": "pnpm typecheck",
      "test": "pnpm test",
      "testWatch": "pnpm test --watch",
      "migrate": "pnpm prisma migrate dev",
      "generate": "pnpm prisma generate"
    }
  }
}
```

---

## Step 4: Check jq

```bash
command -v jq || echo "jq not found - install with: brew install jq (macOS) or apt-get install jq (Linux)"
```

---

## Step 5: Run Sync Script

```bash
curl -fsSL https://raw.githubusercontent.com/timzolleis/effect-patterns/main/scripts/sync-patterns.sh | bash
```

---

## Step 6: Summary

Report:
- Values detected vs. user-provided
- Patterns synced to `patterns/`
- Next steps: "Your AI assistant can now read patterns/ for Effect best practices. Try asking it to implement a repository or HTTP endpoint!"
```

</details>

### Option 2: Manual Setup

1. **Install jq** (required for JSON parsing)
   ```bash
   brew install jq  # macOS
   # or: apt-get install jq (Linux)
   ```

2. **Create `patterns.config.json`** in your project root (see [Configuration](#configuration))

3. **Run the sync script**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/timzolleis/effect-patterns/main/scripts/sync-patterns.sh | bash
   ```

   The script auto-detects your package manager and installs `handlebars` as a dev dependency if needed.

### Install Claude Code Skills (Optional)

Clone this repo and run:
```bash
./scripts/install-skills.sh
```

Skills are installed to `~/.claude/skills/` and include:
- `/review-pattern` - Review pattern documentation for completeness
- `/write-tests` - Write integration tests using Effect patterns

---

## Configuration

The `patterns.config.json` file tells the sync script how to customize patterns for your project.

<details>
<summary><strong>Full example configuration</strong></summary>

```json
{
  "source": "github:timzolleis/effect-patterns",
  "ref": "main",
  "variables": {
    "domainPackage": "@myorg/domain",
    "persistencePackage": "@myorg/persistence",
    "webAppPath": "apps/web",
    "webFeaturesPath": "apps/web/app/features",
    "isMonorepoLayout": true,
    "commands": {
      "packageManager": "pnpm",
      "typecheck": "pnpm typecheck",
      "test": "pnpm test",
      "testWatch": "pnpm test --watch",
      "migrate": "pnpm prisma migrate dev",
      "generate": "pnpm prisma generate"
    }
  }
}
```

</details>

### Variables Reference

| Variable | Description |
|----------|-------------|
| `domainPackage` | Import path for domain models (e.g., `@myorg/domain`) |
| `persistencePackage` | Import path for persistence layer (e.g., `@myorg/persistence`) |
| `webAppPath` | Path to web application root |
| `webFeaturesPath` | Path to features directory |
| `isMonorepoLayout` | `true` = packages/persistence structure, `false` = features/[entity]/repository |
| `commands.packageManager` | `pnpm`, `npm`, `yarn`, or `bun` |
| `commands.typecheck` | Command to run type checking |
| `commands.test` | Command to run tests |
| `commands.testWatch` | Command to run tests in watch mode |
| `commands.migrate` | Database migration command |
| `commands.generate` | Prisma generate command |

### Source Options

| Format | Description |
|--------|-------------|
| `github:owner/repo` | Clone from GitHub (default) |
| `/path/to/local/repo` | Local path for development |
| `https://...` | Any git URL |

---

## What's Included

### Patterns

After syncing, your `patterns/` directory will contain:

| File | Description |
|------|-------------|
| `CLAUDE.md` | Claude Code guidelines (main entry point) |
| `CRITICAL_RULES.md` | Must-follow rules for Effect code |
| `README.md` | Pattern index and quick reference |
| `repository-pattern.md` | Data access layer with Prisma + Effect.Service |
| `http-api-pattern.md` | HTTP APIs with @effect/platform + authorization policies |
| `error-handling-pattern.md` | Domain vs infrastructure error handling |
| `schema-pattern.md` | Effect Schema for domain modeling |
| `testing-pattern.md` | Integration tests with @effect/vitest |
| `form-pattern.md` | React Hook Form with Effect Schema validation |
| `effect-atom-pattern.md` | React data fetching with Effect Atom |
| `usability-pattern.md` | UI/UX guidelines |

### Skills

| Skill | Description |
|-------|-------------|
| `/review-pattern <name>` | Review pattern docs for completeness |
| `/write-tests <file>` | Write integration tests following patterns |

Usage: `/review-pattern repository`, `/review-pattern http-api`

---

## Development

### Repository Structure

```
effect-patterns/
├── patterns/           # Handlebars templates (*.hbs)
├── skills/             # Claude Code skills
│   ├── review-pattern/
│   └── write-tests/
└── scripts/
    ├── install-skills.sh   # Install skills locally
    └── sync-patterns.sh    # Sync patterns to a project
```

### Creating Patterns

1. Create `patterns/[name]-pattern.md.hbs`
2. Use `{{variableName}}` for project-specific values
3. Use `{{#if isMonorepoLayout}}...{{else}}...{{/if}}` for layout variants
4. Add evaluation criteria to `skills/review-pattern/EVALUATION-RUBRIC.md`

### Testing Locally

```bash
# In your test project's patterns.config.json, use local path:
{
  "source": "/path/to/effect-patterns",
  ...
}

# Run the sync script from your local clone
/path/to/effect-patterns/scripts/sync-patterns.sh
```

## Contributing

1. Fork and clone this repo
2. Edit `.hbs` files in `patterns/`
3. Test with a local source path
4. Submit PR

---

## License

MIT
