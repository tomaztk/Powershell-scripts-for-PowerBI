<#
    .SYNOPSIS
    Script for retrieving list of all users and their access permissions on all reports within  Workspaces in a given organisation / tenant on Power BI Azure.
    .DESCRIPTION
        Script iterates through all workspaces and return usernames, iterates through all reports and retrieve access policy with  
		usernames for given workspaces in a given Power BI tenant.
        
        Script must be run as administrator. Modules: MicrosoftPowerBIMgmt.Profile and Join-Object must also be installed under
        same user. 
        Run: Install-Module -Name MicrosoftPowerBIMgmt.Profile -Force
		Run: Install-Module -Name Join-Object -Force
        Created by: Tomaz Kastrun, 13 September 2022
    .INPUTS
    None. Provide only Username and password for Azure subscription
    .LINK
    Online github repository: https://github.com/tomaztk/Powershell-scripts-for-PowerBI
 #>


Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass 
Import-Module Join-Object


# 1. Login to app.power.bi
$user = "YourAzure.Email@domain.com"
$pass = "YourStrongP422w!!rd"


$SecPasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$myCred = New-Object System.Management.Automation.PSCredential($user,$SecPasswd)

Connect-PowerBIServiceAccount -Credential $myCred


# 2. Get list of users and workspaces
$WorkSpace_Users = Get-PowerBIWorkspace -Scope Organization -Include All -All


# 3. Iterate through the workspace and get reports in each workspace (exclude Personal Workspaces)
$reposts_WS = $WorkSpace_Users | ForEach-Object {
            $Workspace = $_.name
            foreach ($Rep in $_.Reports) {
                [PSCustomObject]@{
                    WorkspaceName = $Workspace
                    ReportID = $Rep.id
                    ReportName   =$Rep.Name}
                    }
        } | Select ReportID, ReportName, WorkspaceName |  Where-Object {$Workspace -NotLike "PersonalWorkspace *"} 


# 4. Iterate through the workspace and get users with access policy on each workspace (exclude Personal Workspaces)
$users_WS =  $WorkSpace_Users | ForEach-Object {
            $Workspace = $_.name
            foreach ($User in $_.Users) {
                [PSCustomObject]@{
                    WorkspaceName = $Workspace
                    AccessPermission = $User.accessright    
                    UserName   =$user.Identifier}
                    }
        } | Select UserName, AccessPermission, WorkspaceName |  Where-Object {$Workspace -NotLike "PersonalWorkspace *"}  


# 5. Merge two data
$joinedWS = Join-Object -Left $reposts_WS -Right $users_WS -LeftJoinProperty 'WorkspaceName' -RightJoinProperty 'WorkspaceName'  -Type OnlyIfInBoth -LeftProperties ReportName, WorkspaceName  -RightProperties UserName, AccessPermission
