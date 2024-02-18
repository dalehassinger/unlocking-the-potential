// Orchestrator Action to list AD Sub OUs
// Created by the VMware by Broadcom Healthcare Aria Team

// Before you use this Action you MUST run the next 2 Workflows
// You MUST run the Workflow "Add an Active Directory server" to add Active Directory Server to Orchestrator
// You MUST also run the Workflow "Configure Active Directory plug-in options" and set the "Default Active Directory server"

// Set the Parent OU value (APP Name)
var parentOU = "APPS";

//Search for Parent OU Value
var parentOUPath = ActiveDirectory.search('OrganizationalUnit',parentOU);
System.log("Parent OU: " + parentOUPath);

// Create Array of Sub OUs
for each (ou in parentOUPath){
    var childOUs = ou.organizationalUnits;
    //System.log("Child OUs: " + childOUs);
}
//System.log("Child OUs Length: " + childOUs.length);


var data = new Array();
for each (var ouObject in childOUs){
    data.push(ouObject.name)
    //data.push(ouObject.distinguishedName)
    
    //System.log("Existing OU Name: " + ouObject.name);
}
System.log("Existing Sub OUs: " + data);

return data
