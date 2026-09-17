# Skills

Bodies: `agents/skills/<name>/SKILL.md` (synced into `.cursor` / `.claude` / `.opencode` skills).

| Skill | When | Not for |
| --- | --- | --- |
| feature-discovery | Vague idea / kickoff | Coding; PRD before approval |
| write-prd | Discovery approved | Coding; unapproved discovery |
| write-feature-spec | PRD approved | Coding before specs ready |
| write-designer-brief | UI handoff | API-only; pixels before brief |
| implement-from-spec | Ready specs + branch ≠ main | Coding on main |
| sdd-quality-gate | Before human approval | Writing the docs themselves |
| security-review-api | API closeout | Exploits / PoCs |
| security-review-front | UI closeout | Replacing API review |
| git-branch | Before first code change | Force-push / work on main |
| publish-feature | Push / record publish.md | Silent merge to main |
| architecture-mentor | Design, refactor, boundaries, ADR, non-trivial structure | Typos / local bugfixes |
| memory-write | Lasting lesson or ADR | Dumping full specs |
| endpoint-access | New/changed HTTP routes | Auth TBD; UI-only “security” |
