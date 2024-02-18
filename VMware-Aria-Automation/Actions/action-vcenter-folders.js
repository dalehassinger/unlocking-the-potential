//This action will return all vCenter VM Folders.

var vCenterFolders = new Array();

folders = VcPlugin.getAllVmFolders();

for each (folder in folders) {
    vCenterFolders.push(folder.name);
}

return vCenterFolders;