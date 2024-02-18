// Function to create a sub OU
function performAction(item, substring) {
    try {
        // Attempt to create the sub OU
        item.createOrganizationalUnit(substring);
        System.log("Sub OU '" + substring + "' created successfully.");
    } catch (e) {
        System.error("Error creating Sub OU '" + substring + "': " + e.message);
    }
}

// Set the Parent OU value (APP Name) Create an Action input named parentOU and type is string
var parentOU = "MGMT";
//var parentOU = "Epic";

//Search for Parent OU Value+
var ous = ActiveDirectory.search('OrganizationalUnit',parentOU);
System.log("ous: " + ous);
//System.log("ous: " + ous.length);

if(ous.length > 0){
    // Create Array of Sub OUs
    for each (ou in ous){
        var childOUs = ou.organizationalUnits;
        //System.log("Child OUs: " + childOUs);
    }

    // Build a string of Sub OU Values
    var subOUs = "";
    for each (var ouObject in childOUs){
        subOUs = subOUs + ouObject.name + ":"
        System.log("Existing OU Name: " + ouObject.name);
    }
    System.log("Existing Sub OUs: " + subOUs);


    // Define the array of sub OU Names to look for
    var subOUNames = ["Groups", "Servers", "Computers"];

    // Loop through each substring
    subOUNames.forEach(function(substring) {
        // Check if the string contains the substring
        if (subOUs.indexOf(substring) !== -1) {
            System.log("Sub OU '" + substring + "' Exists.");
        } else {
            System.log("Sub OU '" + substring + "' DOES NOT Exist! Creating..");
            // Code to create the AD Sub OUs
            //System.log("substring: " + substring)

            var ous = ActiveDirectory.searchExactMatch("OrganizationalUnit",parentOU);
            //System.log("ous: " + ous)

            // Iterate over the items using forEach
            ous.forEach(function(item) {
                performAction(item, substring);
            });
        }
    });

    System.log("All Sub OUs exist!")
    return "All Sub OUs exist!"

} else {
    System.log("OU " + parentOU + " Not Found")
    return "OU " + parentOU + " Not Found"
}
