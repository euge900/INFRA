#This script was created to create single AD user at the time and add Office licenses, by running 'new-regularuser' from an elevated Powershell session with admin priviledge.
#Before you can run any command below, please install Active directory module by running "Install-Module -name Active Directory.
#Also this script will create a remote session with domain controller and sync Azure AD connect to Azure which'
#will then syncs to Office 365.
#Author: Eugenio Feliz. Let me know if you need help with this script.
#This script is customized to run at my current job, you will need to make some minor changes like domain name and gloabal admin account also Distinguishedname

Function New-regularuser

{
[cmdletbinding()]
  param(
       [parameter(mandatory=$true)]
       [string]$copyfrom

  )


$password = Read-Host "Enter Password New User" -AsSecureString
$name = Read-Host "What is the user's fullname?"
$firstname =  $name.Split()[0]
$lastname =  $name.Split()[1]
$sam = "$firstname.$lastname"
$userprn = "$firstname.$lastname@somedomain.com"
$path = "DistinguishedName"



Write-Host "User is being created, wait a couple of seconds and answer any prompt."


New-ADUser -Name $name -GivenName $firstname -Surname $lastname -SamAccountName "$firstname.$lastname" -Path $path `
-Company $company -UserPrincipalName $userprn -AccountPassword $password -Enabled $true -DisplayName $name

write-host "Setting up Email address"
Set-ADUser -Identity "$firstname.$lastname" -Add @{proxyAddresses="SMTP:$userprn"}



#Find user to copy Organization infor from.
$oth = Get-ADUser -Identity $copyfrom -Properties * | select -Property title, department, company, manager, description,`
distinguishedname



#Create variables to copy Organization info.
$title = $oth.title

$department = $oth.department

$company =$oth.company

$manager = $oth.manager

$description = $oth.description




#Discover and add to a variable all groups from user you are copying from.
$membership = Get-ADUser -Identity $copyfrom -Properties *| Select-Object -ExpandProperty memberof


#Copy all the group memberships from the user you are copying.
foreach ($group in $membership) {Add-ADGroupMember -Identity $group -Members $sam}



#Copy Organization information fro copy user.
Set-ADUser -Identity $sam -Company $company -Department $department -Title $title -Manager $manager -Description $description `
-EmailAddress $userprn


#In case you need to remove email address isntantly.
#Set-ADUser -Identity $h -Remove @{Proxyaddresses="SMTP:$upn"}



#Create a remote session to DC and synchronize AAD connect to the cloud.

Write-Host "Connecting to Domain Controller to sync AAD, please enter password."

$ses = New-PSSession -ComputerName "DomainControllername" -Credential  (get-credential -credential domain\globaladminusername)

$id = $ses.id

Invoke-Command -Session $ses -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}



#Ensure you remove session as too many sessions can cause issues.
Remove-PSSession -Id $id


#Connect to Microsoft Office 365 and assign license to user.
Write-Host "Connecting to Microsoft Online Services to assign licenses."

Connect-MsolService


set-MsolUser -UserPrincipalName $userprn -UsageLocation "us"


Set-MsolUserLicense -UserPrincipalName $userprn -AddLicenses "reseller-account:O365_BUSINESS_PREMIUM"



#Login to SPANNING365 AND Assign Spanning365 Backup license.

Get-SpanningAuthentication -ApiToken apitokenid -Region US -AdminEmail "globaladmin@somedomain.com"

Enable-SpanningUser -UserPrincipalName $userprn



}

New-regularuser
