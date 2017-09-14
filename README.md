# HeedfulCrayon's Powershell Repository
Most of this stuff is just things that I use personally. Feel free to use it if you would like.
## Useful helpdesk functions
### [Cisco Jabber Phone Log](https://github.com/HeedfulCrayon/Powershell/blob/master/Helpdesk/Chatlog.ps1)
Background job that starts another job and monitors it.  If the child job ever stops running, it removes it and creates a new identical job
### [Get-GPOInfo](https://github.com/HeedfulCrayon/Powershell/blob/master/Helpdesk/Domain/Get-GPOInfo.ps1)
Queries AD and Group Policy for information about whether the GPO is enabled, enforced, and where it is linked.  It also returns the affected groups, the members of those groups and the total count of affected members. All of this is compiled into a csv file.
### [Get-RemoteForestMembers](https://github.com/HeedfulCrayon/Powershell/blob/master/Helpdesk/Domain/Get-RemoteForestMembers.ps1)
Queries AD to find all the LocalDomain members that are members of a remote forest. Results our output to an excel file.
