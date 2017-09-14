function Start-PhoneLog {
    Start-Job -Name "CallLogParent" -ScriptBlock {
        $status = $false
        while ($true) {
            if ($status -eq $false) {
                write-output "starting job"
                $callLog = Start-Job -Name "CallLog" -ScriptBlock {
                    Import-Module BurntToast
                    function Set-WindowStyle {
                        param(
                            [Parameter()]
                            [ValidateSet(
                                'FORCEMINIMIZE',
                                'HIDE', 
                                'MAXIMIZE', 
                                'MINIMIZE', 
                                'RESTORE',
                                'SHOW', 
                                'SHOWDEFAULT', 
                                'SHOWMAXIMIZED', 
                                'SHOWMINIMIZED', 
                                'SHOWMINNOACTIVE', 
                                'SHOWNA', 
                                'SHOWNOACTIVATE', 
                                'SHOWNORMAL')]
                            $Style = 'SHOW',
                            [Parameter()]
                            $MainWindowHandle = (Get-Process -Id $pid).MainWindowHandle
                        )
                        $WindowStates = @{
                            FORCEMINIMIZE   = 11; 
                            HIDE            = 0
                            MAXIMIZE        = 3; 
                            MINIMIZE        = 6
                            RESTORE         = 9; 
                            SHOW            = 5
                            SHOWDEFAULT     = 10; 
                            SHOWMAXIMIZED   = 3
                            SHOWMINIMIZED   = 2; 
                            SHOWMINNOACTIVE = 7
                            SHOWNA          = 8; 
                            SHOWNOACTIVATE  = 4
                            SHOWNORMAL      = 1
                        }
                        Write-Verbose ("Set Window Style {1} on handle {0}" -f $MainWindowHandle, $($WindowStates[$style]))

                        $Win32ShowWindowAsync = Add-Type -memberDefinition @'
[DllImport("user32.dll")] 
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
'@ -name "Win32ShowWindowAsync" -namespace Win32Functions -passThru

                        $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
                    }

                    $logfile = "$env:USERPROFILE\AppData\Local\Cisco\Unified Communications\Jabber\CSF\Logs\csf-unified.log"
                    $phoneRegex = '(?<=Number:\s)(\d+)'
                    $dateRegex = '(19[0-9]{2}|2[0-9]{3})-(0[1-9]|1[012])-([123]0|[012][1-9]|31) ([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])'
                    $logLocation = "$env:USERPROFILE\Documents\PhoneCallLogs\"
                    Get-Content $logfile -wait |
                        Where-object {
                        $_ -match "CALL_EVENT: evCallStarted" -and 
                        $_ -match "Connected" -and 
                        $_ -match "CC_CALL_TYPE_INCOMING" 
                    } | 
                        foreach-object { 
                        $currentDate = (Get-Date).AddSeconds(-7)
                        $phone = [regex]::match( $_, $phoneRegex ).Groups[0].Value
                        $user = ""
                        if ($phone.Length -eq 4) {
                            $phoneW = "*$phone"
                        }
                        else {
                            $phoneW = $phone
                        }
                        $user = Get-ADUser -filter { telephoneNumber -like $phoneW } -Properties *
                        $userName = $user.Name
                        $locked = $user.LockedOut
                        [datetime]$date = [regex]::match( $_, $dateRegex ).Groups[0].Value
                        $dateStr = $date.ToString("yyyy_MM_dd")
                        $msg = @"
$date - $username $phone
Locked Out: $locked
"@
                        if ( [datetime]$date -gt [datetime]$currentDate ) {
                            Add-Content -Value $msg -Path "$logLocation\$dateStr-$userName-$phone.txt"
                            $file = "$logLocation\$dateStr-$userName-$phone.txt"
                            # Notification
                            $lockedStatus = "Unlocked"
                            if ($locked) {
                                $lockedStatus = "Locked Out"
                            }
                            $Text1 = New-BTText -Content "$userName"
                            $Text2 = New-BTText -Content "$phone  $lockedStatus"
                            $Binding1 = New-BTBinding -Children $Text1, $Text2
                            $Visual1 = New-BTVisual -BindingGeneric $Binding1
                            $Content1 = New-BTContent -Visual $Visual1 -Launch $file -ActivationType Protocol
                            Submit-BTNotification -Content $Content1
                            # End Notification
                            # $notepad = Start-Process notepad.exe -ArgumentList $file -PassThru
                            # start-sleep -Milliseconds 100
                            # Set-WindowStyle MINIMIZE $notepad.MainWindowHandle
                            # Start-Sleep -Milliseconds 100
                            # Set-WindowStyle SHOWNORMAL $notepad.MainWindowHandle
                        }
                    }
                }  
            }
            Start-Sleep 3
            $status = $callLog.State
            if ($status -ne 'Running') {
                write-host "Job not running"
                $status = $false
                Stop-Job -ID $callLog.id
                Remove-Job -ID $callLog.id
            }
        }
    
    }
    $Host.UI.RawUI.BackgroundColor = "DarkRed"
    Clear-Host
    $Host.UI.RawUI.ForegroundColor = "Yellow"
    write-host "CLOSING ME WILL STOP YOUR PHONE LOG"
    $Host.ui.RawUI.WindowTitle = "DO NOT CLOSE - PHONE LOG"
}
