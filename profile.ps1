Function Test-IsAdmin

{ <#

    .Synopsis
        Tests if the user is an administrator
    .Description
        Returns true if a user is an administrator, false if the user is not an administrator       
    .Example
        Test-IsAdmin
    #>
 $identity = [Security.Principal.WindowsIdentity]::GetCurrent()

 $principal = New-Object Security.Principal.WindowsPrincipal $identity

 $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

}
######----------------- Loaded at runtime ------------------#####
if(-not (Test-IsAdmin)){
    $Host.ui.RawUI.WindowTitle = "Regular PowerShell"
    $Host.UI.RawUI.ForegroundColor = "Green"
}else{
    $Host.ui.RawUI.WindowTitle = "SUPER POWERSHELL"
    $Host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.BackgroundColor = "Black"
}


Set-Location $env:USERPROFILE

#############################


######------------------- Functions -------------------######
function Sign {
    <#
    .Synopsis
        Signs powershell script with my cert   
    .Parameter scriptPath
        Path to script to sign
    .Example
        sign C:\PathTo\Script.ps1
    #>
	Param($scriptPath)
	$cert=(dir cert:currentuser\my\ -CodeSigningCert)
	$time="http://timestamp.comodoca.com/authenticode"
	Set-AuthenticodeSignature $scriptPath $cert -TimestampServer $time
}

function Get-Excuse {
    
    If ( !( Get-Variable -Scope Global -Name Excuses -ErrorAction SilentlyContinue ) ) {
        $Global:Excuses = (Invoke-WebRequest http://pages.cs.wisc.edu/~ballard/bofh/excuses).Content.Split([Environment]::NewLine)
    }
    Get-Random $Global:Excuses
}

Set-Alias ge Get-Excuse
    
function Remove-Excuses {
    Remove-Variable -Scope Global -Name Excuses
}

function Get-DNS {
    <#
    .Synopsis
        Gets the DNS entries for the specified computer from all 3 DNS servers and shows which is currently online
    .Parameter computerName
        Specifies the computer name
    .Parameter DCServers
        Specifies a list of Domain controller servers
    .Example
        Get-DNS dmnatedesk
    #>
    Param(
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$computerName,
        [Parameter(Mandatory = $true, Position = 2)]
        [string[]]$DCServers
    )
    $Results = @()
    foreach ($DC in $DCServers) {
        $result = Resolve-DnsName -Name $ComputerName -Server $DC -Type A
        $Results += $result
    }
    foreach ($Result in $Results) {
        if (Test-Connection -ComputerName $Result.IPAddress -Count 1 -Quiet) {
            write-host $Result.IPAddress -ForegroundColor Green
        }
        else {
            write-host $Result.IPAddress -ForegroundColor Red
        }
    }
}

function LL {
    <#
    .Synopsis
        Replaces the color of certain files in LL call
    .Parameter directory
        Specifies the directory currently in
    .Example
        ll
    #>
    param ($dir = ".", $all = $false) 

    $origFg = $host.ui.rawui.foregroundColor 
    if ( $all ) { $toList = ls -force $dir }
    else { $toList = ls $dir }

    foreach ($Item in $toList) { 
        Switch ($Item.Extension) { 
            ".ps1" {$host.ui.rawui.foregroundColor = "Blue"}
            ".Exe" {$host.ui.rawui.foregroundColor = "Yellow"} 
            ".msi" {$host.ui.rawui.foregroundColor = "Yellow"} 
            ".cmd" {$host.ui.rawui.foregroundColor = "Red"} 
            ".vbs" {$host.ui.rawui.foregroundColor = "Red"}
            ".bat" {$host.ui.rawui.foregroundColor = "Red"} 
            Default {$host.ui.rawui.foregroundColor = "White"} 
        } 
        if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "Green"}
        $item 
    }  
    $host.ui.rawui.foregroundColor = $origFg 
}

function lla
{
    param ( $dir=".")
    ll $dir $true
}

function la { Get-ChildItem -force }

function .. { Push-Location ..}

function ... { Push-Location ..\..}

function .... { Push-Location ..\..\..}

