# WhatsApp Bridge API Operations
# Production endpoint: https://whatsapp.wreckingball.ai:5001/api/external
# Credentials: vault:whatsapp-bridge-api

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('SendMessage', 'GetMessages', 'GetChats', 'GetContacts', 'GetSessions', 'CheckNumber')]
    [string]$Action,

    [string]$To,              # For SendMessage: phone number in format "31633984381@c.us"
    [string]$Message,         # For SendMessage: message text
    [string]$ChatId,          # For GetMessages: chat ID
    [int]$Limit = 50,         # For GetMessages: number of messages
    [string]$PhoneNumber      # For CheckNumber: phone number to check
)

# Get credentials from vault
$vaultRaw = & "C:\scripts\tools\vault.ps1" -Action get -Service whatsapp-bridge-api
$vault = $vaultRaw | ConvertFrom-Json
$apiToken = $vault.password
$email = $vault.username
$baseUrl = "https://whatsapp.wreckingball.ai:5001/api/external"

$headers = @{
    'X-Api-Token' = $apiToken
    'X-Email' = $email
    'Content-Type' = 'application/json'
}

switch ($Action) {
    'SendMessage' {
        if (-not $To -or -not $Message) {
            Write-Error "SendMessage requires -To and -Message parameters"
            Write-Host "Example: -To '31633984381@c.us' -Message 'Hello!'"
            exit 1
        }

        $body = @{
            to = $To
            body = $Message
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri "$baseUrl/whatsapp/messages/send" -Method Post -Headers $headers -Body $body

        if ($response.success) {
            Write-Host "[SUCCESS] Message sent to $($response.to)"
            Write-Host "Session: $($response.sessionId)"
            Write-Host "Sent at: $($response.sentAt)"
        } else {
            Write-Host "[FAILED] Message not sent"
        }

        return $response
    }

    'GetMessages' {
        if (-not $ChatId) {
            Write-Error "GetMessages requires -ChatId parameter (e.g., '31633984381@c.us')"
            exit 1
        }

        $response = Invoke-RestMethod -Uri "$baseUrl/whatsapp/messages?chatId=$ChatId&limit=$Limit" -Headers $headers

        Write-Host "Found $($response.Count) messages in chat $ChatId"

        return $response
    }

    'GetChats' {
        $response = Invoke-RestMethod -Uri "$baseUrl/whatsapp/chats" -Headers $headers

        Write-Host "Total chats: $($response.Count)"
        Write-Host "`nRecent chats:"
        $response | Select-Object -First 10 | ForEach-Object {
            $unread = if ($_.unreadCount -gt 0) { " ($($_.unreadCount) unread)" } else { "" }
            Write-Host "  [$($_.id)] $($_.name)$unread"
        }

        return $response
    }

    'GetContacts' {
        $response = Invoke-RestMethod -Uri "$baseUrl/whatsapp/contacts" -Headers $headers

        Write-Host "Total contacts: $($response.Count)"

        return $response
    }

    'GetSessions' {
        $response = Invoke-RestMethod -Uri "$baseUrl/whatsapp/sessions" -Headers $headers

        Write-Host "WhatsApp Sessions:"
        $response | ForEach-Object {
            Write-Host "`nSession ID: $($_.sessionId)"
            Write-Host "Status: $($_.status)"
            Write-Host "Phone: $($_.phoneNumber)"
            Write-Host "Connected: $($_.connectedAt)"
            Write-Host "Last seen: $($_.lastSeenAt)"
        }

        return $response
    }

    'CheckNumber' {
        if (-not $PhoneNumber) {
            Write-Error "CheckNumber requires -PhoneNumber parameter"
            exit 1
        }

        $encodedNumber = [System.Web.HttpUtility]::UrlEncode($PhoneNumber)
        $response = Invoke-RestMethod -Uri "$baseUrl/whatsapp/check-number?phoneNumber=$encodedNumber" -Headers $headers

        return $response
    }
}
