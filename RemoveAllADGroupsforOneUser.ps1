$u = Read-Host "Enter the SamAccountName for the user you need to remove from all beloging groups"

Write-Host "Removing All group memberships from user $u"

$user = Get-ADUser -Identity $u -Properties  memberof, emailaddress

$groups = $user.MemberOf

$member = $user.SamAccountName
 
foreach ($grp in $groups) {Remove-ADGroupMember -Identity $grp -Members $member -Confirm:$false}