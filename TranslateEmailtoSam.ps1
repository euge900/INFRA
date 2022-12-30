$Lu = Import-Csv -Path "C:\Temp\WhenCreated - Sheet1.csv"

$lu | measure

Get-ADUser -Filter * -Properties 'employeetype', 'samaccountname', 'mail', 'emailaddress', 'userprincipalname' | ? {$lu.email -contains $_.employeetype`
-or $lu.email -ccontains $_.userprincipalname -or $lu.email -contains $_.mail -or $lu.email -contains $_.emailaddress} | select samaccountname, employeetype, mail |`
 select 'samaccountname' | export-csv  "C:\Temp\Poka SSOSAM.csv"

$lu | measure

$lu.email