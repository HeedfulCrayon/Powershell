# Useful helpdesk functions
## Chatlog monitor
##### Background job that starts another job and monitors it.  If the child job ever stops running, it removes it and creates a new identical job
## Get-GPOInfo
##### Queries AD and Group Policy for information about whether the GPO is enabled, enforced, and where it is linked.  It also returns the affected groups, the members of those groups and the total count of affected members. All of this is compiled into a csv file.
## Get-RemoteForestMembers
##### Queries AD to find all the LocalDomain members that are members of a remote forest. Results our output to an excel file.
