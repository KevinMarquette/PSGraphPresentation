graph {
    node database @{
        #src = 
        shape="none"
        label = '<table BORDER="0"><tr><td><img src="{0}"/></td></tr></table>' -f "$psscriptroot\db.png"
    }
    node pwsh @{
        label = ">_"
        color = '#123456'
        fontcolor = 'white'
        style = 'filled'
        shape = 'parallelogram'
        fontsize = '48'
        fontname = 'consolas bold'
    }
    edge database -To pwsh @{
        penwidth=34
        
    }
} | Show-PSGraph