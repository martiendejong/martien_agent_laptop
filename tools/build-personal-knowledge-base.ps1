param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("All", "Arjan", "Gemeente", "MVV", "Inburgering", "Visa")]
    [string]$Domain = "All",

    [switch]$Rebuild,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Output location
$KnowledgeBase = "C:\scripts\_machine\knowledge-base"
$OutputFile = "$KnowledgeBase\personal-domains.json"

if (-not (Test-Path $KnowledgeBase)) {
    New-Item -ItemType Directory -Path $KnowledgeBase -Force | Out-Null
}

function Extract-ArjanKnowledge {
    $readme = Get-Content "E:\arjan_emails\README.md" -Raw -Encoding UTF8

    return @{
        domain = "Arjan Stroeve / Social Media Hulp"
        status = "Publication Ready (95%)"
        key_evidence = @{
            wurgcontract = "E:\arjan_emails\Overeenkomst Martien.pdf (16 sept 2025)"
            email_count = 91
            smoking_gun = "Non-compete clause tijdens financial crisis"
            timeline = "2022-2026"
            game_theory_phase = "Phase 8: Nash Equilibrium (permanent non-cooperation)"
        }
        key_documents = @{
            critical_evidence = "E:\arjan_emails\CRITICAL_EVIDENCE_SUMMARY.md"
            game_theory = "E:\arjan_emails\GAME_THEORY_ANALYSE.md"
            facts = "E:\arjan_emails\FEITEN_EN_EVIDENCE.md"
            timeline = "E:\arjan_emails\TIJDLIJN_EVIDENCE_BASED.md"
            publication_strategy = "E:\arjan_emails\PUBLICATIE_STRATEGIE.md"
        }
        communication_patterns = @{
            exploitation_markers = @("Payment refusals", "Wurgcontract", "Kenyan team refusal", "Blocking", "False accusations")
            narrative_warfare = "Google review accusation via Hassan → Allan"
            response_strategy = "Tit-for-tat boundaries, permanent non-cooperation"
        }
        financial = @{
            outstanding = "EUR 3,625"
            salary_during_crisis = "EUR 3,500 bruto (minimumloon voor lead developer)"
        }
        last_updated = (Get-Date -Format "yyyy-MM-dd")
    }
}

function Extract-GemeenteKnowledge {
    $readme = Get-Content "E:\gemeente_emails\README.md" -Raw -Encoding UTF8

    return @{
        domain = "Gemeente Meppel - Huwelijksdossier"
        status = "Active conflict, 3+ years"
        duration = "1138 dagen (37 maanden)"
        key_facts = @{
            email_count = 896
            start_date = "Januari 2023"
            current_status = "Beide routes geblokkeerd (feb 2026)"
            goalpost_shifting = "30 jan 2026: QR-codes → URLs → fysieke documenten (in uren tijd)"
        }
        key_documents = @{
            timeline = "E:\gemeente_emails\TIJDLIJN_HUWELIJK_2022-2026_COMPLEET.pdf"
            situation = "E:\gemeente_emails\VOLLEDIGE_SITUATIEBESCHRIJVING_MARTIEN_EN_SOFY.md"
            strategy = "E:\gemeente_emails\STRATEGIE_PUBLIEKE_DRUK_ESCALATIE.md"
            for_helpers = "E:\gemeente_emails\hoe-je-martien-echt-kunt-helpen.pdf"
            email_analysis = "E:\gemeente_emails\ANALYSE_GMAIL_VS_INFO_EMAILS.md"
        }
        critical_moments = @{
            "2023-01" = "Eerste contact, direct beschuldigd van schijnhuwelijk"
            "2023-07-24" = "Eerste formele verzoeken"
            "2024" = "Reis naar Kenia mislukt (verkeerde documenten)"
            "2025-12-23" = "Gemeente: 'De legalisatie is zo prima'"
            "2026-01-23" = "Gemeente: 'Het besluit zal negatief zijn'"
            "2026-01-30" = "Verschuivende eisen in uren tijd"
            "2026-02-09" = "Gemeente: 'Die bevestiging kan ik u niet geven'"
        }
        communication_patterns = @{
            gemeente_contact = "Mw. Van der Haar"
            email_fragmentation = "Cruciale emails naar Gmail, intrekking naar info@"
            tactic = "Goalpost shifting, inconsistent requirements"
        }
        last_updated = (Get-Date -Format "yyyy-MM-dd")
    }
}

