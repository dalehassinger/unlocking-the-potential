Here is a list of commands that I use the most as a Windows Administrator.  
This cheat sheet should help you get Started.  

---

Command | Ping:

```
salt "vCROCS01" test.ping  
salt "*" test.ping  
salt "vC*" test.ping  
```

Results:  

```
vCROCS01:
    True
```

---

Command | Ping | with --output=json:

```
salt "vCROCS01" test.ping --output=json
```

Results:  
```
{
    "vCROCS01": true
}
```

---

Command:    

```
salt "vCROCS01" disk.usage
```

Results:  
```
vCROCS01:
    ----------
    C:\:
        ----------
        1K-blocks:
            67642364.0
        available:
            15229492.0
        capacity:
            77%
        filesystem:
            C:\
        used:
            52412872.0
    E:\:
        ----------
        1K-blocks:
            41809856.0
        available:
            38486208.0
        capacity:
            8%
        filesystem:
            E:\
        used:
            3323648.0
```

---

Command:  

```
salt "vCROCS01" disk.usage --output=json
```

Results:  
```
{
    "vCROCS01": {
        "C:\\": {
            "filesystem": "C:\\",
            "1K-blocks": 67642364.0,
            "used": 52424392.0,
            "available": 15217972.0,
            "capacity": "78%"
        },
        "E:\\": {
            "filesystem": "E:\\",
            "1K-blocks": 41809856.0,
            "used": 3323648.0,
            "available": 38486208.0,
            "capacity": "8%"
        }
    }
}
```
 
---

Command stop a Windows Service:

```
salt "vCROCS01" service.stop "spooler"
```

Results:  
```
vCROCS01:
    True
```

---

Command disable a Windows Service:

```
salt "vCROCS01" service.disable "spooler"
```

Results:  
```
vCROCS01:
    True
```

---

Command get status of a Windows Service:

```
salt "vCROCS01" service.status "spooler"
```

Results:  
```
vCROCS01:
    False
```

---

Command see if a Windows Service is enabled:

```
salt "vCROCS01" service.enabled "spooler"
```

Results:  
```
vCROCS01:
    False
```

---

Command Copy a file to a Windows Server - Source File | Destination File:

```
salt "vCROCS01" cp.get_file "salt://installer_file.msi" "C:\install_files\installer_file.msi"
```

Results:  
```
vCROCS01:
    C:\install_files\installer_file.msi
```

---

Command Delete a file from a Windows Server:

```
salt "vCROCS01" file.remove 'C:\install_files\installer_file.msi'
```

Results:  
```
vCROCS01:
    True
```

---
 
Command add grain data to a minion:

```
salt "vCROCS01" grains.append azure_vm "True"
```

```
vCROCS01:
    ----------
    azure_vm:
        - True
```

---

Command get grain custom data from a minion:

```
salt "vCROCS01" grains.get azure_vm
```

Results:  
```
vCROCS01:
    - True
```

---

Command get grain os data from a minion:

```
salt "vCROCS01" grains.get os
```

Results:  
```
vCROCS01:
    Windows
```

---

Command get grain os data from a minion:

```
salt "vCROCS01" grains.get osfullname
```

Results:  
```
vCROCS01:
    Microsoft Windows Server 2016 Datacenter
```

---

Command get grain domain data from a minion:

```
salt "vCROCS01" grains.get domain
```

Results:  
```
vCROCS01:
    vcrocs.info
```

---

Command get grain IP data from a minion:

```
salt "vCROCS01" grains.get fqdn_ip4
```

Results:  
```
vCROCS01:
    - 192.168.99.99
```

---

Command sync minion grain data with salt master:

```
salt "vCROCS01" saltutil.sync_grains
```

Results:  
```
vCROCS01:
```
 
---

Command run powershell Command:  

```
salt "vCROCS01" cmd.run 'Get-Service | Where-Object {$_.Status -eq "Running"}' shell=PowerShell
```

Results:  
```
vCROCS01:

    Status   Name               DisplayName
    ------   ----               -----------
    Running  AppHostSvc         Application Host Helper Service
    Running  BFE                Base Filtering Engine
    Running  BrokerInfrastru... Background Tasks Infrastructure Ser...
    Running  CbDefense          CB Defense
    Running  CDPSvc             Connected Devices Platform Service
    Running  CertPropSvc        Certificate Propagation
    Running  COMSysApp          COM+ System Application
    Running  CoreMessagingRe... CoreMessaging
```

---

Command run powershell script with script saved on salt master File Server: 

```
salt "vCROCS01" cmd.script source="salt://dev/qualys_install_azure.ps1" shell=powershell
```

Results:  
Runs all line of code in script the same as if script was saved local on minion.
 
---

Command minion reboot:

```
salt "vCROCS01" system.reboot 0
```

Results:  
```
vCROCS01:
    True
```
---

 
Command join minion to a Windows Domain. You can also specify OU that computer object will be located:

```
salt "vCROCS01" system.join_domain domain='vcrocs.info' username='vcrocs\administrator' password='VMware1!' account_ou='OU=Dev,OU=Servers,DC=vcrocs,DC=info' account_exists=False restart=True
```

---

 
Command add a registry key to minion or change value of an existing registry key:

```
salt "vCROCS01" reg.set_value HKEY_LOCAL_MACHINE 'SYSTEM\vCROCS' 'Created_by_User' 'dhassinger'
```

Results:  
```
vCROCS01:
    True
```

---

 
Command grains.get:

```
salt "EXPLORE-WIN-01" grains.get os
```

Results:  
```
EXPLORE-WIN-01:
    Windows
```  

By Adding --out=newline_values_only only the value is returned.   

```
salt "EXPLORE-WIN-01" --out=newline_values_only grains.get os
```

Results:  
```
Windows
```
