# Project Inventory & Rollout Waves

Part of the [CP7 Reusable Repository Documentation Standard](STANDARD.md).

A **read-only, high-level** inventory of current version-controlled CP7 projects
and a recommended adoption order. This is a triage map, **not** a deep audit —
per-project auditing happens at [ADOPTION.md](ADOPTION.md) stage 1, one project
at a time. Nothing here changes any project's state.

**Method:** read-only presence scan (`AGENTS.md`, `README.md`, `docs/INDEX.md`,
`HANDOFF.md`, `ROADMAP.md`, CI workflows, harness adapters) across the projects
listed in `/home/chris/AGENT_INDEX.md`. Scanned 2026-07-22.

Legend — **A**=AGENTS.md · **R**=README · **I**=docs/INDEX.md · **H**=HANDOFF ·
**M**=ROADMAP · **CI**=.github/workflows · **Ad**=harness adapter(s).
Risk = documentation drift risk / cleanup effort. Sens = operational
sensitivity (live/prod exposure).

## Inventory

| Project | Type (high level) | A | R | I | H | M | CI | Ad | Doc risk | Sens | Wave |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| empower | full-stack finance app | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | **Reference** | High | — (done) |
| project-playbook | template / methodology (host) | ✓ | ✓ | – | ✓ | – | ✓ | – | Low | Low | **1** |
| playbook-cli | Python CLI (no service) | ✓ | ✓ | – | ✓ | – | ✓ | – | Low | Low | **1** |
| cc-loop | agent tooling | ✓ | ✓ | – | ✓ | – | – | – | Low | Low | **1** |
| 531-pwa | frontend PWA | ✓ | ✓ | – | ✓ | – | ✓ | – | Medium | Low | **1** |
| service-register | small Python service | ✓ | ✓ | – | ✓ | – | – | – | Low | Medium | **1** |
| dashboard | frontend app | ✓ | ✓ | – | ✓ | – | ✓ | – | Medium | Medium | 2 |
| cp7-mobile | React Native / Expo app | ✓ | ✓ | – | ✓ | – | ✓ | CLAUDE | Medium | Low | 2 |
| gitview | Docker service | ✓ | ✓ | – | ✓ | – | – | – | Medium | Medium | 2 |
| mfd-dashboard | Docker dashboard | ✓ | ✓ | – | ✓ | – | – | – | Medium | Medium | 2 |
| bosgame-mcp | MCP server | ✓ | ✓ | – | ✓ | – | – | – | Medium | Medium | 2 |
| skill-updates | tooling / docs | ✓ | ✓ | – | ✓ | – | – | – | Medium | Low | 2 |
| autochain | tooling | ✓ | ✓ | – | ✓ | – | – | – | Medium | Low | 2 |
| acerserver-maintenance | ops / scripts | ✓ | ✓ | – | ✓ | – | – | – | Medium | Medium | 2 |
| session-broker | Python service | ✓ | ✓ | – | ✓ | – | ✓ | – | Medium | Medium | 2 |
| netmon | monitoring daemon | ✓ | ✓ | – | ✓ | – | ✓ | – | Medium | High | 3 |
| context-engine-v2 | live Python service (:8402) | ✓ | ✓ | – | ✓ | – | ✓ | – | High | High | 3 |
| session/honcho | Docker memory stack | ✓ | ✓ | – | ✓ | – | ✓ | – | High | High | 3 |
| firecrawl | Docker service (fork) | ✓ | ✓ | – | ✓ | – | ✓ | – | High | High | 3 |
| hermes-workspace | agent gateway (Docker) | ✓ | ✓ | – | ✓ | – | ✓ | – | High | High | 3 |

> The full index lists additional non-project roots (docker service dirs,
> dotfiles, wiki, scripts). Those are out of scope for this standard unless a
> given one is genuinely a documented project.

## Fleet-wide observations (deterministic)

- **Near-universal baseline already exists:** almost every project has
  `AGENTS.md` + `README.md` + `HANDOFF.md`. Good starting point.
- **The consistent gap:** no `docs/INDEX.md`, no vetted `ROADMAP.md`, no spec
  lifecycle, and no docs check anywhere except **empower** (the reference).
- **Harness adapters are rare** (only empower and cp7-mobile) — meaning most
  repos correctly rely on direct `AGENTS.md` consumption, which the standard
  endorses.
- **HANDOFF freshness is the likely per-project cleanup** — several may hold
  stale active entries; that is a stage-1 audit finding, not asserted here.

## Recommended first rollout wave (5)

Chosen for **manageable risk + representativeness** — they cover the distinct
project archetypes so the standard proves itself across shapes before touching
anything production-sensitive:

1. **project-playbook** — dogfood the standard in the repo that hosts it; a
   template repo, lowest risk.
2. **playbook-cli** — a pure Python CLI (no service, no DB, no frontend): proves
   the "small project" baseline and the no-worktree/no-deploy path.
3. **531-pwa** — a frontend PWA: proves the standard on a JS/build-tool project.
4. **cc-loop** — agent tooling: proves it on an agent-facing repo where the
   `AGENTS.md`-as-canon contract matters most.
5. **service-register** — a small backend service: proves the conditional
   operations/deployment docs without high production stakes.

**Explicitly deferred to later waves:** the live/prod-sensitive services
(context-engine-v2, honcho, firecrawl, hermes-workspace, netmon) — Wave 3, each
with a careful stage-1 audit — and empower, which is already the reference
implementation and needs no adoption.
