# projectlearn
The following project is geared towards automating and using different services within Windows and Azure. Services like Azure NetApp Files, Azure Firewall, and Guest Policy (DSC). We will use WVD as the core service in this project. The focus will be delivering other services that should be used with WVD, but not WVD itself. WVD is already fairly automated.


The Logic App creates and uses a Managed System Identity (MSI) to authenticate and authorize against api.securitycenter.windows.com to update threat indicators.

The MSI must be assigned API Permissions to WindowsDefenderATP App. To assign use PowerShell and AzureAD Module.

$msi = Get-AzureADServicePrincipal | ?{$_.DisplayName -ieq "Restrict-MDATPUrl"}
$graph = Get-AzureADServicePrincipal -Filter "AppId eq 'fc780465-2017-40d4-a0c5-307022471b92'"
$roles = $graph.AppRoles | ?{$_.Value -imatch "Ti.ReadWrite" }

Foreach ($role in $roles){
New-AzureADServiceAppRoleAssignment -ObjectId $msi.ObjectId -PrincipalId $msi.ObjectId -Id $role.Id -ResourceId $graph.ObjectId
}
