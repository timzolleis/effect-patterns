# Effect Patterns

Curated Effect-TS patterns and Claude Code skills for building production applications with Effect.

**What this does:** Syncs battle-tested patterns into your project's `patterns/` directory, customized with your package names, paths, and commands. Your AI coding assistant reads these to write consistent, idiomatic Effect code.

## Quick Start

### Option 1: Agent-Guided Setup (Recommended)

**[Copy the agent instructions](docs/AGENT-SETUP.md)** and paste them into Claude Code, Cursor, or any AI assistant.

The agent will auto-detect your project structure, create the config, and run the sync.

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

```bash
curl -fsSL https://raw.githubusercontent.com/timzolleis/effect-patterns/main/scripts/install-skills.sh | bash
```

Or with a specific ref:
```bash
curl -fsSL https://raw.githubusercontent.com/timzolleis/effect-patterns/main/scripts/install-skills.sh | bash -s -- github:timzolleis/effect-patterns v1.0.0
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

After syncing, you'll get:

**Repo root:**
| File | Description |
|------|-------------|
| `CLAUDE.md` | Claude Code guidelines (main entry point) |

**`patterns/` directory:**
| File | Description |
|------|-------------|
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
