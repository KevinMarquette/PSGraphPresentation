$settingsPath = '.\.vscode\settings.json'
$startTime = [datetime]"2019/04/28 10:20:00AM"
$startTime = Get-Date

$ColorMap = @(
    @{
        Name = "Demo Prep"
        Time = $startTime.AddMinutes(-10)
        Color = "#ffff66"
    },
    @{
        Name = "Start Presentation"
        Time = $startTime
        Color = "#99ff99"
    },
    @{
        Name = "Presentation"
        Time = $startTime.AddMinutes(1)
        Color = "#91acbb"
    },
    @{
        Name = "Start Demo: Basic Features"
        Time = $startTime.AddMinutes(3)
        Color = "#6666FF"
    },
    @{
        Name = "Basic Features: Half way done"
        Time = $startTime.AddMinutes(8)
        Color = "#AAAAFF"
    },
    @{
        Name = "Basic Features: Finish"
        Time = $startTime.AddMinutes(12)
        Color = "#DDDDFF"
    },
    @{
        Name = "Other Features"
        Time = $startTime.AddMinutes(13)
        Color = "#33AAAA"
    },  
    @{
        Name = "Other Features: Finish"
        Time = $startTime.AddMinutes(13)
        Color = "#AAFFFF"
    },
    @{
        Name = "Server Infrastrucutre"
        Time = $startTime.AddMinutes(17)
        Color = "#AA66AA"
    },
    @{
        Name = "Server Infrastrucutre: Halfway"
        Time = $startTime.AddMinutes(21)
        Color = "#FF66FF"
    },
    @{
        Name = "Server Infrastrucutre: Finish"
        Time = $startTime.AddMinutes(24)
        Color = "#FFDDFF"
    },
    @{
        Name = "Org Chart"
        Time = $startTime.AddMinutes(25)
        Color = "#99FF99"
    },
    @{
        Name = "Lightning Demo"
        Time = $startTime.AddMinutes(29)
        Color = "#FFFF00"
    },
    @{
        Name = "Realworld Examples"
        Time = $startTime.AddMinutes(34)
        Color = "#FFFF99"
    },
    @{
        Name = "PSGraphPlus"
        Time = $startTime.AddMinutes(38)
        Color = "#FFAA00"
    },
    @{
        Name = 'Last Demo: AST, Wrap it up'
        Time = $startTime.AddMinutes(40)
        Color = "#FF6666"
    },
    @{
        Name = 'No more time: Show PPT end slide'
        Time = $startTime.AddMinutes(44)
        Color = "#FF0000"
    },
    @{
        Name = 'Done, back to default'
        Time = $startTime.AddMinutes(55)
        Color = "#91acbb"
    }
)
$index = 0
while($true)
{
    $settings = Get-Content $settingsPath | 
        ConvertFrom-JSON
    $color = $ColorMap[$index].Color
    Write-Host ('[{0}] {1:HH:mm:ss} {2}' -f $color, (Get-Date),   $ColorMap[$index].Name)
    $settings.'workbench.colorCustomizations'.'statusBar.background' = $color
    $settings.'workbench.colorCustomizations'.'titleBar.activeBackground' = $color
    $settings.'workbench.colorCustomizations'.'titleBar.inactiveBackground' = $color
    $settings | ConvertTo-Json | Set-Content -Path $settingsPath -Encoding utf8
    Start-Sleep -Seconds 5

    if($ColorMap[$index + 1].Time -le (Get-Date))
    {
        $index++        
        Write-Host ("  [{0}] Next Index [{1}]" -f $ColorMap[$index].Time, $index)
    }
    if($index -ge $ColorMap.Length)
    {
        break
    }
}