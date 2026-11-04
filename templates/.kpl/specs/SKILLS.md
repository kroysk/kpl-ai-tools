# Skills

Bodies: `.kpl/agents/skills/<name>/SKILL.md` (synced into `.cursor` / `.claude` / `.opencode` skills).

| Skill | When | Not for |
| --- | --- | --- |
| kpl-new-project | Greenfield / no existing code | Existing codebases (use kpl-project-explore + kpl-sdd-init) |
| feature-discovery | Vague idea / kickoff on existing code | Coding; PRD before approval; fix-path bugs |
| fix-bug | Defect, known files, no new capability/FR/trust boundary | New capability/actor/route (use feature-discovery) |
| write-prd | Discovery approved | Coding; unapproved discovery |
| write-feature-spec | PRD approved | Coding before specs ready |
| write-designer-brief | UI handoff | API-only; pixels before brief |
| implement-from-spec | Ready specs + branch ≠ main | Coding on main; writing Closed PASS |
| bulk-read | Large-file I/O / understand without editing | Patches, debug, architecture, security |
| sdd-quality-gate | Before human approval | Writing the docs themselves |
| security-review-api | API closeout | Exploits / PoCs |
| security-review-front | UI closeout | Replacing API review |
| git-branch | Before first code change | Force-push / work on main |
| publish-feature | Push / record publish.md | Silent merge to main; skip Closed gate |
| architecture-mentor | Deep design/refactor/boundary/ADR dive (brief version is always-on in every flow) | Typos / copy-only changes |
| memory-write | Lasting lesson or ADR | Dumping full specs |
| endpoint-access | New/changed HTTP routes | Auth TBD; UI-only “security” |
| kpl-doctor | Health check after install/refresh | Installing or writing app code |
| sdd-onboard | First guided SDD walkthrough (routes to the right entry) | Skipping gates; implementing code |
