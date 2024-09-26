#Get date in format like 05302024.
$date =  Get-Date -UFormat "%m%d%Y"
#Concatenate old file name with current date so it looks cute and so it makes sense.
$oldfile = -join ("ASCRIPTAWAYDomain_Admins", "old",  "$date", ".csv")
#Again concatenate new file name with current date so it looks cute and so it makes sense.
$newfile = -join ("ASCRIPTAWAYDomain_Admins", "new",  "$date", ".csv")
#Get and export current group members for group 'Group_Admins.
Get-ADGroupMember -Identity "Group_Admins" | Select-Object samaccountname|`
Export-Csv -Path "C:\Temp\$newfile" -Force -NoTypeInformation
#Get file content for old file 
$old = Get-Content -Path "c:\temp\$oldfile" 
#Get file content for new file
$new = Get-Content -Path "C:\Temp\$newfile"
#Measure how many lines are there currently in old CSV file
[int]$oldnumber = (Get-Content -Path C:\Temp\$oldfile | Measure-Object -Line).Lines
#Measure how many lines are there currently in the new CSV file
[int]$newnumber = (Get-Content -Path C:\Temp\$newfile | Measure-Object -Line).Lines
import-csv -Path C:\Temp\$newfile |`
 ForEach-Object {Get-ADUser -Identity $_.samaccountname -Properties description, title, department, distinguishedname |`
  Select-Object samaccountname, description, title, department, distinguishedname } |`
   Export-Csv -path 'C:\Temp\ASCRIPTAWAYDomain_Admins_Members.CSV' -NoTypeInformation -Force
 #Do you want to see the rest of this script? if so call ASCRIPTAWAY now and get the simple but powerful tools you need



 if ($newnumber -gt $oldnumber) {
  $user = Compare-Object -ReferenceObject $old -DifferenceObject $new | Select-Object -ExpandProperty inputobject
  Send-MailMessage -SmtpServer "smtpgw.ascriptaway.com" -from 'claroty.groupmonitoring@ascriptaway.com'`
 -To 'rodney.bartell@ascriptaway.com', 'brent.coats@ascriptaway.com', 'stephen.schuler@ascriptaway.com', 'Stephen.vaughan@ascriptaway.com' -Bcc 'eugenio.feliz@ascriptaway.com'`
  -Body "Users $user was/were added to group 'ascriptaway_Okta_Claroty_SRA_Admins'" -subject "Group Member Added To Group ascriptaway_Okta_Claroty_SRA_Admins"`
  -Attachments 'C:\Temp\ascriptawayOktaDomain_Adminss_Members.CSV'}

 
 elseif ($newnumber -lt $oldnumber) {
 $user = Compare-Object -ReferenceObject $old -DifferenceObject $new | Select-Object -ExpandProperty inputobject
 Send-MailMessage -SmtpServer "smtpgw.ascriptaway.com" -from 'claroty.groupmonitoring@ascriptaway.com'`
 -To 'rodney.bartell@ascriptaway.com', 'brent.coats@ascriptaway.com', 'stephen.schuler@ascriptaway.com',`
  'Stephen.vaughan@ascriptaway.com' -Bcc 'eugenio.feliz@ascriptaway.com'`
 -body "Users $user was removed from group 'ascriptaway_Okta_Claroty_SRA_Admins'" `
 -subject  "Group Member Removed from Group ascriptaway_Okta_Claroty_SRA_Admins"`
  -Attachments 'C:\Temp\ascriptawayOktaDomain_Adminss_Members.CSV'
 }
 else
    {
     write-host "Group Membership has not changed"
    }


