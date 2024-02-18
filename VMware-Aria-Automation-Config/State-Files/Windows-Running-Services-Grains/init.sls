grains-data:
  cmd.script:
    - name: grains-running-services
    - source: salt://scripts/windows-running-services.ps1
    - shell: PowerShell