
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

- store: brand2boost
  path: C:\stores\brand2boost
  used_by: [client-manager]
  contains: [data, config, identity.db]
  notes: Main store for Brand2Boost/Client Manager SaaS application

- store: artrevisionist.b
  path: C:\stores\artrevisionist.b
  used_by: [client-manager]
  contains: [prompts, chats, uploads, data]
  notes: Project data store with conversation history and uploaded documents

- store: branddesigner
  path: C:\stores\branddesigner
  used_by: [client-manager]
  contains: [role.prompts, config]
  notes: Brand designer role prompts and configuration

## Planned Stores (Not Yet Created)

- store: corinaai
  path: C:\stores\corinaai
  used_by: [corinaai]
  contains: [data, config, identity.db]
  notes: PLANNED - CorinaAI digital support platform data store

- store: mastermindgroup
  path: C:\stores\mastermindgroup
  used_by: [mastermindgroupai]
  contains: [data, config, identity.db]
  notes: PLANNED - MastermindGroupAI coaching platform data store
