# create self-signed certificate for 'localhost', stored in Computer store and valid for 2 years
$selfCert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(2)

# make this certificate trusted (locally) (i.e. copy it from Personal store to Trusted Root CAs store)
$srcStore = New-Object System.Security.Cryptography.X509Certificates.X509Store "My", "LocalMachine"
$srcStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

$cert = $srcStore.certificates -match $selfCert.Thumbprint

$dstStore = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
$dstStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$dstStore.Add($cert[0])

$srcStore.Close()
$dstStore.Close()

# bind this certificate to our IIS website
New-IISSiteBinding -Name "Default Web Site" -BindingInformation "*:443:" -CertificateThumbPrint $selfCert.Thumbprint -CertStoreLocation "Cert:\LocalMachine\My" -Protocol https