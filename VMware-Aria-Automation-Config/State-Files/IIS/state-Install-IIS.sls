# Installs the IIS Web Server Role (Web-Server)
IIS-WebServerRole:
  win_servermanager.installed:
    - recurse: True
    - name: Web-Server