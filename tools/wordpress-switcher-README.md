# WordPress Multi-Site Switcher

Snel wisselen tussen 3 WordPress sites op je lokale XAMPP omgeving.

## Beschikbare Sites

1. **ArtRevisionist** - Database: `artrevisionist` - Theme: `artrevisionist-wp-theme`
2. **martiendejong.nl** - Database: `martiendejong` - Theme: `martiendejong-wp-theme`
3. **Hydro Vision** - Database: `hydrovision` - Theme: `hydro-vision`
4. **Maasai Investments** - Database: `maasaiinvestments` - Theme: `maasai-investments-theme`

## Gebruik

### Eenvoudig (aanbevolen)

Gebruik het all-in-one script dat automatisch WordPress installeert als de database leeg is:

```powershell
# Switch naar martiendejong.nl (installeert WordPress als nodig)
.\wp-switch-and-setup.ps1 -Site martiendejong

# Switch naar ArtRevisionist
.\wp-switch-and-setup.ps1 -Site artrevisionist

# Switch naar Hydro Vision
.\wp-switch-and-setup.ps1 -Site hydrovision

# Switch naar Maasai Investments
.\wp-switch-and-setup.ps1 -Site maasaiinvestments
```

### Handmatig

Gebruik de individuele switcher scripts:

```powershell
# ArtRevisionist
.\switch-to-artrevisionist.ps1

# martiendejong.nl
.\switch-to-martiendejong.ps1

# Hydro Vision
.\switch-to-hydrovision.ps1

# Maasai Investments
.\switch-to-maasaiinvestments.ps1
```

Als de database leeg is, moet je handmatig WordPress installeren:

```powershell
.\wp-quick-install.ps1 -SiteTitle "Mijn Site"
```

## Wat doen de scripts?

1. Backup van huidige `wp-config.php`
2. Update `DB_NAME` in `wp-config.php`
3. Check of database WordPress bevat
4. Installeer WordPress als database leeg is (alleen all-in-one script)
5. Activeer correct theme via MySQL UPDATE
6. Flush rewrite rules

## Bestandslocaties

- **WordPress root:** `E:\xampp\htdocs\`
- **Themes:** `E:\xampp\htdocs\wp-content\themes\`
- **wp-config:** `E:\xampp\htdocs\wp-config.php`
- **Backup:** `E:\xampp\htdocs\wp-config.php.backup`

## Databases

Alle databases gebruiken:
- **User:** root
- **Password:** (leeg)
- **Host:** localhost

## Default Admin Credentials (na fresh install)

- **Username:** admin
- **Password:** admin
- **Email:** admin@localhost.local

## URLs

- **Site:** http://localhost/
- **Admin:** http://localhost/wp-admin/

## Troubleshooting

### Site niet bereikbaar na switch
1. Check of Apache draait (`E:\xampp\xampp-control.exe`)
2. Check of MySQL draait
3. Bezoek http://localhost/ in je browser
4. Clear browser cache

### Theme niet zichtbaar
1. Login bij wp-admin
2. Ga naar Appearance > Themes
3. Activeer het juiste theme handmatig

### Database errors
1. Check of MySQL draait
2. Check of database bestaat:
   ```sql
   SHOW DATABASES;
   ```
3. Re-run het setup script

## Scripts Overzicht

| Script | Functie |
|--------|---------|
| `wp-switch-and-setup.ps1` | All-in-one: switch + auto-install |
| `switch-to-artrevisionist.ps1` | Switch naar ArtRevisionist |
| `switch-to-martiendejong.ps1` | Switch naar martiendejong.nl |
| `switch-to-hydrovision.ps1` | Switch naar Hydro Vision |
| `switch-to-maasaiinvestments.ps1` | Switch naar Maasai Investments |
| `wp-quick-install.ps1` | Handmatige WordPress installatie |

## Notities

- Elke site heeft zijn eigen database
- Themes blijven behouden in `wp-content/themes/`
- Plugins blijven behouden in `wp-content/plugins/`
- Uploads blijven behouden in `wp-content/uploads/` (gedeeld tussen sites)
- Auth keys/salts blijven hetzelfde (in wp-config.php)

## Uploads Scheiden (optioneel)

Als je aparte uploads per site wilt:

1. Maak directories:
   ```powershell
   mkdir E:\xampp\htdocs\wp-content\uploads-artrevisionist
   mkdir E:\xampp\htdocs\wp-content\uploads-martiendejong
   mkdir E:\xampp\htdocs\wp-content\uploads-hydrovision
   ```

2. Voeg toe aan wp-config.php (per site basis):
   ```php
   define('UPLOADS', 'wp-content/uploads-martiendejong');
   ```

## Gemaakt

2026-02-12 - Jengo @ C:\scripts
