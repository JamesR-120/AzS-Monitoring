Write-Host @("

.TITLE: Format-TAZ-Json.ps1
.AUTHOR: James R
.DATE: 02/07/2020

.SYNOPSIS: Formats JSON output from TAZ - Cloud, host and infra perf metrics.

.CHANGE LOG:
                20200702- JR - Script created.
                20230128- JR - Formatting

") -ForegroundColor Cyan

<# Set Env

    Get-Variable node* | Remove-Variable
    Get-Variable infra* | Remove-Variable
    Get-Variable cloud* | Remove-Variable

#>

# Fetch input (JSON from TAZ)

#$summary = Get-Content $OutPath\$FileName | ConvertFrom-Json
$summary = Get-Content "AzureStack_Validation_Summary_2020.07.09_07.00.12_MAS.INF.json" | ConvertFrom-Json

# Get Physical Nodes & Perf Data

$NodeList = [System.Collections.ArrayList]@()
$NodeValuesSplit = [System.Collections.ArrayList]@()
$NodeOutput = [System.Collections.ArrayList]@()

$NodeValues = $summary.Information[2].data # Node perf data
$NodeFields = $summary.Information[2].fields # Node perf fields

# Get Infra Nodes & Perf Data

$InfraList = [System.Collections.ArrayList]@()
$InfraValuesSplit = [System.Collections.ArrayList]@()
$InfraOutput = [System.Collections.ArrayList]@()

$InfraValues = $summary.Information[1].data # Infra perf data
$InfraFields = $summary.Information[1].fields # Infra perf fields

# Get Cloud Data

$CloudList = [System.Collections.ArrayList]@()
$CloudValuesSplit = [System.Collections.ArrayList]@()
$CloudOutput = [System.Collections.ArrayList]@()

$CloudValues = $summary.Information[0].data # Cloud perf data
$CloudFields = $summary.Information[0].fields # Cloud perf fields        
 
# Build Physical Node List

$Counter = 0

Try {
    While (($NodeList).Count -le $Counter)
    {

$NodeList += $NodeValues[$Counter][0]
$Counter = $Counter + 1
}}

Catch { $Nodelist }
$Counter = 0

# Build Infra Node List
    
$Counter = 0

Try {
    While (($InfraList).Count -le $Counter)
    {$InfraList += $InfraValues[$Counter][0]
     $Counter = $Counter + 1}
    }

Catch { $InfraList }

$Counter = 0

# Build Physical Node Array

$Counter = 0
$NodeCounter = 0

ForEach ($Node in $NodeValues)
        {
            $NodeValuesSplit += $Node
        }

ForEach ($Value in $NodeValuesSplit) {
    If ($Value -like "*az*") {$Counter = 0 ; $CurrentNode = $Value }# Reset $NodeFields counter to replay values for each node.                                                
    $NodeOutput += [pscustomobject]@{'Node'=$CurrentNode;'Metric'=$NodeFields.Disp[$Counter];'Description'=$NodeFields.Desc[$Counter];'Value'=$Value}                                     
    $Counter = $Counter + 1                                                        
    $NodeCounter = $NodeCounter + 1                                                                             
} # ForEach $Value

# Build Infra Node Array

$Counter = 0
$NodeCounter = 0

ForEach ($Infra in $InfraValues)
    {$InfraValuesSplit += $Infra}

ForEach ($Value in $InfraValuesSplit) {
    If (($Value -like "*az*") -or ($Value -like "*ir*")) {$Counter = 0 ; $CurrentInfra = $Value }# Reset $InfraFields counter to replay values for each node.
    $InfraOutput += [pscustomobject]@{'Node'=$CurrentInfra;'Metric'=$InfraFields.Disp[$Counter];'Description'=$InfraFields.Desc[$Counter];'Value'=$Value}

    $Counter = $Counter + 1
    $NodeCounter = $NodeCounter + 1
} # ForEach $Value


# Build Cloud Array

$Counter = 0
$NodeCounter = 0

ForEach ($Cloud in $CloudValues)
    {$CloudValuesSplit += $Cloud}

ForEach ($Value in $CloudValuesSplit) {
    #If (($Value -like "*az*") -or ($Value -like "*ir*")) {$Counter = 0 ; $CurrentInfra = $Value } #Reset $InfraFields counter to replay values for each node.
    $CloudOutput += [pscustomobject]@{'Metric'=$CloudFields.Disp[$Counter];'Description'=$CloudFields.Desc[$Counter];'Value'=$Value}

    $Counter = $Counter + 1
    $NodeCounter = $NodeCounter + 1
} # ForEach $Value

# Write output

Write-Host -ForegroundColor Cyan "`nPhysical Hosts"
$NodeOutput | FT

Write-Host -ForegroundColor Cyan "`nInfra Nodes"
$InfraOutput | FT

Write-Host -ForegroundColor Cyan "`nCloud"
$CloudOutput | FT