function ..... { Push-Location ..\..\..\..}

function ...... { Push-Location ..\..\..\..\..}

function ....... { Push-Location ..\..\..\..\..\..}

function test-dns {
    <#
    .Synopsis
        Clears the DNSCache and checks connection to new DNS-given IP address
    .Parameter computerName
        Specifies the computer name
    .Example
        Test-DNS natedesk
    #>
    param ($computer)
    Clear-DnsClientCache
    $ip = ([system.net.dns]::resolve($computer)).AddressList.IPAddressToString
    $newIP = $ip
    while($newIP -eq $ip){
        Clear-DnsClientCache
        $newIP = ([system.net.dns]::resolve($computer)).AddressList.IPAddressToString
        if(Test-Connection $computer -Count 1 -Quiet){
            $status = "Online"
        }else{
            $status = "Offline"
        }
        write-host ((get-date -Format "h:mm tt") + " - - " + $newIP + " - - " + $status)
        Start-sleep 5
    }
}

function Get-ScheduledTask {
    <#   
    .SYNOPSIS   
    Script that returns scheduled tasks on a computer
        
    .DESCRIPTION 
    This script uses the Schedule.Service COM-object to query the local or a remote computer in order to gather	a formatted list including the Author, UserId and description of the task. This information is parsed from the XML attributed to provide a more human readable format
    
    .PARAMETER Computername
    The computer that will be queried by this script, local administrative permissions are required to query this information

    .NOTES   
    Name: Get-ScheduledTask.ps1
    Author: Jaap Brasser
    DateCreated: 2012-05-23
    DateUpdated: 2015-08-17
    # Site: http://www.jaapbrasser.com
    Version: 1.3.2

    .LINK
    # http://www.jaapbrasser.com

    .EXAMPLE
        .\Get-ScheduledTask.ps1 -ComputerName server01

    Description
    -----------
    This command query mycomputer1 and display a formatted list of all scheduled tasks on that computer

    .EXAMPLE
        .\Get-ScheduledTask.ps1

    Description
    -----------
    This command query localhost and display a formatted list of all scheduled tasks on the local computer

    .EXAMPLE
        .\Get-ScheduledTask.ps1 -ComputerName server01 | Select-Object -Property Name,Trigger

    Description
    -----------
    This command query server01 for scheduled tasks and display only the TaskName and the assigned trigger(s)

    .EXAMPLE
        .\Get-ScheduledTask.ps1 | Where-Object {$_.Name -eq 'TaskName') | Select-Object -ExpandProperty Trigger

    Description
    -----------
    This command queries the local system for a scheduled task named 'TaskName' and display the expanded view of the assisgned trigger(s)

    .EXAMPLE
        Get-Content C:\Servers.txt | ForEach-Object { .\Get-ScheduledTask.ps1 -ComputerName $_ }

    Description
    -----------
    Reads the contents of C:\Servers.txt and pipes the output to Get-ScheduledTask.ps1 and outputs the results to the console


    #>
    param(
        [string]$ComputerName = $env:COMPUTERNAME,
        [switch]$RootFolder
    )

    #region Functions
    function Get-AllTaskSubFolders {
        [cmdletbinding()]
        param (
            # Set to use $Schedule as default parameter so it automatically list all files
            # For current schedule object if it exists.
            $FolderRef = $Schedule.getfolder("\")
        )
        if ($FolderRef.Path -eq '\') {
            $FolderRef
        }
        if (-not $RootFolder) {
            $ArrFolders = @()
            if (($Folders = $folderRef.getfolders(1))) {
                $Folders | ForEach-Object {
                    $ArrFolders += $_
                    if ($_.getfolders(1)) {
                        Get-AllTaskSubFolders -FolderRef $_
                    }
                }
            }
            $ArrFolders
        }
    }

    function Get-TaskTrigger {
        [cmdletbinding()]
        param (
            $Task
        )
        $Triggers = ([xml]$Task.xml).task.Triggers
        if ($Triggers) {
            $Triggers | Get-Member -MemberType Property | ForEach-Object {
                $Triggers.($_.Name)
            }
        }
    }
    #endregion Functions


    try {
        $Schedule = New-Object -ComObject 'Schedule.Service'
    }
    catch {
        Write-Warning "Schedule.Service COM Object not found, this script requires this object"
        return
    }

    $Schedule.connect($ComputerName) 
    $AllFolders = Get-AllTaskSubFolders

    foreach ($Folder in $AllFolders) {
        if (($Tasks = $Folder.GetTasks(1))) {
            $Tasks | Foreach-Object {
                New-Object -TypeName PSCustomObject -Property @{
                    'Name'               = $_.name
                    'Path'               = $_.path
                    'State'              = switch ($_.State) {
                        0 {'Unknown'}
                        1 {'Disabled'}
                        2 {'Queued'}
                        3 {'Ready'}
                        4 {'Running'}
                        Default {'Unknown'}
                    }
                    'Enabled'            = $_.enabled
                    'LastRunTime'        = $_.lastruntime
                    'LastTaskResult'     = $_.lasttaskresult
                    'NumberOfMissedRuns' = $_.numberofmissedruns
                    'NextRunTime'        = $_.nextruntime
                    'Author'             = ([xml]$_.xml).Task.RegistrationInfo.Author
                    'UserId'             = ([xml]$_.xml).Task.Principals.Principal.UserID
                    'Description'        = ([xml]$_.xml).Task.RegistrationInfo.Description
                    'Trigger'            = Get-TaskTrigger -Task $_
                    'ComputerName'       = $Schedule.TargetServer
                }
            }
        }
    }

}

function Get-AllLogons {
    param(
        [Parameter(Mandatory = $true)]
        [String]$computerName,
        [Parameter(Mandatory = $false)]
        $days = 15
    )
    $endDate = Get-Date
    $startDate = ($endDate).AddDays( - $days)
    get-winevent -computer $computerName -FilterHashtable @{logname = 'security'; id = 4624} | Select-Object @{N = 'User'; E = {$_.Properties[5].Value}}, @{N = 'Logon Type'; E = {$_.Properties[8].Value}}, TimeCreated
}

function Shrug {
    #'¯\_(ツ)_/¯' | Set-Clipboard
    -join [char[]](175, 92, 95, 40, 12484, 41, 95, 47, 175) | Set-Clipboard
}

function Throw-Table {
    #'(╯°□°）╯︵ ┻━┻' | Set-Clipboard
    (40, 9583, 176, 9633, 176, 65289, 9583, 65077, 32, 9531, 9473, 9531 | ForEach-Object {[char]$_}) -join "" | Set-Clipboard
}

function Stop-VMWare{
    if(-not (Test-IsAdmin)){
        write-host "You must run this as admin" -ForegroundColor 'Yellow'
    }else{
        get-service -DisplayName VMware* | Stop-Service
        get-process vmware-tray | Stop-Process
    }
}

function Start-VMware{
    if(-not (Test-IsAdmin)){
        write-host "You must run this as admin" -ForegroundColor 'Yellow'
    }else{
        get-service -DisplayName VMware* | Start-Service
    }
    
}

function python {
    $Host.UI.RawUI.BackgroundColor = "DarkGreen"
    $Host.UI.RawUI.ForegroundColor = "White"
    $Host.ui.RawUI.WindowTitle = "PYTHON"
    Clear-Host
    &python.exe
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "Green"
    $Host.ui.RawUI.WindowTitle = "Regular Powershell"
    Clear-Host
}

function Get-CompleteHistory {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 1)]
        [string]$strSearch # String to search
    )
    if ($strSearch) {
        $lines = Get-Content $env:APPDATA\Microsoft\Windows\Powershell\PSReadline\ConsoleHost_history.txt | Select-String "$strSearch" -Context 1, 1 
        $count = $lines.Count
        foreach ($line in $lines) {
            Write-Host $line.context.precontext[0]
            Write-Host $line.line -ForegroundColor Yellow
            write-host $line.context.postcontext[0] + "`r`n"
        }
    }
    else {
        Get-Content $env:APPDATA\Microsoft\Windows\Powershell\PSReadline\ConsoleHost_history.txt
    }
}
