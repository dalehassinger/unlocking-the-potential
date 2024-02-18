<#
.SYNOPSIS
  This Script is used to Create Remote Console Dashboards for Aria Operations
.DESCRIPTION
  VMRC Links
.PARAMETER
  No Parameters
.INPUTS
  No inputs
.OUTPUTS
  Email sent.
.NOTES
  Version:        1.0
  Author:         Dale Hassinger
  Creation Date:  04/20/2023
  Purpose/Change: Initial script development
  Color Scheme of html file works nice with the Dark Theme within Aria Operations

.EXAMPLE
    .\vmrc.ps1
#>



# ----- [ Define Username/Password ] -----
$vCenterName = 'vCenter.vCROCS.info'
$userName = 'administrator@vsphere.local'
$passWord = 'H@ckME!'

# ----- [ Connect to vCenter ] -----
Connect-VIServer -Server $vCenterName -User $userName -Password $passWord -Force -Protocol https

# ----- [ Get All VMs ] -----
$vmrcName = Get-VM | Sort-Object Name | Where-Object { $_.Name -notmatch '^vcls' }

# ----- [ Create Web Page ] -----
$htmlBody = '
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
* {
    box-sizing: border-box;
}

#myInput {
    background-position: 10px 10px;
    background-repeat: no-repeat;
    width: 100%;
    font-size: 75%;
    font-family: arial, sans-serif;
    padding: 12px 20px 12px 40px;
    border: 0px solid #ddd;
    margin-bottom: 12px;
    background-color: #34495E;
}

.input-text {
    color: #5DADE2;
}

#myTable {
    border-collapse: collapse;
    width: 100%;
    border: 0px solid #263238;
    font-size: 75%;
    font-family: arial, sans-serif;
}

#myTable th, #myTable td {
    text-align: left;
    padding: 12px;
}

#myTable tr {
    border-bottom: 1px solid #566573;
}

#myTable tr.header, #myTable tr:hover {
    background-color: #566573;
}

tr:nth-child(odd) {
    background-color: #263238;
}

tr:nth-child(even) {
    background-color: #263238;
}

a:link {
    text-decoration: none;
    color: #5DADE2;
}

a:visited {
    text-decoration: none;
    color: Black;
}

a:hover {
    text-decoration: underline;
    color: #5DADE2;
}

a:active {
    text-decoration: underline;
    color: #dddddd;
}

</style>
</head>
<body>
<input type="text" class="input-text" id="myInput" onkeyup="myFunction()" placeholder="Search for Server Name..." title="Type in a name">

<table id="myTable">
'

# ----- [ Loop thru all VMs and create the VMRC links ] -----
if($vmrcName.count -gt 0){
    foreach($vm in $vmrcName){
        $htmlBody += '
        <tr>
            <td><b><a href="vmrc://' + $vm.Uid.Split(":")[0].Split("@")[1] + '/?moid=' + $vm.ExtensionData.MoRef.Value + '" target="_blank">' + $vm.Name.ToUpper() + '</a></b></td>
        </tr>'
    } # End Foreach
} # End If
else{
    $htmlBody += '
    <tr>
        <td>No VMs Found!</td>
    </tr>'
} # End Else

$htmlBody += '
<tr>
    <td bgcolor="#dddddd"><b><center>VMware VMRC MUST be installed on local computer to use Remote Console. (VM Count: ' + $vmrcName.Count + ')</b></center></td>
</tr>'

$htmlBody += '
</table>
<script>
function myFunction() {
    var input, filter, table, tr, td, i, txtValue;
    input = document.getElementById("myInput");
    filter = input.value.toUpperCase();
    table = document.getElementById("myTable");
    tr = table.getElementsByTagName("tr");
    for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[0];
    if (td) {
        txtValue = td.textContent || td.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
        } else {
        tr[i].style.display = "none";
        }
    }       
    }
}
</script>
</body>
</html>
'

# ------ [ Write Web Page to Web Server default folder ] -----
$FilePath = '/var/www/html/vmrc.html'
$htmlBody | Out-File -FilePath $FilePath

# ----- [ Disconnect All vCenters ] -----
Disconnect-VIServer * -Force -Confirm:$false

