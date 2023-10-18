#Searched for enabled Active directory users whose samaccountname do not contain "adm", "svc" and description does not say don't delete'
#also gets accounts with passwordneverexpires property set to false.
$date =  get-date 
$45ago = $date.AddDays(-45)

Get-ADUser -Filter * -SearchBase "OU=Sites,DC=corp,DC=ascriptaway,DC=com" -Properties SamAccountName,`
 enabled, ObjectGUID, passwordneverexpires, description, modified, lastlogondate, lastbadpasswordattempt |`
  Where-Object {$_.enabled -eq $true -and $_.DistinguishedName -notlike "*service accounts*" -and $_.description`
-notlike "*service*" -and $_.samaccountname -notlike "*adm*" -and $_.samaccountname -notlike "*svc*" -and`
 $_.description -notlike "*DO NOT DELETE*" -and $45ago -gt $_.modified -and $45ago -gt $_.lastlogondate`
-and $45ago -gt $_.lastbadpasswordattempt}| Select-Object ObjectGUID, samaccountname, enabled,`
 modified, lastlogondate, lastbadpasswordattempt, description | Export-Csv `
 -Path "C:\Temp\DisabledUsersGUID.csv" -NoTypeInformation -Force


#Moving disable users to inactive OU OU=InactiveAccounts,DC=corp,DC=ascriptaway,DC=com,
#objectGUID seems to be the only way to move all the objects.
Import-Csv -Path C:\Temp\DisabledUsersGUID.csv |`
ForEach-Object {Move-ADObject  $_.'ObjectGUID' -TargetPath "OU=InactiveAccounts,DC=corp,DC=ascriptaway,DC=com"}

#Find users who haven't logged on to their computers in more than 90 days while excluding admin accounts and some 
#service accounts then export to a list.
$date =  get-date 
$90ago = $date.AddDays(-90)

 Get-ADUser -Filter * -SearchBase "OU=InactiveAccounts,DC=corp,DC=ascriptaway,DC=com" -Properties modified, lastlogondate,`
  enabled, description| Select-Object samaccountname, modified, lastlogondate, lastbadpasswordattempt, enabled, description |`
 Where-Object {$90ago -gt $_.modified -and $90ago -gt $_.lastbadpasswordattempt -and  $_.samaccountname -notlike "*adm*"`
-and $_.enabled -eq $false -and $_.samaccountname -notlike "*svc*" -and $_.description -notlike "*service*"`
 -and  $_.description -NotLike "*DO NOT DELETE*" -and $_.employeetype -notlike "*domain.com*"} |`
Export-Csv -LiteralPath 'C:\Temp\InactiveUserstodelete.csv' -NoTypeInformation -Force

#Use created list to delete users from Active directory.
import-csv -Path 'C:\Temp\InactiveUserstodelete.csv' |`
 ForEach-Object {Remove-ADUser -Identity $_.'samaccountname' -Verbose}
#If you need to bring a users back to life from recycle bin
restore-adobject -Identity 'samaccountname' 