function Extract-MVVKnowledge {
    $actieplan = if (Test-Path "E:\mvv\ACTIEPLAN.md") { Get-Content "E:\mvv\ACTIEPLAN.md" -Raw -Encoding UTF8 } else { "" }
    $checklist = if (Test-Path "E:\mvv\CHECKLIST_IND_VEREISTEN.md") { Get-Content "E:\mvv\CHECKLIST_IND_VEREISTEN.md" -Raw -Encoding UTF8 } else { "" }

    return @{
        domain = "MVV (Machtiging tot Voorlopig Verblijf)"
        purpose = "Visa application for Sofy to enter Netherlands"
        key_documents = @{
            actieplan = "E:\mvv\ACTIEPLAN.md"
            checklist_ind = "E:\mvv\CHECKLIST_IND_VEREISTEN.md"
            readme = "E:\mvv\README.md"
            tasks_sophy = "E:\mvv\9-2-2026\Tasks for Sophy.md"
            template_communication = "E:\mvv\TEMPLATE_Communicatie_Overzicht.md"
        }
        supporting_documents = @{
            invitation_letter = "E:\mvv\Invitation_Letter_Sophy_Nashipae_Mpoe.pdf"
            ticket = "E:\mvv\ticket.png"
            room = "E:\mvv\room.png"
        }
        related_folder = "E:\bedrijf\mvv aanvraag\"
        last_updated = (Get-Date -Format "yyyy-MM-dd")
    }
}

function Extract-InburgeringKnowledge {
    $files = Get-ChildItem "E:\inburgering" -File -ErrorAction SilentlyContinue

    return @{
        domain = "Inburgering (Integration Exam)"
        purpose = "Dutch integration exam requirements and preparation"
        files_present = $files.Count
        location = "E:\inburgering\"
        last_updated = (Get-Date -Format "yyyy-MM-dd")
    }
}

function Extract-VisaKnowledge {
    $files = Get-ChildItem "E:\visa application" -File -ErrorAction SilentlyContinue

    return @{
        domain = "Visa Application"
        purpose = "Visa application documents and supporting evidence"
        files_present = $files.Count
        key_documents = $files | Select-Object -First 10 | ForEach-Object { $_.Name }
        location = "E:\visa application\"
        last_updated = (Get-Date -Format "yyyy-MM-dd")
    }
}

# Main execution
$knowledge = @{
    version = "1.0"
    created = (Get-Date -Format "o")
    last_updated = (Get-Date -Format "o")
    domains = @{}
}

if ($Domain -eq "All" -or $Domain -eq "Arjan") {
    if (-not $Silent) { Write-Host "Extracting Arjan knowledge..." -ForegroundColor Cyan }
    $knowledge.domains.arjan = Extract-ArjanKnowledge
}

if ($Domain -eq "All" -or $Domain -eq "Gemeente") {
    if (-not $Silent) { Write-Host "Extracting Gemeente knowledge..." -ForegroundColor Cyan }
    $knowledge.domains.gemeente = Extract-GemeenteKnowledge
}

if ($Domain -eq "All" -or $Domain -eq "MVV") {
    if (-not $Silent) { Write-Host "Extracting MVV knowledge..." -ForegroundColor Cyan }
    $knowledge.domains.mvv = Extract-MVVKnowledge
}

if ($Domain -eq "All" -or $Domain -eq "Inburgering") {
    if (-not $Silent) { Write-Host "Extracting Inburgering knowledge..." -ForegroundColor Cyan }
    $knowledge.domains.inburgering = Extract-InburgeringKnowledge
}

if ($Domain -eq "All" -or $Domain -eq "Visa") {
    if (-not $Silent) { Write-Host "Extracting Visa knowledge..." -ForegroundColor Cyan }
    $knowledge.domains.visa = Extract-VisaKnowledge
}

# Save to JSON
$knowledge | ConvertTo-Json -Depth 20 | Set-Content $OutputFile -Encoding UTF8

if (-not $Silent) {
    Write-Host "`nKnowledge base built successfully!" -ForegroundColor Green
    Write-Host "Output: $OutputFile" -ForegroundColor Yellow
    Write-Host "Domains extracted: $($knowledge.domains.Keys -join ', ')" -ForegroundColor Cyan
}

return $knowledge
