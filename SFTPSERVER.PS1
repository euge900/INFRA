#Author Eugenio Feliz, eugeniof13@gmail.com
#Connect to SFTP server, find file based on name and date, download the file to local host and delete file at source SFTP server 
#then connect to Destination SFTP server and upload the file, once upload is finished, delete file from local host and clean
#Recycle bin so there is no trace of file and is compliant with HIPAA.
#Using a PuTTY Private Key connect to your source SFTP server and find a file based on the name and date, if the file exists
#it will download it to your local computer while deleting the source file on the source SFTP server. Then Connect to destination
#SFTP server and upload the file there, finally delete the file in the local computer and clear recycle bin so there is
#no trace of file left and that way comply with HIPAA standards.
#You will need to download WinSCP module for these commands to work.


#dates on day, month and year.
$d = get-date -format dd
$m = get-date -format MM
$y = get-date -format yyyy

#test the results of the variables.
Write-Host $y$m$d
Write-Host *FileName.txt$y$m$d


#Variables for hostname, username, password, fingerprint, path to remote key
$username = "Username"

$pwd = ConvertTo-SecureString "passkeynow" -AsPlainText -Force

$sshHostKeyFingerprint = "ecdsa-sha2-nistp256 256 8FTVGV986GVB598ghbn548977"

$HostName = "SOURCEFTPNAMEORIP"

$pathtokey =  "C:\id_rsa.ppk"

$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $pwd


$sessionOption = New-WinSCPSessionOption -HostName $HostName -SshHostKeyFingerprint $sshHostKeyFingerprint `
 -SshPrivateKeyPath $pathtokey  -Credential $creds

New-WinSCPSession -SessionOption $sessionOption 

$Session = Get-WinSCPSession


#Query to search for file.
$file = Get-WinSCPChildItem -WinSCPSession $Session -Path "SFTPPATHNAME" -Filter * |  `
? {$_.name -like  "*FileName.txt$y$m$d*"}


#Download FILE from SFTP and then delete source.
Receive-WinSCPItem -RemotePath $file.FullName -LocalPath C:\ -Remove



#Remove SFTP Session.
Remove-WinSCPSession -WinSCPSession $Session








#Uploading file to destination server.
#Below are variables for creating session to destination server.

$destuser = "username" 

$key = ConvertTo-SecureString 'PASSWORD' -AsPlainText -Force 

$cre = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $destuser, $key

$Desthost = "IPORHOSTNAME"

$destsshfingerprnt =  "ssh-ed25519 255 FINDSSHFINGERPRINTONMANUALCONNECTIONTOSERVER="

$sesopt = New-WinSCPSessionOption -HostName $Desthost -SshHostKeyFingerprint $destsshfingerprnt -Credential $cre

#Create the session.
New-WinSCPSession -SessionOption $sesopt

$S = Get-WinSCPSession



#List document to send.
$doctoSend = Get-ChildItem -Path C:\ | ? {$_.Name -like "*FileName.txt$y$m$d*"}


#Upload File to SFTP server.
Send-WinSCPItem -LocalPath $doctoSend.FullName -RemotePath data


#Remove SFTP Session.
Remove-WinSCPSession -WinSCPSession $s


#Remove file from local workstation.
$doctoSend | Remove-Item 


#clean Recycle bin.
Clear-RecycleBin -Force 





