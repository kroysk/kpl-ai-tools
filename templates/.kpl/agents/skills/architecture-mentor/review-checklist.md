# Architecture review checklist

Use in **Review** mode. Mark each: ok / gap / n/a. Fix gaps only if in scope; otherwise list as follow-ups.

## Boundaries

- [ ] Clear owner module/package for the change
- [ ] Trust boundary (HTTP, CLI, job, webhook) validates input server-side
- [ ] No new circular imports across feature modules

## Coupling & cohesion

- [ ] Change stays in few files/modules commensurate with the AC
- [ ] No god service / god component introduced
- [ ] Shared code is truly shared (not premature DRY)

## Data

- [ ] Single writer for critical state (or explicit multi-writer rules)
- [ ] Migrations / schema impact named if any
- [ ] Idempotency considered for retries / webhooks if relevant

## Failure & ops

- [ ] Error paths visible (user + logs); no silent swallow at trust edge
- [ ] Timeouts / retries only where an external call exists
- [ ] Observability: enough to debug the new path (log/metric/trace as stack uses)

## Auth & access

- [ ] Every new HTTP route has `access: public` or `access: permission:<code>`
- [ ] Authorization enforced where the data lives, not only in UI

## Complexity

- [ ] Pragmatic ladder climbed; no speculative layers
- [ ] Pattern named matches actual code shape
- [ ] “Not doing” list is honest
