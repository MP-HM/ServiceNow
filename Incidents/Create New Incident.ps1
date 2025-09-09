<#
================================================================================
SCRIPT INFORMATION
================================================================================
Description     : Create Incident in ServiceNow
Author          : mpauwels
Created Date    : 08.09.2025
Last Updated    : 09.09.2025
version         : 1.1
Requirements    : PowerShell 5.1+, ServiceNow OAuth credentials
================================================================================
#>

#$instance = "https://heidelbergmaterialsdev.service-now.com" #DEV
$instance = "https://heidelbergmaterialstest.service-now.com" #TEST
#$instance = "https://heidelbergmaterialsprod.service-now.com" #PROD

$clientId = "5a4fe50b4ec74fe88ea3669418e7db75"
$clientSecret = "a)u!xIkN3,"
$tokenUrl = "$instance/oauth_token.do"

function Get-AccessToken {
    $body = @{
        grant_type = "client_credentials"
        client_id = $clientId
        client_secret = $clientSecret
    }

    $response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body -ContentType "application/x-www-form-urlencoded"
    return $response.access_token
}

function new-Incident {
    param (
        [string]$accessToken,
        [string]$callerSysId,
        [string]$serviceOfferingSysId,
        [string]$category,
        [string]$subcategory,
        [string]$cmdbCiSysId,
        [int]$impact,
        [int]$priority,
        [string]$assignmentGroupSysId,
        [string]$shortDescription,
        [string]$description
    )

    $uri = "$instance/api/now/table/incident"

    $body = @{
        caller_id = $callerSysId
        service_offering = $serviceOfferingSysId
        category = $category
        cmdb_ci = $cmdbCiSysId
        impact = $impact
        priority = $priority
        assignment_group = $assignmentGroupSysId
        short_description = $shortDescription
        description = $description
        subcategory = $subcategory
    } | ConvertTo-Json -Depth 10

    $headers = @{
        Authorization = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response.result
}

# Main
$token = Get-AccessToken

# Replace these with actual sys_ids and values from your instance
$callerSysId = "e553c7ddebe7d2101d59f9e4cad0cdb2"                                               #Michael Pauwels
$serviceOfferingSysId = "ed1ce80eeb74a6105d05fa2bcad0cdbf"                                      #Application Support
$category = "Application"                                                                       #Application 
$subcategory = "Performance Issue"                                                              #Performance Issue 
$cmdbCiSysId = "74a1d02f127e26505cb6721082625789"                                               #ServiceNow
$impact = 2                                                                                     #1=High, 2=Medium, 3=Low
$priority = 3                                                                                   #1=High, 2=Medium, 3=Low
$assignmentGroupSysId = "23659b14eb2aa61004fff24e0bd0cdf8"                                      #GRP APP ITSM
$shortDescription = "Incident Created via Powershell"
$description = "This incident was created via PowerShell with multiple fields populated."

$incident = New-Incident -accessToken $token `
    -callerSysId $callerSysId `
    -serviceOfferingSysId $serviceOfferingSysId `
    -category $category `
    -cmdbCiSysId $cmdbCiSysId `
    -impact $impact `
    -priority $priority `
    -assignmentGroupSysId $assignmentGroupSysId `
    -shortDescription $shortDescription `
    -description $description `
    -subcategory $subcategory

Write-Host "Created Incident $($incident.number) (Sys_ID: $($incident.sys_id)) on $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')" -ForegroundColor Green

<#
================================================================================
CURRENT ISSUES
================================================================================
- [FIXED] Not able to populate following fields:
    - Category
    - Subcategory
================================================================================
CHANGE LOG
================================================================================
Version 1.0 - 08.09.2025 - mpauwels
    - Initial script creation
    - Added OAuth authentication
    - Added incident retrieval by number
    - Added error handling and colored output

Version 1.1 - 09.09.2025 - mpauwels
    - Fixed issue with category not populating
    - Fixed issue with subcategory not populating
================================================================================
#>
