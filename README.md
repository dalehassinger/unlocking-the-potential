### "Unlocking The Potential"

Collection of items for the VMware Aria Admin and Automation | Monitoring | Logging Enthusiast.

* VMware Aria Automation | vRA  
  * Templates
  * abx scripts
  * Actions
  * Custom Forms
  * Action Constants
  * Secrets
  * Workflows
* VMware Aria Automation Config | SaltStack Config
  * state files  
  * jobs
  * PowerShell Scripts to use VMware Aria Automation Config APIs
* VMware Aria Operations | vROPS
  * Dashboards  
  * Views
  * Super Metrics
  * Metric Search Examples
* VMware Aria Operations for Logs | Log Insight  
  * Load Balance Cloud Proxies
* PowerShell
  * Scripts
* PowerCLI
  * Scripts
* Ansible
  * Playbooks

If you can Script It, You can Automate it!  

Visit this Blog Site for additional Information:  
[www.vCROCS.info](https://www.vCROCS.info)

This code is to help someone get started and to give some ideas of what can be done with VMware Aria Products. All code should be used in a DEV environment first, until you understand all the steps that the process will complete. I always say there are a 100 ways to do the same process with Automation. These examples are how I would do the processes.

This is my way of giving back to the vCommunity. This code and examples are all mine and not the opinion of my employer.  

If anyone would have some examples that they would want to include in this repository to share with the vCommunity, please reach out.  

#vExpert #VMware #automation #monitoring #salt #powershell

### Release Details:  

---

2024-03-19
* added some Aria Automation Actions and Workflow to send messages to Microsoft Teams and Google Spaces.  
* Released with this Blog Post | [VMware Aria Automation | How to send messages and updates](https://www.vcrocs.info/aria-automation-messages-updates/)  

---

2024-02-17
* added PowerShell script to create a html file that has VMRC links for VMs. HTML file to be used with Text Display Widget within Aria Operations.  

---

2024-01-12
* added some common commands that I use with Photon OS. Command to set Photon password to never expire I use the most.  

---

2024-01-10
* added a Aria Automation Action that allows you to pick a VM from a Picker List and only return the VM Name. I then add the VM Name to the Deployment name to make it unique.  

---

2024-01-07
* added a (2) Aria Automation Actions to check the AD (Active Directory) OU (Organizational Unit) structure BEFORE creating a new Server. If the required OUs are not in place, the Action will create the OUs.  

---

2024-01-04
* added a Aria Automation Action to show the AD (Active Directory) OU that a Server (Computer Object) was located.  

---

2023-12-26
* added PowerShell Scripts to use with the VMware Aria Operations APIs. Shows the field Names to use with Servicenow Management Pack.  

---

2023-11-12
* added PowerShell Scripts to use with the VMware Aria Automation Config APIs  
* Released with this Blog Post | [Unlocking the Potential | VMware Aria Automation Config API](https://www.vCROCS.info/unlocking-the-potential-vmware-aria-automation-config-api/)

---

2023-10-19
* added Orchestrator action code to get all VM folders from vCenter  

---

2023-10-17
* added code to load balance VMware Aria Operations for Logs Cloud Proxies  

---

2023-08-18
* added code and screen shots from VMware Explore 2023 Presentation  

---

2023-08-01
* added example Powershell code to do RESTFULL API calls to VMware Aria Automation Config  

---
  
2023-06-25:  
* State file example using jinga to get a value from grains file and create a Windows registry key based on that value.  
* Added grains.get to the Salt-Command-Cheat-Sheet  

---
  
2023-06-24:  
* Added some PowerCLI Examples from a PowerBlock Presentation that I did.

---
  
2023-06-13:  
* Added super metric and view to show VM Snap Count

---
  
2023-06-05:  
* Added screen shot of Arial Operations Environment Overview Dashboard.  
* [Dashboard Screen Shot](https://github.com/dalehassinger/unlocking-the-potential/tree/main/VMware-Aria-Operations/Dashboards/TAM-Environment-Overview)  

---
  
2023-06-03:  
Initial Release.  
* Salt State Examples.  
* VMware Aria Automation Template Examples.  
* VMware Aria Operations Metric Search Examples.  
  
---
  
  
