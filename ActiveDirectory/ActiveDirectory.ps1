#region Demo prep
$cred = Get-Credential -UserName administrator -Message DomainAdmin
$Server = "10.2.45.1"
$PSDefaultParameterValues["*-AD*:Server"] = $Server
$PSDefaultParameterValues["*-AD*:Credential"] = $cred
Start-VM Demo-DC
Test-NetConnection $Server

#endregion

$ADUsers  = Get-ADUser -Filter * -Properties memberof,department,title -SearchBase 'OU=Demo Accounts,DC=demo,DC=local'
$ADGroups = Get-ADGroup -Filter * -SearchBase 'OU=Groups,OU=Demo Accounts,DC=demo,DC=local'
$ADUsers  | ogv
$ADGroups | ogv



graph ADUsers @{rankdir='LR'} {

    Node $ADGroups -NodeScript {$_.DistinguishedName} -Attributes @{
        label={$_.Name}
        shape='box'
        style='filled'
        color='green'
    }

    Node $ADUsers -NodeScript {$_.DistinguishedName} -Attributes @{
        label={'{0}\n{1}\n{2}' -f $_.Name,$_.title,$_.department }
        shape='box'
    }    
    
    ForEach ($group in $ADGroups)
    {
        $members = Get-ADGroupMember $group | where DistinguishedName
        If($null -ne $members)
        {
            Edge -From $members.DistinguishedName -To $group.DistinguishedName
        }
    }
} | Export-PSGraph -ShowGraph
