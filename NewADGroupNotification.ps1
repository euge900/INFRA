#Get date in format like 05302024.
$date =  Get-Date -UFormat "%m%d%Y"
#Concatenate old file name with current date so it makes sense.
$oldfile = -join ("ASCRIPTAWAYDomain_Admins", "old",  "$date", ".csv")
#Now concatenate new file name with current date it makes sense.
$newfile = -join ("ASCRIPTAWAYDomain_Admins", "new",  "$date", ".csv")
#Get and export current group members for group 'Group_Admins.
Get-ADGroupMember -Identity "Domain Admins" | Select-Object samaccountname|`
Export-Csv -Path "C:\Temp\$newfile" -Force -NoTypeInformation
#Get file content for old file 
$old = Get-Content -Path "c:\temp\$oldfile" 
#Get file content for new file
$new = Get-Content -Path "C:\Temp\$newfile"
#Measure how many lines are there currently in old CSV file
[int]$oldnumber = (Get-Content -Path C:\Temp\$oldfile | Measure-Object -Line).Lines
#Measure how many lines are there currently in the new CSV file
[int]$newnumber = (Get-Content -Path C:\Temp\$newfile | Measure-Object -Line).Lines
import-csv -Path C:\Temp\$newfile | ForEach-Object {Get-ADUser -Identity $_.samaccountname -Properties description, title,`
department, distinguishedname | Select-Object samaccountname, description, title, department, distinguishedname } |`
   Export-Csv -path 'C:\Temp\ASCRIPTAWAYDomain_Admins_Members.CSV' -NoTypeInformation -Force
if ($newnumber -gt $oldnumber) {
  $user = Compare-Object -ReferenceObject $old -DifferenceObject $new | Select-Object -ExpandProperty inputobject
  Send-MailMessage -SmtpServer "smtpgw.ascriptaway.com" -from "Groupmonitoring@ascriptaway.com" -to "efeliz@ascriptaway.com"`
 -Body "Users $user was/were added to group 'Domain Admins'" -subject "Group Member Added To Group Domain Admins"`
  -Attachments 'C:\Temp\Domain_Adminss_Members.CSV'}
elseif ($newnumber -lt $oldnumber) {
 $user = Compare-Object -ReferenceObject $old -DifferenceObject $new | Select-Object -ExpandProperty inputobject
 Send-MailMessage -SmtpServer "smtpgw.ascriptaway.com" -from 'Groupmonitoring@ascriptaway.com'
-body "Users $user was removed from Group Domain Admins" -subject  "Group Member Removed from Group Domain Admins"`
  -Attachments 'C:\Temp\Domain_Adminss_Members.CSV'
 }
 else
    {
     write-host "Group Membership has not changed, email will not be sent"
    }


