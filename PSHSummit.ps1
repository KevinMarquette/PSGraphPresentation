                                                                                 break; # F5 protection, You saw nothing
#region Intro
@{
    Topic     = 'Working with PSGraph'
    Presenter = 'Kevin Marquette'
    Title     = 'Principal DevOps Engineer'

    Email     = 'kevmar@gmail.com'
    Twitter   = '@kevinmarquette'
    Blog      = 'kevinmarquette.github.io'
    Github    = 'github.com/kevinmarquette/psgraph'

    ThisDemo  = 'https://github.com/KevinMarquette/PSGraphPresentation'
}
#endregion
#region Installing PSGraph

# Install GraphViz from the Chocolatey repo
$PackageSource = @{
    Location     = 'http://chocolatey.org/api/v2/'
    Name         = 'Chocolatey'
    ProviderName = 'Chocolatey'
}
Register-PackageSource @PackageSource
Find-Package graphviz | Install-Package -ForceBootstrap

# Install PSGraph from the Powershell Gallery
Find-Module PSGraph -Repository PSGallery |
    Install-Module -Force -AllowClobber -Scope CurrentUser

# Import Module
Import-Module PSGraph

Get-Command -Module PSGraph

#endregion
#region Features

# basic graph
Graph {
    node start, middle, end
    Edge start -To middle
    Edge middle -To end
} | Show-PSGraph


# Export-PSGraph
$path = ".\preview.png"
$data = Graph {
    node start, middle, end
    Edge start -To middle
    Edge middle -To end
}
$data | Export-PSGraph $path

code $path


# Edge Syntax
Graph {
    Edge -From First -To Second
    Edge Third -To Fourth
    Edge Fith,Sixth,Seventh,Eighth
} | Export-PSGraph $path


# Edge multipath
Graph {
    Edge A -To 1,2,3
    Edge 2,3 -To C,D,f
} | Export-PSGraph $path


# Edge atributes
Graph {
    Edge First -To Second @{
        color = 'Red'
        label = 'MyLabel'
    }
} | Export-PSGraph $path


# Node Syntax
Graph {
    Node First
    Node Second,Third,Fourth
} | Export-PSGraph $path


# Node Labels
Graph {
    Node First @{
        label = 'Friendly Name'
    }
    Edge First -To Second
} | Export-PSGraph $path

# Lots of attribute options
Graph {
    node pwsh @{
        shape     = 'parallelogram'
        style     = 'filled'
        color     = '#123456'
        label     = ">_"
        fontsize  = '48'
        fontname  = 'consolas bold'
        fontcolor = 'white'
    }
} | Export-PSGraph $path



# Graph Attributes
Graph @{ label = 'Label of the Graph'; rankdir = 'LR' } {
    node start, middle, end
    Edge start -To middle
    Edge middle -To end
} | Export-PSGraph $path


# graphviz attribute documentation
start 'https://graphviz.gitlab.io/_pages/doc/info/attrs.html'


# Attribute defaults
Graph @{ label = 'Attribute Defaults' } {
    Node @{shape = 'box'}
    Edge @{color = 'red'}

    Node start, middle, end
    Edge start -To middle
    Edge middle -To end
} | Export-PSGraph $path

## Other features

# Rank
Graph @{ label = 'Rank' } {
    Edge First,Second,Third
    Edge Fourth,Fith,Sixth

    #Rank Second,Fourth,Sixth

    Node Second,Fourth,Sixth @{
        color='blue'
        shape='box'
    }
} | Export-PSGraph $path


# Subgraph
Graph  {
    Edge First,Second,Third
    Edge Fourth,Fith,Sixth

    Subgraph {
        Node First,Second,Fourth
    }
} | Export-PSGraph $path


Graph {
    Subgraph Group1 @{label='Group1'} {
        Edge First,Second,Third
    }
    Subgraph Group2 {
        Edge Fourth,Fith,Sixth
    }
    Edge Group1 -To Fith
} | Export-PSGraph $path


# Records
Graph @{ label = 'Record' } {
    Record Table1 {
        'Row1'
        'Row2'
        'Row3'
    }
} | Export-PSGraph $path


