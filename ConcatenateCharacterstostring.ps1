$dom = "@gmail.com"
$users = Import-Csv -Path 'C:\Temp\Oktadeleteusers.csv'
foreach ($u in $users) {-join "$u", "$dom"}


Import-Csv -Path 'C:\Temp\Listofusers.csv'| foreach {-join ($_.email, "$dom")} | Export-Csv -Path 'C:\Temp\Oktadeleteusers.csv' -Force 
