#Connect to Azure with an admin account of course.
Connect-AzAccount

#If you have multiple subscriptions, make sure to select the correct one. 
Set-AzContext -Subscription "sandbox"

#Creat a variable referencing the Azure VPN Gateway.
$gw = Get-AzVirtualNetworkGateway -Name "ConsultantVPNGWTEST" -ResourceGroupName "RG-SANDBOX-EAST-01"


#Set the Custom Route  for the Virtual network so that Remote users can reach certain resources otherwise not available.
Set-AzVirtualNetworkGateway -VirtualNetworkGateway $gw -CustomRoute 10.113.0.0/24, 10.114.0.0/24, 20.49.104.32/32, 20.49.97.9/32

#View the the added Azure VPN custom routes.
$gw.CustomRoutes


#If you need to remove all Azure VPN custom routes just do as below.
Set-AzVirtualNetworkGateway -VirtualNetworkGateway $VPNGW2 -CustomRoute @()

#But if you need to remove only one Custom route do as below.
Set-AzVirtualNetworkGateway -VirtualNetworkGateway $VPNGW2 -CustomRoute @(8.8.8.8/32)