<#
    .SYNOPSIS
    Script for retrieving Activity logs for given organisation / tenant on Power BI Azure.
    .DESCRIPTION
        Script iterates through number of days and uses cmdlet Get-PowerBIActivityEvent to retrieve activity log of Power BI tenant.
        The logs are stored into SQL Server table with use of cmdlet Write-SqlTableData.
        
        Script must be run as administrator. Modules: MicrosoftPowerBIMgmt.Profile and SqlServer must also be installed under
        same user. 
        Run: Install-Module -Name MicrosoftPowerBIMgmt.Profile -Force
        Run: Install-Module -Name SqlServer -Force
        Created by: Tomaz Kastrun, 02 September 2022
    .INPUTS
    None. Provide only Username and password for Azure subscription
    .LINK
    Online github repository: https://github.com/tomaztk/Powershell-scripts-for-PowerBI
 #>


# 1. Login to app.power.bi
$user = "YourAzure.Email@domain.com"
$pass = "YourStrongP422w!!rd"


$SecPasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$myCred = New-Object System.Management.Automation.PSCredential($user,$SecPasswd)

Connect-PowerBIServiceAccount -Credential $myCred



# 2. Get list of users and workspaces
$WorkSpace_Users = Get-PowerBIWorkspace -Scope Organization -Include All -All


# 3. Iterate through the users for each workspace (and exclude Personal Workspaces)
$WorkSpace_Users | ForEach-Object {
    $Workspace = $_.name
    foreach ($User in $_.Users) {
        [PSCustomObject]@{
            WorkspaceName = $Workspace
            AccessPermission = $User.accessright    
            UserName   =$user.Identifier}
            }
} | Select UserName, AccessPermission, WorkspaceName |  Where-Object {$Workspace -NotLike "PersonalWorkspace *"}

