#In this script we have a CSV list of emails missing the @domain.com portion at the end of each email.
#We need to use -jon to add @domain.com at the end for intance there is a user with email 
#'eugeniof13' but it is missing the domain portion to read 'eugeniof13@gmail.com'.

$dom = "@domain.com"
$users = Import-Csv -Path 'C:\Temp\Oktadeleteusers.csv'
foreach ($u in $users) {-join "$u", "$dom"}


Import-Csv -Path 'C:\Temp\Oktadeleteusers.csv'| foreach {-join ($_.email, "$dom")} | Export-Csv -Path 'C:\Temp\Oktadeleteusers.csv' -Force 

