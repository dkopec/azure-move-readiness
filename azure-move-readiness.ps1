[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $OriginSubscription,
    [Parameter()]
    [String]
    $DestinationSubscription
)

function Get-AzSubscriptionID {
  # Login to your Azure account
  Connect-AzAccount

  # Get all subscriptions
  $subscriptions = Get-AzSubscription

  # Display all subscriptions
  $subscriptions | Format-Table -Property Id, Name

  # Ask for user input to select a subscription
  $selectedSubscriptionName = Read-Host -Prompt 'Input the Name of the subscription you want to select'

  # Get the selected subscription
  $selectedSubscription = $subscriptions | Where-Object { $_.Name -eq $selectedSubscriptionName }

  # Store the selected subscription's ID in a variable
  $selectedSubscriptionId = $selectedSubscription.Id

  # return the selected subscription's ID
  return $selectedSubscriptionId
}

Write-Information "There are some important steps to do before moving a resource. By verifying these conditions, you can avoid errors."

Write-Information "1. The source and destination subscriptions must be active. If you have trouble enabling an account that has been disabled, create an Azure support request. Select Subscription Management for the issue type."

Write-Information "The source and destination subscriptions must exist within the same Microsoft Entra tenant."

if (!$OriginSubscription ){
  $OriginSubscription = Get-AzSubscriptionID
}

$OriginTenant = (Get-AzSubscription -SubscriptionName $OriginSubscription).TenantId

if (!$DestinationSubscription){
  $DestinationSubscription = Get-AzSubscriptionID
}

$DestinationTenant = (Get-AzSubscription -SubscriptionName $DestinationSubscription).TenantId

$InTheSameTenant = $OriginTenant.CompareTo($DestinationTenant)

If (!$InTheSameTenant) {
  Write-Error "Tenant IDs for the source and destination subscriptions aren't the same, use the following methods to reconcile the tenant IDs: \n
  https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/billing-subscription-transfer \n
  https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory
  "
}

