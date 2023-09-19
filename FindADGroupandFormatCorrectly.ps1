Get-ADGroup -Filter * -Properties description | `
? {$_.name -like "*braincube*"} | select name, description | `
Export-Csv -Path C:\Temp\BraincubeGroups.csv -NoTypeInformation | Format-Table -Wrap