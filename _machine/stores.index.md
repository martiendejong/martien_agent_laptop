
# stores.index.md (machine-wide)

Registry of document stores under C:\stores.

Rules:
- Agents may read store config/metadata.
- Agents must not mutate store data unless explicitly instructed by the user.
- Any store-impacting change must create a task and include a rollback plan.

Format:
- store: <name>
  path: C:\stores\<name>
  used_by: [repo1, repo2]
  contains: [data, config]
  notes: <optional>

## Stores
- store: <fill>
  path: C:\stores\<fill>
  used_by: [<fill>]
  contains: [data, config]
  notes: <fill>
