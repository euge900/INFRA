#Create your function to make code repeatable
Function New-AscriptAwayEmployee
{
[cmdletbinding()]
  param(
       [parameter(mandatory,
       HelpMessage="Copyfrom!Enter the name of an existing contractor who you would like to copy group membership, title, company, manager, description" )]
       [string]$copyfrom,
       [parameter(mandatory,
       HelpMessage="Enter the Title for new user" )]
       [string]$title
       )
#Create needed variables, always start at the top
$name = Read-Host "What is the user's fullname?"
$manager = Read-Host "What is the new user's manager name? be sure to enter samaccountname"
$fullfirstname = $name.Split()[0]
$firstinitial =  $name[0]
$lastname =  $name.Split()[1]
$sam = -join ("$firstinitial", "$lastname")
$userprn = -join ("$sam", "@AscriptAway.com")
$targetou = 'OU=Users,OU=ASC-Intune,DC=AscriptAway,DC=com'
#Write getting started message
Write-Host "Let's get started, connecting to required services Azure AD, ExchangeOnline and M365. drink some strong coffee & wait a couple of seconds to answer any prompts." -ForegroundColor Green
#Connect to Microsoft Online and Exchange online services with your admin account. Ensure MFA is enabled.
Connect-MsolService
Connect-ExchangeOnline
#Create an 8 character long paassword, save it to variable and display it so it can be copied for user to login.
Add-Type -AssemblyName system.web 
$password = ([System.Web.Security.Membership]::GeneratePassword(8,2))
Write-Host "Below is User's Password you can copy from here to password vault"
#Display the newly created password
$secpassword = Write-Host $password -ForegroundColor Red
#Create user account setting propterties full, last name, OU,
New-ADUser -Name $name -GivenName $fullfirstname -Surname $lastname -SamAccountName "$sam" `
-Enabled $true -UserPrincipalName $userprn -EmailAddress $userprn -Title $title -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -Path $targetou 
#Display the new AD account info to the display
Write-Host "Below is the SamAccountName that you will need to paste later on!" -ForegroundColor Green
Write-Host $sam -BackgroundColor Red
#Find user to copy Organization infor from.
$oth = Get-ADUser -Identity $copyfrom -Properties department, company, office |`
 select -Property department, company, office, DistinguishedName
#Create variables to copy Organization info from other user who will be the same department and share same boss
$department = $oth.department
$company =$oth.company
$office = $oth.office
#sleep for 3 seconds
Start-Sleep -Seconds 3
#Copy Organization information from copy user.
Set-ADUser -Identity $sam -Company $company -Department $department -Manager $manager -Description $title -Office $office -DisplayName $name
#All employees AD groups
$allemployees = 'ASC_All Employees'
$hello = 'ASC_WHFB'
$alldirves = 'Drives_AllEmployees'
#Adding All Employees default groups!
Write-Host "Adding AD groups 'ASC_All Employees', 'ASC_WHFB', 'Drives_AllEmployees'!" -ForegroundColor Green
$allgroups =  $allemployees, $hello, $alldirves
foreach ($group in $allgroups) {Add-ADGroupMember -Identity $group -Members $sam -Verbose}
#See new user's information and keep variable for later.
Write-Host "Review the new user info to ensure everything looks good before moving on" -ForegroundColor Green
#Copy sam account name for later use
$sam | clip 
Get-usergeneralinfo -user $sam 
 #Connect to domain controller and run a syncall to the other DCs.
Write-Host "connecting to Domain controller to sync changes" -ForegroundColor Green
$s = new-PSSession -ComputerName 'DC01-PROD'
Invoke-Command -session $s -scriptblock {repadmin /syncall}
Start-Sleep -Seconds 3
Get-PSSession | Remove-PSSession
#Connect to AD connect server and invoke a delta policy syncrhonization.
Write-Host "connecting to AD connect server to initialize a delta sync cycle!" -ForegroundColor Green
$s1 = New-PSSession -ComputerName 'ASC-Connect-01' 
Invoke-Command -Session $s1 -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
#Sleep for 3 seconds
Start-Sleep -Seconds 3
#Remove remote pssession to the domain controller
Get-PSSession | Remove-PSSession
#Sleep for 10 seconds otherwise script is too fast
Start-Sleep -Seconds 10
#Connect to Azure AD & add user to groups.
Write-Host "Next, let's connect to azure AD to add azure AD groups, make sure to use your A-samaccountname admin account" -ForegroundColor Green
#Connect to Entra ID
Connect-AzureAD
#Write to the screen a message about status and coffee lol
Write-Host "Check out the new user in Azure AD below and keep sipping on that coffee!" -ForegroundColor Green
#Prompt to do Ctrl-V to past or simply do right click
[string]$AzString = Read-Host "Do Ctrl+V to paste samaccount information"
#Verify you have the user
Get-AzureADUser -SearchString $AzString
#Create a variable for the same user and select unict object ID
$refobj = Get-AzureADUser -SearchString $AzString | select -ExpandProperty objectid
Write-Host "Adding license 'M365 Defender Enduser' plus adding user to 'All AscriptAway' Teams group" -ForegroundColor Green 
#Add user to 'M365 Defender Enduser' group
Add-AzureADGroupMember -ObjectId adh02834-msdf79237-oaj2635 -RefObjectId $refobj -Verbose
#Add user to All AscriptAway Teams Group
Add-AzureADGroupMember -ObjectId 9823498-2398u3241y3-983248 -RefObjectId $refobj -Verbose
#“Pick M365 Business Premium” or "M365 Business Premium + Teams Phone". These are dummy object IDs. 
#Please enter your own or email scripthelp@ascriptaway.com for help.
Write-Host "Now let's pick M365 license" -ForegroundColor Green
$M365 = Read-Host "Will new user need 'M365 Business Premium + Teams Phone' or  'M365 Business Premium' license? Please select 1 for 'M365 Business Premium + Teams Phone' or 2 for 'M365 Business Premium' without Teams phone” 
$M365Lcs = switch ($M365)
{ 
1{Add-AzureADGroupMember -ObjectId 12basd89-90asdb-0823823 -RefObjectId $refobj -Verbose}
2{Add-AzureADGroupMember -ObjectId 0823734-82939sdfj-928023 -RefObjectId $refobj -Verbose}    
   }
#Pause for a second otherwise script is too fast
Start-Sleep -Seconds 5
#Add new employee to allAscriptAway employee distribution group.
Write-Host "Almost done now, connecting to exchange online to add user to distribution group 'allAscriptAwayemployees@AscriptAway.com'" -ForegroundColor Green 
#Add user to distribution group
Add-DistributionGroupMember -Identity 'allAscriptAwayemployees@AscriptAway.com' -Member $userprn
#Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
#Disconnect from Entra ID
Disconnect-AzureAD
#Creae Strong Authentication requirement object
$sa = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$sa.RelyingParty = "*"
$sa.State = "Enforced"
$sar = @($sa)
#Enforce MFA for the user
Set-MsolUser -UserPrincipalName $userprn -StrongAuthenticationRequirements $sar
#Display user's password
Write-Host "Here is new user $sam's password $password" -ForegroundColor Green
Write-Host "IF there were errors adding licenses or AzureADgroups run command 'Add-EmployeeUserLicenses' next to add licenses and add MFA"
} 
New-AscriptAwayEmployee
