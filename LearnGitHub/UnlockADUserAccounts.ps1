Search-ADAccount -lockedout | Select-Object Name, SamAccountname
Unlock-ADAccount -Identity samaccountname