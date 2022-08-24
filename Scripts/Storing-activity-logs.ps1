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

        Created by: Tomaz Kastrun, 23 August 2022


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

# 2. Get Data from app.powerbi/azure for previous day
$Datum = Get-Date((get-date ).AddDays(-1))  -Format "yyyy-MM-dd"

$StartDate = $Datum + 'T00:00:00'
$EndDate = $Datum + 'T23:59:59'


$json = Get-PowerBIActivityEvent -StartDateTime $StartDate -EndDateTime $EndDate | ConvertFrom-Json
$activity = $json | Select Id, CreationTime,Workload, UserId, Activity, ItemName, WorkSpaceName, DatasetName, ReportName, WorkspaceId, ObjectId, DatasetId, ReportId, ReportType ,DistributionMethod, ConsumptionMethod

# 3. Insert into SQL Server Database
Write-SqlTableData -InputData $activity -ServerInstance "MySQLServer2022" -DatabaseName "MyDatabase" -SchemaName "dbo" -TableName "PowerBIActivityLog" -Force




###############################################################
###  If you want to run script for past 10 days, use for loop
###############################################################

$user = "YourAzure.Email@domain.com"
$pass = "YourStrongP422w!!rd"

$SecPasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$myCred = New-Object System.Management.Automation.PSCredential($user,$SecPasswd)
Connect-PowerBIServiceAccount -Credential $myCred


$start = 1
$end = 10 # for past 10 days

for ($i=$start; $i -le $end; $i++)
{
    $Datum = Get-Date((get-date ).AddDays(-$i))  -Format "yyyy-MM-dd"
    $StartDate = $Datum + 'T00:00:00'
    $EndDate = $Datum + 'T23:59:59'

    Write-host("Start with", $StartDate, " and end with ", $EndDate)

    $json = Get-PowerBIActivityEvent -StartDateTime $StartDate -EndDateTime $EndDate | ConvertFrom-Json
    $activity = $json | Select Id, CreationTime,Workload, UserId, Activity, ItemName, WorkSpaceName, DatasetName, ReportName, WorkspaceId, ObjectId, DatasetId, ReportId, ReportType ,DistributionMethod, ConsumptionMethod

    # 3. Insert into SQL Server Database
    Write-SqlTableData -InputData $activity -ServerInstance "MySQLServer2022" -DatabaseName "MyDatabase" -SchemaName "dbo" -TableName "PowerBIActivityLog" -Force
    Write-host("Data for ", $Datum, " inserted into SQL Server Table")

    Start-Sleep -Seconds 120 #wait for 2 minutes

}