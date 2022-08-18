<#
    .SYNOPSIS
    Script for deleting Usage Report Metrics in all workspaces for given organisation / tenant on Azure.

    .DESCRIPTION
        Script iterates through all workspaces and looks for GUID of Dataset "Usage Reports Metrics". 
        If dataset exists, it deletes it. 

        Script must be run as administrator. Module: MicrosoftPowerBIMgmt.Profile must also be installed under
        same user. 
        Run: Install-Module -Name MicrosoftPowerBIMgmt.Profile -Force

        Created by: Tomaz Kastrun, 16 August 2022


    .INPUTS
    None. Provide only Username and password for Azure subscription

    .LINK
    Online github repository: https://github.com/tomaztk/Powershell-scripts-for-PowerBI

 #>


# 1. Login to app.powerbi/azure
$user = "InsertYourAccountEmail"
$pass = "InsertHereYourOwnPassword"

$SecPasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$myCred = New-Object System.Management.Automation.PSCredential($user,$SecPasswd)

Connect-PowerBIServiceAccount -Credential $myCred


# 2. Get Organization workspaces
$OrWorkSpaces = Get-PowerBIWorkspace  -Scope Organization -All | select-object -Property Id, Name, Type | where { $_.Type -eq "Workspace" }


# 3. Iterate through list of Work spaces and for each workspace GUID get Usage Metrics GUID
foreach ($WSid in $OrWorkSpaces)
{
    $workSpaceID = $WSid.Id
    $workSpaceName = $WSid.Name
    $DatasetsURL = 'groups/' + $workSpaceID + '/datasets'

    $x = (Invoke-PowerBIRestMethod -Url $DatasetsURL -Method Get) | ConvertFrom-Json 
    $UsageReportDatasetID = $x.value | where { $_.Name -eq "Usage Metrics Report" }
    $UsageReportDatasetID = $UsageReportDatasetID.id

    if ($UsageReportDatasetID -eq $null ) {
        Write-Host ("Dataset for Usage Report Statistics in Workspace  >"+ $workSpaceName +"< does not exists")
        } 
        else {

          $UsageReportDatasetURL = 'groups/' + $workSpaceID + '/datasets/' + $UsageReportDatasetID 
          Invoke-PowerBIRestMethod -Url $UsageReportDatasetURL -Method Delete
          Write-Host ("Deleting ....") 
         }

}