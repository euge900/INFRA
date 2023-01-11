Connect-Okta -FullDomain "oktahttpsurl" -Token '08234utokenhere'


Set-OktaOption -ApiToken 08234utokenhere -BaseUri oktahttpsurl

#Get-OktaUser |  select -Property lastlogin, id, profile | ? {$_.profile -like "*domain*" -and $_.profile -notlike "*otherdomain*"} |select -ExpandProperty profile | select login, email


Get-OktaUser |  select -Property lastlogin, id, profile | ? {$_.profile -like "*domain*" -and $_.profile`
 -notlike "*otherdomain*"} | select lastlogin, id, profile | Export-Csv -Path C:\Temp\oktausers.csv -Force -NoTypeInformation


1..100 | foreach {Get-OktaUser -next | select -Property lastlogin, id, profile | ? {$_.profile -like "*domain*" -and $_.profile`
 -notlike "*otherdomanin*"} |select lastlogin, id, profile | Export-Csv -Path C:\Temp\oktausers.csv -Append -NoTypeInformation }