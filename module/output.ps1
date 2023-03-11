$ignoreItems = @()

$runeList = @{
    "El" = 1; "Eld" = 2; "Tir" = 3; "Nef" = 4; "Eth" = 5; "Ith" = 6; "Tal" = 7; "Ral" = 8; "Ort" = 9; "Thul" = 10; "Amn" = 11; "Sol" = 12; "Shael" = 13; "Dol" = 14; "Hel" = 15; "Io" = 16; "Lum" = 17; "Ko" = 18; "Fal" = 19; "Lem" = 20; "Pul" = 21; "Um" = 22; "Mal" = 23; "Ist" = 24; "Gul" = 25; "Vex" = 26; "Ohm" = 27; "Lo" = 28; "Sur" = 29; "Ber" = 30; "Jah" = 31; "Cham" = 32; "Zod" = 33;
}

function Show-Discord {
    param(
        [PSCustomObject]$item,
        [string]$url
    )
    #for privacy reasons remove domain
    $item.source = $item.source.split("@")[0]
    $description = ""
    $title += "$($item.nameEN)`n"
    if ($item.mods) { 
        for ($i = 0; $i -lt $item.mods.Split("`n").Count; $i++) {
            if ($i -eq 0) {
                    $description += "`n"
            }
            $description += $item.modsEN[$i] + "`n"
        }
    }
    $description += "*$($item.source) $($item.Timestamp)*"

    #https://birdie0.github.io/discord-webhooks-guide/structure/embeds.html
    $payload = [PSCustomObject]@{
        embeds = @([PSCustomObject]@{
                color       = $item.Color
                title       = $title
                description = $description
            })
    }
    Invoke-RestMethod -Uri $url -Method Post -Body ($payload | ConvertTo-Json) -ContentType 'application/json; charset=utf-8' 
}

Function Publish-Item {
    param(
        [PSCustomObject]$item,
        [hashtable]$config
    )
    $jsonLog = $config.Get_Item("jsondump")
    $minRune = If ($RuneList.Contains($config.Get_Item("minrune"))) { $RuneList[$config.Get_Item("minrune")] } Else { 0 }

    #ignore low runes and ignorelist
    if ($ignoreItems.Contains($item.nameEN) -or 
    (
        $item.nameEN.EndsWith(" Rune") -and 
        $RuneList.Contains($item.nameEN.split(" ")[0]) -and
        $RuneList[$item.nameEN.split(" ")[0]] -lt $minRune
    )
    ) { 
        Write-Host -message "ignoring $($item.nameEN)" 
        continue
    }

    #log to json
    if ($jsonLog) {
        $item | Convertto-json | Out-File "$PSScriptRoot\..\itemdump.json" -Append
    }

    #send to console and discord
    Show-Console -item $item
    Show-Discord -item $item -url $config.Get_Item("hookurl")
}

Function Show-Console {
    param(
        [PSCustomObject]$item
    )
    Write-Host -ForegroundColor red $($item.source) $($item.timestamp | Out-String).replace("`n","").replace("`r","")
    Write-Host -ForegroundColor red ($($item.nameEN + " - " + $item.name) | Out-String).replace("`n","").replace("`r","")
    Write-Host -ForegroundColor DarkGray ($($item.modsEN) | Out-String)
}