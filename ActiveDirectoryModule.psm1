#Get a list of Active directory users with similar naming converntion.
function find-user
{
param(
[parameter(mandatory=$true)]
[string[]]$user
)
Get-ADUser -Filter * -property name, samaccountname, title, employeeid, physicalDeliveryOfficeName, description | ? {$_.name -like "*$user*"} |`
 select name, samaccountname, title, employeeid, physicalDeliveryOfficeName, enabled, description| Format-Table -Wrap
}
find-user


#Get a list of Active Directory groups with similar naming convention.
Function Find-group
{
param(
[Parameter(mandatory=$true)]
[string[]]$group 
)
Get-ADGroup -Filter * -property name, groupcategory, groupscope, description, whenCreated, whenChanged | ? {$_.name -like "*$group*"}|`
 select name, groupcategory, groupscope, description, whenCreated, whenChanged   | Format-Table -Wrap
 }
Find-group


#Get a list of AD computers with similar naming convention.
function Find-computer
{
param(
[parameter(mandatory=$true)]
[string[]]$computername
)
Get-ADComputer -Filter * -property name, DNSHostName, enabled | ? {$_.name -like "*$computername*"}`
 | select name, DNSHostName, enabled | Format-Table -Wrap
 }
Find-Computer



#List all of the AD groups a users is a member of.
FUnction Get-UserGrpMembership 
{
param(
[parameter(Mandatory = $true)]
[string[]]$user
)
Get-ADUser -Identity "$user" -Property memberof | select -ExpandProperty memberof
 }
Get-UserGrpMembership


#List all group members of an active directoy group and format them by name and samaccountname.
Function Get-GroupMembership
{
param(
[parameter(Mandatory=$true)]
[string[]]$gname
)
Get-ADGroupMember -Identity "$gname" | select name, samaccountname | Format-Table -Wrap
 }
Get-GroupMembership


#Copy all AD groups a user is a member of to another user so they have equal access.
function Copy-adgrpmembership
{
param(
[parameter(mandatory=$true)]
[string]$copyfrom,
[parameter(mandatory=$true)]
[string]$copyto
)

$membership = Get-ADUser -Identity $copyfrom -Properties *| Select-Object -ExpandProperty memberof

foreach ($group in $membership) {Add-ADGroupMember -Identity $group -Members $copyto}

}

Copy-adgrpmembership


#Remove a user from a group by typing 'remove-userfromgroup -groupname 'group'.
function Remove-userfromgroup
{
param(
[parameter(mandatory=$true)]
[string]$groupname,
[parameter(mandatory=$true)]
[string]$user
)
Remove-ADGroupMember -Identity $groupname -Members $user 

}
Remove-userfromgroup


#Add a user to a group by simply typing add-usertogroup -groupname 'group'.
function Add-UsertoGroup
{
param(
[parameter(mandatory=$true)]
[string]$groupname,
[parameter(mandatory=$true)]
[string]$user
)
Add-ADGroupMember -Identity $groupname -Members $user
}
Add-UsertoGroup

#add users to a designated number of groups this is for adding groups that are added very often
function add-usertopvlgroups
{
param(
[parameter(mandatory=$true)]
[string]$admuser
)

$privilegedgrps = 'SD Team Admin Access', 'TDS_RO_Share_access', 'Helpdesk Level3'

foreach ($group in $privilegedgrps) {Add-ADGroupMember -Identity $group -Members $admuser
}
 }
add-usertopvlgroups


 



#List user's Active directory activity information like when was the password last changed and more.
function get-useractivity 
{
param(
[parameter(mandatory=$true)]
[string]$usertocheck
)
Get-ADUser -Identity $usertocheck -Properties whencreated, whenchanged, passwordlastset, modified, lastlogondate, PasswordExpired,`
lastbadpasswordattempt | select whencreated, whenchanged, passwordlastset, modified, lastlogondate, PasswordExpired, lastbadpasswordattempt
 
}
get-useractivity 



#Move a user to a designated OU for instance disabled OU.
Function Move-UserToInactiveOU
{
param(
[parameter(Mandatory=$true)]
[string]$usertomove
)
Move-ADObject -Identity $usertomove -TargetPath "Distinguishedname"
}
Move-UserToInactiveOU





#Get user's AD important information by simply typing get-usergeneralinfo -user 'usernam'.
Function Get-usergeneralinfo
{
param(
[parameter(Mandatory=$true)]
[string]$user
)
Get-ADUser -Identity $user -Properties lockedout, employeetype, EmployeeID, mail, emailaddress, DistinguishedName, office, title, department, whencreated, whenchanged, passwordlastset,`
description, modified, lastlogondate, lastbadpasswordattempt, PasswordExpired, manager, surname | select -Property samaccountname, enabled, employeetype, EmployeeID, mail, emailaddress,`
 DistinguishedName, office, title, department, UserPrincipalName, whencreated, whenchanged, passwordlastset, description, modified, lastlogondate, lastbadpasswordattempt,`
 PasswordExpired, manager, givenname, surname, lockedout
}
Get-usergeneralinfo 


#Generate a 25 characters password on the spot by simply typing new-25characterpassword.
Function new-25characterpassword
{

Add-Type -AssemblyName system.web
([System.Web.Security.Membership]::GeneratePassword(25,2))
 }

new-25characterpassword


#List all Distribution groups in your you Active Directory environment.
Function Get-AllADDistributiongroups
{
    Get-ADGroup -Filter * | ? {$_.GroupCategory -like "*distrib*"} |`
     Select-Object name, ObjectGUID
}