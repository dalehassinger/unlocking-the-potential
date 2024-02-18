// Orchestrator Action to return the AD OU based on a Server Name
// Created by the VMware by Broadcom Healthcare Aria Team

// Before you use this Action you MUST run the next 2 Workflows
// You MUST run the Workflow "Add an Active Directory server" to add Active Directory Server to Orchestrator
// You MUST also run the Workflow "Configure Active Directory plug-in options" and set the "Default Active Directory server"
// Make sure there is an input "ServerName" with type as string.

// The next line was used for testing. Fast way to Test. Remove the ServerName input and hard code the server name.
//var serverInfo = ActiveDirectory.getComputerAD("WIN-19-000");
var serverInfo = ActiveDirectory.getComputerAD(ServerName);

if(serverInfo !== null){
    var removeAD = serverInfo.distinguishedName.split(",")[0]

    //Logging to make sure code is working
    System.log("Server Distinguished Name: " + serverInfo.distinguishedName);
    System.log("              Server Name: " + serverInfo.name);
    System.log("                    AD CN: " + removeAD);

    // Complete AD string
    var serverOU = serverInfo.distinguishedName;

    // Define the string to remove
    const partToRemove = removeAD;

    // Remove the String and the following comma if it exists
    serverOU = serverOU.replace(partToRemove + ",", "");

    // If the string was at the end or middle without a following comma, remove it
    serverOU = serverOU.replace(partToRemove, "");

    // Logging to show the results
    System.log("                    AD OU: " + serverOU);

    return serverOU

} else {

    return "Not Found"

}

