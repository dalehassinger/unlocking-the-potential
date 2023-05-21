# Runs the script to add a selfsigned ssl to IIS
install_SSL:
  cmd.script:
    - name: ssl
    - source: salt://scripts/add-selfsigned-ssl.ps1
    - shell: PowerShell
