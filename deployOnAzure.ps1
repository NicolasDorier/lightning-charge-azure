# This
# Assume your ran logged to azure with
# Login-AzureRmAccount 
# Then you selected your subscript with
# Get-AzureRmSubscription –SubscriptionName "your subscription" | Select-AzureRmSubscription
param([String]$ResourceGroupName, [String]$Network)

$rg = $ResourceGroupName

$usr = ([char[]]([char]'a'..[char]'z') + ([char[]]([char]'A'..[char]'Z')) + 0..9 | Sort-Object {Get-Random})[0..8] -join ''
$pass = ([char[]]([char]'a'..[char]'z') + ([char[]]([char]'A'..[char]'Z')) + 0..9 | Sort-Object {Get-Random})[0..16] -join ''
$pass = $pass + 'aB1' # So we satisfy 100% sure the password requirements

$parameters = `
@{"adminUsername" = $usr;`
  "adminPassword" = $pass;`
  "network" = $Network;
}

New-AzureRmResourceGroup -Name $rg -Location "South Central US"
New-AzureRmResourceGroupDeployment -ResourceGroupName $rg -TemplateFile "azuredeploy.json" -TemplateParameterObject $parameters


$site = (Get-AzureRmPublicIpAddress -ResourceGroupName $rg).DnsSettings.Fqdn

$cmd = "ssh $usr@$site"

$temp += "Lightning server on Network: $Network`n"
$temp = "Username: $usr`n"
$temp += "Password: $pass`n"
$temp += "Machine address: $site`n"
$temp += "Command line: $cmd`n`n"

$temp += "Your Lightning server instance will be available shortly on: https://$site/ with a staging certificate from Let's Encrypt!`n"
$temp += "Your next steps are:`n"
$temp += "`t1. Add the following DNS record to your domain server: `"your-domain.com. CNAME $site.`"`n"
$temp += "`t2. Connect via SSH to this virtual machine, and run `". ./changedomain your-domain.com`"`n"
$temp += "You will then have a fully HTTPS configured access to your own Lightning Server instance"

Write-Host $temp