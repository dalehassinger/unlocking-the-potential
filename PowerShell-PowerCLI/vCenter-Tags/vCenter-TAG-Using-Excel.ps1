# Create Date: 09/06/2024
#  Created By: Dale Hassinger
# Description: Add/Remove TAGs to/from a VMware vCenter
#              Pull data from a Excel Spreadsheet using the PowerShellModule importExcel
#              Demo Only. Please Test in a Lab Area.





# ----- [ Add TAGs/Categories ] -----

# Import the ImportExcel module
Import-Module ImportExcel

Try {
    # Define the connection settings as a hash table
    $esxHostSettings = @{
        Server = "192.168.6.100"
        Username = "administrator@vcrocs.local"
        Password = "VMware1!"
    }

    # Connect to the ESX host using the specified credentials (splatting!)
    Connect-VIServer @esxHostSettings -Force

    #Get-VM | Sort-Object Name

    # Define the path to the Excel file
    $excelFilePath = "/Users/hdale/github/PS-TAM-Lab/Northwell-Tags.xlsx"
    $sheetName = "TAGs-ADD"

    # Import data from the first sheet of the Excel file
    $data = Import-Excel -Path $excelFilePath -WorksheetName $sheetName

    # Display the pulled data
    #$data
    #$data.Count

    foreach($tag in $data){

        # Define the Tag Category and Tag Names
        $categoryName        = $tag.Category
        $categoryDescription = $tag.CategoryDescription
        $tagName             = $tag.Tag
        $tagDescription      = $tag.TagDescription

        # Check if the Tag Category already exists
        $category = Get-TagCategory -Name $categoryName -ErrorAction SilentlyContinue
        if (-not $category) {
            # Create the Tag Category
            $category = New-TagCategory -Name $categoryName -Cardinality Multiple -EntityType "VirtualMachine" -Description $categoryDescription
            Write-Host "Tag Category '$categoryName' created successfully."
        } else {
            Write-Host "Tag Category '$categoryName' already exists."
        }

        # Check if the Tag already exists
        $tag = Get-Tag -Name $tagName -ErrorAction SilentlyContinue
        if (-not $tag) {
            # Create the Tag
            $tag = New-Tag -Name $tagName -Category $category -Description $tagDescription
            Write-Host "Tag '$tagName' created successfully in category '$categoryName'."
        } else {
            Write-Host "Tag '$tagName' already exists in category '$categoryName'."
        }

    } # End foreach

    # Disconnect from vCenter
    Disconnect-VIServer -Server * -Confirm:$false

} Catch {
    Write-Error "An error occurred: $_"
} # End Catch







# ----- [ Delete TAG ] -----

# --- Delete a single TAG
Try {
    # Define the connection settings as a hash table
    $esxHostSettings = @{
        Server = "192.168.6.100"
        Username = "administrator@vcrocs.local"
        Password = "VMware1!"
    }

    # Connect to the ESX host using the specified credentials (splatting!)
    Connect-VIServer @esxHostSettings -Force

    # Specify the tag you want to delete
    $tagName = "DB-Server"
    $tag = Get-Tag -Name $tagName -ErrorAction SilentlyContinue
    Write-Host "Deleting tag: $tagName"

    # Remove the tag
    Remove-Tag -Tag $tag -Confirm:$false -ErrorAction SilentlyContinue

    # Disconnect from vCenter
    Disconnect-VIServer -Server * -Confirm:$false

} Catch {
    Write-Error "An error occurred: $_"
} # End Catch




# --- Delete multiple TAGs in an Excel Spreadsheet

# Define the path to the Excel file
$excelFilePath = "/Users/hdale/github/PS-TAM-Lab/Northwell-Tags.xlsx"
$sheetName = "TAGs-Delete"

# Import data from the first sheet of the Excel file
$data = Import-Excel -Path $excelFilePath -WorksheetName $sheetName

# Display the pulled data
#$data
#$data.Count

Try {
    # Define the connection settings as a hash table
    $esxHostSettings = @{
        Server = "192.168.6.100"
        Username = "administrator@vcrocs.local"
        Password = "VMware1!"
    }

    # Connect to the ESX host using the specified credentials (splatting!)
    Connect-VIServer @esxHostSettings -Force

    # Loop through the tags in excel and remove them
    foreach ($tagName in $data.Tag) {
    
        $tag = Get-Tag -Name $tagName -ErrorAction SilentlyContinue
        
        if ($tag) {
            Remove-Tag -Tag $tag -Confirm:$false
            Write-Host "Deleted tag: $tagName"
        } else {
            Write-Host "Tag not found: $tagName"
        } # End else

    } # End foreach

    # Disconnect from vCenter
    Disconnect-VIServer -Server * -Confirm:$false

} Catch {
    Write-Error "An error occurred: $_"
} # End Catch





# ----- [ Show TAGs ] -----
# Get and display all tags
Try {
    # Define the connection settings as a hash table
    $esxHostSettings = @{
        Server = "192.168.6.100"
        Username = "administrator@vcrocs.local"
        Password = "VMware1!"
    }

    # Connect to the ESX host using the specified credentials (splatting!)
    Connect-VIServer @esxHostSettings -Force

    $allTags = Get-Tag
    $allTags
    
    #$allTags.Name
    #$allTags.Count
    
    # Disconnect from vCenter
    Disconnect-VIServer -Server * -Confirm:$false

} Catch {
    Write-Error "An error occurred: $_"
} # End Catch











# ----- [ Add Existing TAGs to an Excel Worksheet ] -----

# Import the ImportExcel module
Import-Module ImportExcel

# Define the path to the Excel workbook and the worksheet name
$excelFilePath = "/Users/hdale/github/PS-TAM-Lab/Northwell-Tags.xlsx"
$sheetName = "TAGs-Current"

# Clear the worksheet if it already exists
Export-Excel -Path $excelFilePath -WorksheetName $sheetName -ClearSheet

Try {
    # Define the connection settings as a hash table
    $esxHostSettings = @{
        Server = "192.168.6.100"
        Username = "administrator@vcrocs.local"
        Password = "VMware1!"
    }

    # Connect to the ESX host using the specified credentials (splatting!)
    Connect-VIServer @esxHostSettings -Force

    # Get all tags from vCenter
    $data = Get-Tag
    #$data
    
    # Loop through the tags and add them to the Excel worksheet
    foreach ($tagCurrent in $data) {
    
        # Define the new data (this can be any object or data structure, like an array, hashtable, etc.)
        $newData = @(
        [PSCustomObject]@{Category=$tagCurrent.Category; Tag=$tagCurrent.Name; TagDescription=$tagCurrent.Description}
        )
    
        # Append the data to the specified sheet in the Excel file
        $newData | Export-Excel -Path $excelFilePath -WorksheetName $sheetName -Append
    
    } # End foreach

    # Disconnect from vCenter
    Disconnect-VIServer -Server * -Confirm:$false

} Catch {
    Write-Error "An error occurred: $_"
} # End Catch


