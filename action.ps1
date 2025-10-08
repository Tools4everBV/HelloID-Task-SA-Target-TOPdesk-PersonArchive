# TOPdesk-Task-SA-Target-TOPdesk-PersonArchive
###########################################################
# Form mapping
$formObject = @{
    id = $form.archivingReasonId
}
$userId = $form.id
$userDisplayName = $form.displayName

try {
    Write-Information "Executing TOPdesk action: [ArchivePersonAccount] for: [$($userDisplayName)]"
    Write-Verbose "Creating authorization headers"
    # Create authorization headers with TOPdesk API key
    $pair = "${topdeskApiUsername}:${topdeskApiSecret}"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $key = "Basic $base64"
    $headers = @{
        "authorization"       = $Key
        "Accept"              = "application/json"
        "Partner-Solution-Id" = "TOOL001"
    }

    Write-Verbose "Archiving TOPdesk Person for: [$($userDisplayName)]"
    $splatArchiveUserParams = @{
        Uri         = "$($topdeskBaseUrl)/tas/api/persons/id/$($userId)/archive"
        Method      = "PATCH"
        Body        = ([System.Text.Encoding]::UTF8.GetBytes(($formObject | ConvertTo-Json -Depth 10)))
        Verbose     = $false
        Headers     = $headers
        ContentType = "application/json; charset=utf-8"
    }
    $response = Invoke-RestMethod @splatArchiveUserParams

    $auditLog = @{
        Action            = "DisableAccount"
        System            = "TOPdesk"
        TargetIdentifier  = [String]$response.id
        TargetDisplayName = [String]$response.dynamicName
        Message           = "TOPdesk action: [DisablePersonAccount] for: [$($userDisplayName)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags "Audit" -MessageData $auditLog

    Write-Information "TOPdesk action: [DisablePersonAccount] for: [$($userDisplayName)] executed successfully"
}
catch {
    $ex = $_
    $auditLog = @{
        Action            = "DisableAccount"
        System            = "TOPdesk"
        TargetIdentifier  = ""
        TargetDisplayName = [String]$userDisplayName
        Message           = "Could not execute TOPdesk action: [DisablePersonAccount] for: [$($userDisplayName)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    if ($($ex.Exception.GetType().FullName -eq "Microsoft.PowerShell.Commands.HttpResponseException")) {
        $auditLog.Message = "Could not execute TOPdesk action: [DisablePersonAccount] for: [$($userDisplayName)]"
        Write-Error "Could not execute TOPdesk action: [DisablePersonAccount] for: [$($userDisplayName)], error: $($ex.ErrorDetails)"
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute TOPdesk action: [DisablePersonAccount] for: [$($userDisplayName)], error: $($ex.Exception.Message)"
}
###########################################################