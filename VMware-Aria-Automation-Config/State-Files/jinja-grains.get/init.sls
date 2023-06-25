# jinja code to get values from grains

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
