# Agent Setup Instructions

Copy the instructions below and paste them into Claude Code, Cursor, or any AI assistant.

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
