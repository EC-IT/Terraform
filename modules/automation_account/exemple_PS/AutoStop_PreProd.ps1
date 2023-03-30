
# Connect with manage identity automation-infra-umi
Connect-AzAccount -Identity -AccountId "xxxxx-xxx-xxx-xxx-xxxxx"
Select-AzSubscription -Subscription "xxxxx-xxx-xxx-xxx-xxxxx"


[array]$VMs = Get-AzVm -Status | `
Where-Object {$PSItem.Tags.Keys -eq "ENVIRONMENT" -and $PSItem.Tags.Values -eq "PRE-PROD" -and $PSItem.Tags['AUTOMATION'] -ne "NOSTOP" `
-and $PSItem.PowerState -eq "VM running"}

ForEach ($VM in $VMs) 
{
    Write-Output "Shutting down: $($VM.Name)"
    Stop-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Force
}     