# Edges from Row to Row
Graph @{ label = 'Row Edges' } {
    Record Table1 {
        Row 'Row1' -Name Row1
        Row 'Row2' -Name Row2
        Row 'Row3' -Name Row3
    }

    Record Table2 {
        Row 'Row1' -Name Row1
        Row 'Row2' -Name Row2
        Row 'Row3' -Name Row3
    }

    Edge Table1:Row1 -to Table2:Row1
    Edge Table2:Row2 -To Table1:Row3
    Rank Table1, Table2
} | Export-PSGraph $path


# Entity
$object = [PSCustomObject]@{
    First = 'Kevin'
    Last = 'Marquette'
    Age = 37
}

Graph @{ label = 'Entity' } {
    Entity $object
} | Export-PSGraph $path


# Alternate View
Graph @{ label = 'Entity View' }{
    Entity $object -Name 'Person' -Show Value
} | Export-PSGraph $path



#endregion
#region Example Diagrams

# Server infrastructure
graph {
    # External/DMZ
    node loadbalancer @{shape='house'}
    node Web @{shape='rect'}

    # Internal
    node Api
    node DB @{shape='octagon'}

    # Connections
    edge loadbalancer -To Web
    edge Web -To Api
    edge Api -To DB

}  | Export-PSGraph $path



# Using arrays for node/edge
graph {
    # External/DMZ
    node loadbalancer @{shape='house'}
    node Web1,Web2 @{shape='rect'}
    rank Web1,Web2

    # Internal
    node Api1,Api2,Api3
    rank Api1,Api2,Api3
    node DB1 @{shape='octagon'}
    rank DB1

    # Connections
    edge loadbalancer -To Web1,Web2
    edge Web1,Web2 -To Api1,Api2,Api3
    edge Api1,Api2,Api3 -To DB1
}  | Export-PSGraph $path



# Using variables
$webServers = 'Web1','Web2','Web3'
$apiServers = 'Api1','Api2','Api3','Api4'
$databaseServers = 'DB1','DB2'

graph {
    # External/DMZ
    node loadbalancer @{shape='house'}
    node $webServers @{shape='rect'}
    rank $webServers

    # Internal
    node $apiServers
    rank $apiServers
    node $databaseServers @{shape='octagon'}
    rank $databaseServers

    # Connections
    edge loadbalancer -To $webServers
    edge $webServers  -To $apiServers
    edge $apiServers  -To $databaseServers
} | Export-PSGraph $path



# From datasource
$servers = Import-Csv .\large.csv
$servers | Format-Table -Auto

$webServers = $servers.Where({ $_.Role -eq 'Web'}).ComputerName
$apiServers = $servers.Where({ $_.Role -eq 'Api'}).ComputerName
$databaseServers = $servers.Where({ $_.Role -eq 'DB'}).ComputerName

graph {
    # External/DMZ
    node loadbalancer @{shape='house'}
    node $webServers @{shape='rect'}
    rank $webServers

    # Internal
    node $apiServers
    rank $apiServers
    node $databaseServers @{shape='octagon'}
    rank $databaseServers

    # Connections
    edge loadbalancer -To $webServers
    edge $webServers  -To $apiServers
    edge $apiServers  -To $databaseServers

    <# IP Addresses #>
    $servers | ForEach-Object {
        Node -Name $_.ComputerName @{ 
            label = '{0}\n{1}' -f $_.ComputerName, $_.IP 
        }
    }#>
} | Export-PSGraph $path



# Add process time checks
function Test-ServerConnection
{
    param($InputObject)
    if ((Get-Random -Minimum 0 -Maximum 100) -gt 20)
    {
        $true
    }
    else
    {
        $false
    }
}

graph {
    # External/DMZ
    node loadbalancer @{shape='house'}
    node $webServers @{shape='rect'}
    rank $webServers

    # Internal
    node $apiServers
    rank $apiServers
    node $databaseServers @{shape='octagon'}
    rank $databaseServers

    # Connections
    edge loadbalancer -To $webServers
    edge $webServers  -To $apiServers
    edge $apiServers  -To $databaseServers

    foreach ( $server in $servers) {
        if(Test-ServerConnection $server.ComputerName){
            $color = 'green'
        } else {
            $color = 'red'
        }
        Node -Name $server.ComputerName @{
            label = '{0}\n{1}' -f 
                $server.ComputerName, 
                $server.IP
            color = $color
            style = 'filled'
        }
    }
} | Export-PSGraph $path


#endregion

#region dynamic data

# OrgChart
#  Enumerating objects
$people = Import-Csv .\orgChart.csv
$people | Format-Table -AutoSize

