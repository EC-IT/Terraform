
# Connect with manage identity automation-infra-umi
Connect-AzAccount -Identity -AccountId "xxxxx-xxx-xxx-xxx-xxxxx"
Select-AzSubscription -Subscription "xxxxx-xxx-xxx-xxx-xxxxx"


<# Starting VM which have a Start-Order tag #>
[array]$VMs = Get-AzVm -Status | `
Where-Object {$PSItem.Tags.Keys -eq "ENVIRONMENT" -and $PSItem.Tags.Values -eq "PRE-PROD" `
-and $PSItem.Tags.Keys -eq "START-ORDER"`
-and $PSItem.PowerState -eq "VM deallocated"
} | `
Sort-Object {$PSItem.Tags["START-ORDER"]}

ForEach ($VM in $VMs)
{
    Write-Output "Starting: $($VM.Name)"    
    Start-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
}     

<# Starting VM without a Start-Order tag #>
$VMs = Get-AzVm -Status | `
Where-Object {$PSItem.Tags.Keys -eq "ENVIRONMENT" -and $PSItem.Tags.Values -eq "PRE-PROD" `
-and ! $PSItem.Tags.Keys.Contains("START-ORDER") `
-and $PSItem.PowerState -eq "VM deallocated"
}
 
ForEach ($VM in $VMs)
{
    Write-Output "Starting: $($VM.Name)"
    Start-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
}     
