﻿#this module brings the functionality to read the chinese data out of the binary log files

function Get-Bots {
    param([string]$path)

    $dropLogs = Get-ChildItem -path $path -Filter "入庫記錄.txt" -Recurse | Select-Object Length, PsPath
    if ($null -eq $dropLogs) { 
        Write-Warning "no droplogs found in $path -> terminating"
        exit  
    }

    $bots = @()
    foreach ($logFile in $dropLogs) {
        if ($($logFile.PSPath.split('\')[-2]) -match '@') {
            $name = $logFile.PSPath.split('\')[-2]
            $bots += [PSCustomObject]@{
                Name      = $name
                Path      = $logFile.PSPath
                Length    = $logFile.length
                ItemCount = (Get-ItemCount -Path $logFile.PSPath)
            }
        }
        Write-Host "Monitoring $name"
    }
    return $bots
}

function Get-ItemCount {
    param([string]$path)
    if ([System.Version]$PSVersionTable.PSVersion -lt [System.Version]"6.0.0") {
        $b = get-Content -path $path -Encoding Byte -Raw
    } else {
        $b = get-Content -path $path -AsByteStream -Raw
    }

    return $b.length / 1140
}

Function Get-Item {
    param(
        [PSCustomObject]$bot,
        [int]$index
    )
    
    if ([System.Version]$PSVersionTable.PSVersion -lt [System.Version]"6.0.0") {
        $data = get-Content -path $bot.Path -Encoding Byte -Raw
    } else {
        $data = get-Content -path $bot.Path -AsByteStream -Raw
    }
    $itemByte = [System.Array]::CreateInstance([byte], 1140)

    $start = $index * 1140
    $end = $start + 1139
    
    for ($start; $start -le $end; $start++) {
        $itemByte = $itemByte + $data[$start]
    }
    $item = Get-ItemObject -item $([System.Text.Encoding]::Unicode.GetString($itemByte) )
    $item.source = $bot.Name
    return $item
}