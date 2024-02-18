# State File Windows Servers - VMware Explore 2023

# Set Registry Values
Reg_Setting_Aria:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: Aria_Automation_Created
    - vdata: True
    - vtype: REG_SZ

Reg_Setting_Build_By:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: Build_BY
    - vdata: 'Dale Hassinger'
    - vtype: REG_SZ

Reg_Setting_Build_Date:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: Build_Date
    - vdata: {{ salt["system.get_system_date"]() }}
    - vtype: REG_SZ

Reg_Setting_E_Drive:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: E_Drive_Size
    - vdata: {{ salt['grains.get']('vCROCS_Drive_E_Size')[0] }}
    - vtype: REG_SZ

Reg_Setting_L_Drive:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: L_Drive_Size
    - vdata: {{ salt['grains.get']('vCROCS_Drive_L_Size')[0] }}
    - vtype: REG_SZ

Reg_Setting_T_Drive:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SYSTEM\vCROCS'
    - vname: T_Drive_Size
    - vdata: {{ salt['grains.get']('vCROCS_Drive_T_Size')[0] }}
    - vtype: REG_SZ

# Windows Spooler Service
stop_service:
  service.dead:
    - name: spooler
    
disable_service:
  service.disabled:
    - name: spooler

# Install Software
install_software:
  pkg.installed:
    - pkgs:
      - firefox_x64
      - git

# Bring New Drives Online and format
onlinenewdrives:
  cmd.script:
    - name: online-new-drives
    - source: salt://scripts/windows-server-new-drives-ps.ps1
    - shell: PowerShell
