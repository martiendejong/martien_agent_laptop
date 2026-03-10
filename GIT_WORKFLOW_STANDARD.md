# Git Workflow Standard

**MANDATORY voor alle repositories**

## Branch Structure

Elk repository MOET deze branches hebben:

- **`main`** - Productie branch (protected)
  - Altijd stabiel en deployable
  - Direct merges NIET toegestaan
  - Alleen merges via Pull Requests vanuit `develop`

- **`develop`** - Development branch (default branch)
  - Alle feature branches mergen hier naartoe
  - Dit is de default branch voor nieuwe clones
  - Periodic merges naar `main` voor releases

- **Feature branches** - `feature/naam-van-feature`
  - Branchen vanaf `develop`
  - Mergen terug naar `develop` via PR
  - Verwijderen na merge

## Deprecated Branches

- **`master`** - NIET MEER GEBRUIKEN
  - Oude GitHub/Git conventie
  - Vervangen door `main`
  - Bij bestaande repos: verwijderen of archiveren

## Workflow

### 1. Nieuwe Feature Starten

```bash
git checkout develop
git pull origin develop
git checkout -b feature/mijn-feature
# werk aan feature
git add .
git commit -m "feat: beschrijving"
git push origin feature/mijn-feature
```

### 2. Feature Voltooien

```bash
# Via GitHub/GitLab: Create Pull Request
# Target: develop
# Na approval: Merge & Delete branch
```

### 3. Release naar Productie

```bash
git checkout main
git pull origin main
git merge develop --no-ff
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin main --tags
```

## Nieuwe Repository Opzetten

### Via GitHub/GitLab

```bash
# 1. Create repo with main branch (default)
# 2. Clone lokaal
git clone <url>
cd <repo>

# 3. Create develop branch
git checkout -b develop
git push origin develop

# 4. Set develop as default branch
# GitHub: Settings → Branches → Default branch → develop
# GitLab: Settings → Repository → Default branch → develop

# 5. Protect main branch
# GitHub: Settings → Branches → Branch protection rules
# - Require pull request reviews
# - Require status checks
# - Restrict who can push

# 6. Verwijder master als die bestaat
git branch -d master
git push origin --delete master
```

### Bestaand Repo Converteren

```bash
# Als repo master heeft:
git checkout master
git branch -m master main  # rename lokaal
git push origin main       # push nieuwe naam
git push origin --delete master  # verwijder oude

# Set main as default op GitHub/GitLab
# Dan develop branch aanmaken zoals hierboven
```

## Commit Message Conventie

Gebruik Conventional Commits:

- `feat:` - Nieuwe feature
- `fix:` - Bug fix
- `docs:` - Documentatie
- `style:` - Formatting, geen code wijziging
- `refactor:` - Code refactoring
- `test:` - Tests toevoegen/aanpassen
- `chore:` - Build process, dependencies

Altijd eindigen met:
```
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

## Branch Naming Conventions

- `feature/` - Nieuwe features
- `fix/` - Bug fixes
- `docs/` - Documentatie updates
- `refactor/` - Code refactoring
- `test/` - Test updates

## Checklist Nieuwe Repo

- [ ] `main` branch bestaat
- [ ] `develop` branch aangemaakt
- [ ] `develop` is default branch
- [ ] `main` is protected
- [ ] `master` verwijderd (indien bestond)
- [ ] README.md met development instructies
- [ ] .gitignore aanwezig
- [ ] Dit workflow document toegevoegd

## Voor Alle Agents

**ALTIJD:**
1. Check of develop branch bestaat
2. Feature branches vanaf develop
3. Merge naar develop (NOOIT direct naar main)
4. PR voor alle merges

**NOOIT:**
1. Direct committen op main
2. Force push naar main of develop
3. Master branch gebruiken
4. Feature branches van main branchen

## Repository Overzicht

Zie `C:\scripts\_machine\git-repositories.md` voor lijst van alle repos en hun status.
