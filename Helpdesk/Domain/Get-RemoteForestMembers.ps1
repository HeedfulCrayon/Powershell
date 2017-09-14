<#
.NOTES
    Written by Nathan Borup
#>
    if (Get-Module -ListAvailable -Name ImportExcel) {
        write-host "ImportExcel module installed. Ready for action."
    }
    else {
        Import-Module ImportExcel
    }
    $groups = Get-ADGroup -Filter { GroupScope -eq "DomainLocal"} | Select *
    $groupCount = $groups.Count
    $count = 0
    $groupObj = @()
    $groupErr = @()
    foreach ($group in $groups) {
        $name = $group.Name
        $percentComplete = ($count / $groupCount) * 100
        Write-Progress -Activity "Searching for Remote Forest Group Members" -Status 'Progress->' -PercentComplete $percentComplete -CurrentOperation "$count of $groupCount - $name"
        try {
            $members = Get-ADGroupMember $group.SID -recursive | 
                Where-Object { $_.distinguishedName -notlike "*DC=dmba*"} | Select Name
        }
        catch {
            $groupErr += $Error
            $error.Clear()
        }
        $count ++
        if ($members -ne $null) {
            foreach ($member in $members) {
                $objMember = New-Object System.Object
                $objMember | Add-Member -Type NoteProperty -Name Group -Value $name
                $objMember | Add-Member -Type NoteProperty -Name Member -Value $member.Name
                $groupObj += $objMember
            }
        }
    }
    $groupObj | Export-Excel -WorkSheetname "Remote Forest Members" -Path $env:USERPROFILE\Desktop\members.xlsx
    $groupErr | Export-Excel -WorkSheetname "failed Groups" -Path $env:USERPROFILE\Desktop\members.xlsx
