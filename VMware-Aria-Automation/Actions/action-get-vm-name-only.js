// Orchestrator Action to return only the VM name from the VM selected in a Picker List
// Created by the VMware by Broadcom Healthcare Aria Team
// Add an VC:VirtualMachine input to the Action

if(pickerName !== null){
    
    //Display Value to Log for testing
    System.log(pickerName.name);
    
    //Return pickerName.name to custom Form
    return pickerName.name
    
} else {
    
    //Return a value before pickerName.name is Selected or you will get an error
    return "Select VM Name"
    
}