graph orgChart @{label = 'Basic org chart'} {
    Node @{shape='rect'}

    $people | ForEach-Object {
        Node -Name $_.ID @{ 
            label = "{0}\n{1}" -f $_.Name, $_.Title 
        }
    }

    $people | Where Manager | ForEach-Object {
        Edge -From $_.Manager -To $_.ID
    }
} | Export-PSGraph $path


# Inline Object Enumeration
$people = Import-Csv .\orgChart.csv

graph orgChart {
    Node @{shape='rect'}

    Node $people -NodeScript {$_.ID} @{ 
        label = {"{0}\n{1}" -f $_.Name, $_.Title} 
    }

    $hasManager = $people | Where Manager
    Edge -Node $hasManager -FromScript {$_.Manager} -ToScript {$_.ID}

} | Export-PSGraph $path



#endregion
#region Lightning demos

# Parent and Child processes
$process = Get-CimInstance -ClassName CIM_Process
$process | Ft ProcessName, ProcessID, ParentProcessID

graph processes @{rankdir='LR'} {
    node @{shape='box'}
    node $process -NodeScript {$_.ProcessId} -Attributes @{
        label={$_.ProcessName}
    }
    edge $process -FromScript {$_.ParentProcessId} -ToScript {$_.ProcessId}
} | Show-PSGraph


# Network Connections
$netstat = Get-NetTCPConnection -State Established,TimeWait

graph network @{rankdir='LR'}  {
    Node @{shape='rect'}

    $EdgeParam = @{
        Node       = $netstat
        FromScript = {$_.LocalAddress}
        ToScript   = {$_.RemoteAddress}
        Attributes = @{
            label={'{0}:{1}' -f $_.LocalPort,$_.RemotePort}
        }
    }
    Edge @EdgeParam
} | Show-PSGraph



# Process Connections
$netstat = Get-NetTCPConnection | 
    where LocalAddress -EQ '192.168.86.90'
$process = Get-Process | 
    where id -in $netstat.OwningProcess

graph network @{rankdir='LR'} {
    node @{shape='rect'}
    node $process -NodeScript {$_.ID} @{
        label={$_.ProcessName}
    }

    $netParam = @{
        Node = $netstat
        FromScript = {$_.OwningProcess}
        ToScript   = {$_.RemoteAddress}
        Attributes = @{
            label={'{0}:{1}' -f $_.LocalPort,$_.RemotePort}
        }
    }
    edge @netParam
} | Show-PSGraph


# Production examples
start .\examples\dependency.png
start .\examples\firewall.png
start .\examples\f5.png
start .\examples\trace.png
start .\examples\trace2.png

# Bonus Content
# PSGraphPlus

Get-Command -Module PSGraphPlus

Show-NetworkConnectionGraph
Show-ProcessConnectionGraph

# Git diagrams
  Show-GitGraph -ShowCommitMessage -Direction TopToBottom
  Show-GitGraph -ShowCommitMessage -Direction TopToBottom -Path ..\PSGraph
  Show-GitGraph -ShowCommitMessage -Direction TopToBottom -Path ..\PowerShell
  Show-GitGraph -ShowCommitMessage -Direction TopToBottom -Path ..\PowerShellGet


# Graph of command calls
  Show-AstCommandGraph -Path ..\PSGraph\output\PSGraph\PSGraph.psm1
  Show-AstCommandGraph -Path ..\PSGraph\output\PSGraph\PSGraph.psm1 -AllCalls

  # Internal Modules
  Show-AstCommandGraph -Path C:\ldx\LDXGet\Output\LDXGet\LDXGet.psm1
  Show-AstCommandGraph -Path C:\ldx\LDF5\Output\LDF5\LDF5.psm1

  # PowerShellGet
  Show-AstCommandGraph -Path $env:home\documents\powershell\modules\PowerShellGet\2.1.2\PSModule.psm1

# AST parsing
$script = {
    $ABC = Get-Stuff
    $ABC | Select-Stuff
}

    $script = {
        $test = $true
        if($test -eq $true)
        {
            Write-Verbose "Now is the time" 
        }
        else
        {
            Write-Error "Oh no, this should never happen" -ErrorAction Stop
        }
    }

    $script | Show-AstGraph

    # Show live command
    $command = Get-Command Watch-Command
    Show-AstGraph -ScriptBlock $command.ScriptBlock

    # Annotate original script
    $script | Show-AstGraph -Annotate

#endregion