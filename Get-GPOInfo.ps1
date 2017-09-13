<#
.SYNOPSIS
    Dumps all GPO's to a CSV file
.DESCRIPTION
    Collects GPO information and dumps it to a csv file. Information CSV file contains is:
        -GPO Name
        -GPO GUID
        -GPO Status (Enabled, Enforced and Linked Path)
        -Groups in Security Filtering
        -Users and computers contained in Groups in security filtering 
            as well as users and computers in security filtering
        -Count of users or computers affected by GPO
.NOTES
    Written by Nathan Borup
#>
Write-Progress -Activity "Getting GPO Information"
$GPOs = Get-GPO -All -Domain dmba.com 
$MappingGPO = New-Object 'System.Collections.Generic.Dictionary[[String],[String]]'
foreach ($GPO in $GPOs) {
    $MappingGPO.Add($GPO.DisplayName, $GPO.Id)
}
# GPO Information Collection
$colObjGPO = @()
# Iterate through GPO's and collect information such as:
#   If the GPO is Enabled
#   If the GPO is Enforced
#   What OU the GPO is linked to
#   Groups contained in the scope
#   Users and computers contained in the scope
#   Users and computers contained in the Groups in the scope
#   The count of users affected by the GPO
$current = 0
foreach ($item in $MappingGPO.GetEnumerator()) {
    $current++
    $count = $MappingGPO.Count
    $userCount = 0
    $guid = $item.value
    $name = $item.Key
    $permission = Get-GPPermission -Guid $guid -All | Where Permission -eq GpoApply
    [string]$group = $null
    [string]$users = $null
    foreach ($item in $permission) {
        $percentComplete = ($current / $count) * 100
        Write-Progress -Activity "Getting members of $name policy" -Status 'Progress->' -PercentComplete $percentComplete -CurrentOperation "$current of $count"
        # Get users and computers contained in the scope
        if ($item.trustee.sidType -eq "User" -or $item.Trustee.SidType -eq "Computer") {
            $users += $item.trustee.name + "|"
            # increment user and computer count
            $userCount++
        }
        else {
            # Get users and computers contained in the Groups in the scope
            $group += $item.trustee.name + ","
            if ($item.trustee.name -ne $null -and $item.trustee.name -notlike "Authenticated Users") {
                $groupUsers = Get-ADGroupMember $item.trustee.name
                foreach ($groupUser in $groupUsers) {
                    $users += $groupUser.samAccountName + "|"
                    # increment user and computer count
                    $userCount++
                }
            }
        }
    }
    # Obtain GPO information
    [xml]$GPOReport = Get-GPOReport -Guid $guid -ReportType xml 
    $enabled = ""
    $enforced = ""
    $linkedTo = ""
    foreach ($item in $GPOReport.GPO.LinksTo) {
        $linkedTo += "$($item.SOMPath)|"
        $enabled += "$($item.enabled)|"
        $enforced += "$($item.NoOverride)|"
    }
    $enabled = $enabled.Substring(0,$enabled.Length-1)
    $enforced = $enforced.Substring(0,$enforced.Length-1)
    $linkedTo = $linkedTo.Substring(0,$linkedTo.Length-1)
    # Create GPO Information Object
    $objGPO = New-Object System.Object
    $objGPO | Add-Member -Type NoteProperty -Name Name -Value $name
    $objGPO | Add-Member -Type NoteProperty -Name GUID -Value $guid
    $objGPO | Add-Member -Type NoteProperty -Name Enabled -Value $enabled
    $objGPO | Add-Member -Type NoteProperty -Name Enforced -Value $enforced
    $objGPO | Add-Member -Type NoteProperty -Name LinkedTo -Value $linkedTo
    $objGPO | Add-Member -Type NoteProperty -Name Group -Value $group
    $objGPO | Add-Member -Type NoteProperty -Name Users -Value $users
    $objGPO | Add-Member -Type NoteProperty -Name "User Count" -Value $userCount
    # Add GPO Information Object to GPO Collection
    $colObjGPO += $objGPO
}
# Export Collection to CSV file on desktop
$colObjGPO | Export-CSV $env:USERPROFILE\Desktop\GPO.csv -nti
