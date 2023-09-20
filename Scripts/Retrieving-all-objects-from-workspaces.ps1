<# 
Make sure to install:
    Install-Module MicrosoftPowerBIMgmt -MinimumVersion "1.2.1077"
    Install-Module -Name MicrosoftPowerBIMgmt 
    Install-Module -Name MicrosoftPowerBIMgmt.Admin 
    Install-Module -Name MicrosoftPowerBIMgmt.Capacities 
    Install-Module -Name MicrosoftPowerBIMgmt.Workspaces 
    Install-Module -Name MicrosoftPowerBIMgmt.Data 
    Install-Module -Name MicrosoftPowerBIMgmt.Reports 
    Install-Module -Name MicrosoftPowerBIMgmt.Profile
    Update-Module -Name MicrosoftPowerBIMgmt

    Get-Module MicrosoftPowerBIMgmt* -ListAvailable | Format-Table
    Get-PowerBICapacity

#> 

##
## Storing Power BI data
##


#login!
Login-PowerBI
Connect-PowerBIServiceAccount




#
# GET PowerBI Workspaces
#
#
$delimiter = ";"
$ALL_workspaces = Get-PowerBIWorkspace |  Select-Object Id, Name, Type, CapacityId | ForEach-Object {
                       $dsID =  $_.Id
                       $dsName = $_.Name
                       $dsType = $_.Type
                       $join4 = "$dsID $delimiter $dsName $delimiter $dsType $delimiter $dsID"
                       $join4 | Format-Table
                  }


#
# GET PowerBI DataFlows
#
#

#[pscustomobject]@{Portfolio = $_.Portfolio; Path = $p; CreateTime = "not found"}

# version 2
$type_df = "DataFlow"
$ALL_Dataflows = Get-PowerBIWorkspace | ForEach-Object {
               $wsID =  $_.Id
               $wsName = $_.Name
               Get-PowerBIDataflow -WorkspaceId $wsID | ForEach-Object {
                       $dsID =  $_.Id
                       $dsName = $_.Name
                       $join4 = "$dsID $delimiter $dsName $delimiter $type_df $delimiter $wsID"
                       $join4 | Format-Table
                  }
}


#
# GET PowerBI  Datasets
#

$type_df = "Dataset"
$ALL_Datasets = Get-PowerBIWorkspace | ForEach-Object {
               $wsID =  $_.Id
               $wsName = $_.Name
               Get-PowerBIDataset -WorkspaceId $wsID | ForEach-Object {
                       $dsID =  $_.Id
                       $dsName = $_.Name
                       $join4 = "$dsID $delimiter $dsName $delimiter $type_df $delimiter $wsID"
                       $join4 | Format-Table
                  }
}



#
# GET PowerBI  Datasetsource
#

Get-PowerBIWorkspace | ForEach-Object {
               $wsID =  $_.Id
               $wsName = $_.Name
               Write-Host "current workspaceID: " $wsID " and name: " $wsName
               Write-Host "Current datasets: "
               Get-PowerBIDataset -WorkspaceId $wsID | ForEach-Object {
                       $dsID =  $_.Id
                       $dsName = $_.Name
                      #Write-Host "Current dataset: "   $dsID  " and name: " $dsName
                       Get-PowerBIDatasource -DatasetId $dsID | Format-Table
                       }
               }



#
# GET PowerBI  Reports
#

$type_ = "Report"
$ALL_Reports = Get-PowerBIWorkspace | ForEach-Object {
               $wsID =  $_.Id
               $wsName =  $_.Name
               Get-PowerBIReport -WorkspaceId $wsID | ForEach-Object {
                       $dsID =  $_.Id
                       $dsName = $_.Name
                       $join4 = "$dsID $delimiter $dsName $delimiter $type_ $delimiter $wsID"
                       $join4 | Format-Table
                  }
}






#Export all objects!
#without headers! Headers: ObjectID ObjectName Type WorkspaceID
$initPath = "c:\AllData\"
$filename = "All_objects.csv"
$outPath = $initPath + $filename
$ALL_workspaces | Out-File $outPath  -Force
$ALL_Dataflows  | Out-File $outPath  -Append
$ALL_Datasets   | Out-File $outPath  -Append
$ALL_Reports    | Out-File $outPath  -Append


#Export only workspaces!
#without headers! Headers: WorkspaceID WorkspaceName Type WorkspaceID
$initPath = "c:\AllData\"
$filename = "All_workspaces.csv"
$outPath = $initPath + $filename
$ALL_workspaces | Out-File $outPath  -Force