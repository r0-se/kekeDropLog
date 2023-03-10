. "$PSScriptRoot\module\helper.ps1"
. "$PSScriptRoot\module\item.ps1"
. "$PSScriptRoot\module\reader.ps1"
. "$PSScriptRoot\module\output.ps1"

function Watch-Folder {
    param([hashtable]$config)
    $bots = Get-Bots -path $config.Get_Item("savepath")  
    Write-Host "Starting monitor."
    while ($true) {
        Start-Sleep 5  
        foreach ($bot in $bots) {
            $newCount = (Get-ItemCount -Path $bot.Path)
            if ($newCount -gt $($bot.ItemCount)) {      
                foreach ($item in (Get-Items -bot $bot -newCount $newCount)){
                    Publish-Item -item $item -config $config
                }
                $bot.ItemCount = $newCount
            }
        }
    }
}

Set-Globals
Watch-Folder -config $(Get-Config)