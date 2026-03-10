# Git Repositories Overview

**Standard workflow:** See `C:\scripts\GIT_WORKFLOW_STANDARD.md`

## Active Repositories

### martiendejong-wp-theme
- **URL:** https://github.com/martiendejong/martiendejong-wp-theme
- **Local:** E:\xampp\htdocs\wp-content\themes\martiendejong-wp-theme
- **Branches:** ✅ main, ✅ develop, feature/stm-plugin-migration
- **Default Branch:** develop
- **Status:** ✅ Compliant with standard workflow
- **Last Updated:** 2026-02-26

### client-manager
- **URL:** https://github.com/martiendejong/client-manager
- **Local:** C:\Projects\client-manager
- **Branches:** TBD - needs audit
- **Status:** ⚠️ Needs workflow compliance check

### hazina
- **URL:** https://github.com/martiendejong/hazina
- **Local:** C:\Projects\hazina
- **Branches:** TBD - needs audit
- **Status:** ⚠️ Needs workflow compliance check

### art-revisionist (WordPress)
- **URL:** TBD
- **Local:** E:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme
- **Status:** ⚠️ Needs git initialization

## Deprecated Branches to Remove

Check all repos for `master` branch and remove:
```bash
git branch -d master
git push origin --delete master
```

## TODO: Repository Audit

- [ ] Audit all repositories for branch structure
- [ ] Ensure develop branch exists everywhere
- [ ] Set develop as default branch
- [ ] Protect main branches
- [ ] Remove master branches
- [ ] Update this document with findings

## Notes

- All new repositories MUST follow the standard workflow
- Feature branches ALWAYS merge to develop
- Only develop merges to main (for releases)
- See GIT_WORKFLOW_STANDARD.md for complete guidelines
