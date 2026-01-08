
# repos.index.md (machine-wide)

List all repositories that this machine-wide system may operate on.

Format:
- name: <repo-name>
  path: C:\Projects\<repo-name>
  default_branch: main
  integration_branch: develop
  notes: <optional>

## Repos
- name: hazina
  path: C:\Projects\hazina
  default_branch: main
  integration_branch: develop
  notes: Base framework. Changes here may require follow-up tasks in dependent repos.

- name: client-manager
  path: C:\Projects\client-manager
  default_branch: main
  integration_branch: develop
  notes: Uses Hazina.

- name: artrevisionist
  path: C:\Projects\artrevisionist
  default_branch: main
  integration_branch: develop
  notes: Dependent repo (update if Hazina changes impact it).

- name: bugatti-insights
  path: C:\Projects\bugatti-insights
  default_branch: main
  integration_branch: develop
  notes: Dependent repo.
