﻿Get-Content "$PSScriptRoot\config.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$Path = $h.Get_Item("savepath")
$hookurl = $h.Get_Item("hookurl")

$IgnoreItems = @()
$magic_exceptions= @('銳利之斧')

$dict_source = "https://gist.githubusercontent.com/r0-se/4f72452ac805fde9ff018df81867b49d/raw"
$dict_file = "twdict.txt"

$RuneList=@{
    "El" = 1;"Eld" = 2;"Tir" = 3;"Nef" = 4;"Eth" = 5;"Ith" = 6;"Tal" = 7;"Ral" = 8;"Ort" = 9; "Thul" = 10;"Amn" = 11;"Sol" = 12;"Shael" = 13;"Dol" = 14;"Hel" = 15;"Io" = 16; "Lum" = 17;"Ko" = 18;"Fal" = 19;"Lem" = 20;"Pul" = 21;"Um" = 22;"Mal" = 23;"Ist" = 24;"Gul" = 25;"Vex" = 26;"Ohm" = 27;"Lo" = 28; "Sur" = 29;"Ber" = 30;"Jah" = 31;"Cham" = 32;"Zod" = 33;
}

$DiscColor=@{
    "white" = 16777215;
    "gold" = 13351039; 
    "green" = 65280;
    "yellow" = 15658613;
    "blue" = 8421619;
    "orange" = 15628803;
    "grey" = 5592405;
}
function Get-rare-item {
    param([string]$name)
    $splitted = $name.split(" ")

    if($splitted.Count -eq 2) {
        if ($prefix_rare.cn.Contains($splitted[0]) -and $suffix_rare.cn.Contains($splitted[1])) {
            return ($prefix_rare | Where-Object CN -eq $splitted[0]).en + " " + ($suffix_rare | Where-Object CN -eq $splitted[1]).en
        }
    }
    return $false
}

function Get-magic-item {
    param([string]$name)
    $splitted = $name.split(" ")
    
    if($splitted.Count -eq 1) {
        #stupid workaround for itemnames which match <prefix><type> but are actually white
        if($magic_exceptions.Contains($name)){
            break
        }

        #this is for names in the form "<prefix><type>" - NOT separated by a space
        #example 魚叉手之超大型護身符 harpoonists(魚叉手之) grand charm(超大型護身符)
        foreach($prefix in $prefix_magic){
            if ($name.StartsWith($prefix.cn)) {
                $splitted = $name.insert($prefix.cn.length, ' ').split(" ")
                break
            }
        }

        #example 小護身符幸運 small charm (小護身符) of luck(幸運)
        foreach($suffix in $suffix_magic){
            if ($name.EndsWith($suffix.cn)) {
                #also turns around the order so this is processed by the translation later
                $splitted = ($suffix.cn, $name.Substring(0,$name.length-$suffix.cn.length))
                break
            }
        }
    }

    if($splitted.Count -eq 2) {
        #this is for names in the form "<prefix> <type>" - separated by a space
        if ($prefix_magic.cn.Contains($splitted[0])) {
            $type = Get-Name-Translation -original $splitted[1]
            $current_prefix = ($prefix_magic | Where-Object cn -eq $splitted[0] | Select-Object -Last 1).en
            return "$current_prefix $type"
        }

        #this is for names in the form "<suffix> <type>" - separated by a space -> not sure if that even happens naturally anymore
        if ($suffix_magic.cn.Contains($splitted[0])) {
            $type = Get-Name-Translation -original $splitted[1]
            $current_suffix = ($suffix_magic | Where-Object cn -eq $splitted[0]| Select-Object -Last 1).en 
            return "$type $current_suffix"
        }
    }

    #this is for names in the form "<suffix> <suffix> <type>" - separated by a space; this is weird yo
    #example 火光之 品質的 超大型護身符 sparking(火光之) of quality(品質的) grand charm(超大型護身符)
    if($splitted.Count -eq 3) {
        if ($prefix_magic.cn.Contains($splitted[0]) -and $suffix_magic.cn.Contains($splitted[1])) {
            $type = Get-Name-Translation -original $splitted[2]
            $current_prefix = ($prefix_magic | Where-Object cn -eq $splitted[0] | Select-Object -Last 1).en
            $current_suffix = ($suffix_magic | Where-Object cn -eq $splitted[1] | Select-Object -Last 1).en 
            return "$current_prefix $type $current_suffix"
        }
    }   
    return $false
}
function Get-Mod-Translation {
    param([string]$original)

    if (-not (test-chinese-chars -string $original)){
        return $original
    }

    #this is supposed to insert skill and class names or weapon speeds
    foreach ($s in $staticmaps) {
        if ($original.Contains($s.cn)) {
            $pre = Get-Name-Translation -original $original.Substring(0, $original.IndexOf($s.cn)).Trim()
            $post = Get-Name-Translation -original $original.Substring($original.IndexOf($s.cn)+($s.cn.length)).Trim()
            return Get-Mod-Translation -original "$pre $($s.en) $post".Trim()
        }
    }

    foreach ($s in $regexmaps) {
        if ($original -match $s.cn) {
            $result = $s.en
            for($i=1;$i -lt $Matches.count;$i++) {
                $result = $result -replace "\{$($i-1)\}", $Matches[$i]
            }
            return $result
        }
    }
    return "not in dict: $original"
}

function Get-Name-Translation {
    param([string]$original)
    if ($original -eq '') {
        return ''
    }
    foreach ($s in $staticmaps) {
        if ($original.Contains($s.cn)) {
            $pre = Get-Name-Translation -original $original.Substring(0, $original.IndexOf($s.cn)).Trim()
            $post = Get-Name-Translation -original $original.Substring($original.IndexOf($s.cn)+($s.cn.length)).Trim()
            return "$pre $($s.en) $post".Trim()
        }
    }
    $out = $tw_dict |  Where-Object { $_."tw-old" -eq $original } | Select-Object -Last 1
    if ($out.enUS) {
        return $out.EnUS
    }

    return $original
}

function itemintoobj {
    param([string]$item)

    $returnItem = [PSCustomObject]@{
        Timestamp = ''
        Name      = ''
        NameEN    = ''
        Mods      = $null
        ModsEN    = New-Object System.Collections.ArrayList($null)
        Color     = 16711680
    }
    $item = $item -replace '\x00', ''
    
    if ($item -match '(?<first>[0-9]{4}\/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2})') {
        $returnItem.Timestamp = $matches[0]
    }

    if ($item -match '.*(?=\d{4}\/)') {
        $returnItem.Name = $matches[0]
        if($returnItem.Name.StartsWith("符文：")) {
            $returnItem.Color = $DiscColor.orange
        }
        $magic = Get-magic-item -name $returnItem.Name
        if ($magic) {
            $returnItem.Color = $DiscColor.blue
            $returnItem.NameEN = $magic
        } else {
            $returnItem.NameEN = Get-Name-Translation -original $returnItem.Name
        }
    }

    if ($item -match '(?<=\d{4}\/\d{2}\/\d{2} \d{2}:\d{2})[\s\S]*') {
        $returnItem.Mods = New-Object System.Collections.ArrayList(,$matches[0].split("`n"))
        $returnItem.Mods.Reverse()
        
        #this happens for set items and maybe uniques (e.g. Tal Rashas Education - Amulet)
        #happens also for rare.. maybe blue
        # $returnItem.Mods[0] <-- name
        # $returnItem.Mods[1] <-- type
        if ($returnItem.Name -eq $returnItem.Mods[1]+$returnItem.Mods[0]){
            $rare = Get-rare-item -name $returnItem.Mods[0]
            if ($rare) {
                $returnItem.NameEN = $rare
                $returnItem.Color = $DiscColor.yellow
            } else {
                $returnItem.Color = $DiscColor.gold
                $returnItem.NameEN = Get-Name-Translation -original $returnItem.Mods[0]
            }
            #only return the item name without type
        }
        $returnItem.Mods.RemoveAt(0)


        for($i=0;$i -lt $returnItem.mods.count;$i++){
            if($returnItem.mods[$i] -eq ""){
                #kills set summary
                $returnItem.Color = $DiscColor.green
                $returnItem.mods.RemoveRange($i,$returnItem.mods.count-$i)
                break;
            }

            #handle the first line of mods
            if($i -eq 0) {
                #non named items (white blue yellow grey) have def or damage in the first line
                if (($returnItem.mods[$i].StartsWith("雙手傷害：") -or $returnItem.mods[$i].StartsWith("防禦：") -or $returnItem.mods[$i].StartsWith("單手傷害："))){
                    if ($returnItem.color -ne $DiscColor.blue -and $returnItem.color -ne $DiscColor.blue){
                        $returnItem.Color = $DiscColor.white
                    }
                    $returnItem.ModsEN.Add((Get-Mod-Translation -original $returnItem.mods[$i]))
                } else {
                    #colored item have itemtype as first attribute -> translate as name
                    $returnItem.ModsEN.Add((Get-Name-Translation -original $returnItem.mods[$i]))
                }
                
            } else {
                #normal mod
                $returnItem.ModsEN.Add((Get-Mod-Translation -original $returnItem.mods[$i]))
            }
            
        }
        if ($returnItem.color -eq $DiscColor.white -and ($returnItem.modsEN[-1].Contains("Socketed") -or $returnItem.modsEN[-1].Contains("Ethereal"))) {
            $returnItem.color = $DiscColor.grey
        }
    }

    return $returnItem
}


function Get-Itemcount {
    param([string]$path)
    $b = get-Content -path $path -AsByteStream -Raw

    return $b.length / 1140
}

Function Get-Item {
    param([string]$path,
        $index)
    $data = get-Content -path $path -AsByteStream -Raw
    $itemByte = [System.Array]::CreateInstance([byte], 1140)

    $start = $index * 1140
    $end = $start + 1139
    write-verbose -message "$start is $end is"

    for ($start; $start -le $end; $start++) {
        #$b[$i]
        $itemByte = $itemByte + $data[$start]
    }
    $item = itemintoobj $([System.Text.Encoding]::Unicode.GetString($itemByte) )

    return $item
}


function Watch-Folder {
    param(
        [Parameter(Mandatory = $True)]
        [string]$path
    )

    $currentsize = Get-ChildItem -path $path -Filter "入庫記錄.txt" -Recurse | Select-Object Length, PsPath
    if ($null -eq $currentsize) { 
        Write-Warning "no droplogs found in $path -> terminating"
        Exit -1    
    }

    write-host "Monitoring folders"
    $mons = @()
    foreach ($c in $currentsize) {
        #had this match to ignore lvling accounts and only match mfers at one point like -match 'account1@email|account2@email.com'
        if ($($c.PSPath.split('\')[-2]) -match '@') {
            $obj = [PSCustomObject]@{
                Name      = $c.PSPath.split('\')[-2]
                Path      = $c.PSPath
                Length    = $c.length
                ItemCount = (get-itemcount -Path $c.PSPath)
            }
        
            $mons += $obj
        }
    }
    
    Write-Verbose "starting loop"

    while ($true) {
        Start-Sleep 5
      
        foreach ($o in $mons) {
            $compare = (get-itemcount -Path $o.Path)
            if ($compare -ne $($o.ItemCount)) { 
                (Get-Process -pid $PID).MainWindowHandle | out-null
                
                $AmountofNewItems = $compare - $($o.ItemCount)
                $loopervar = $($o.ItemCount)
                $o.ItemCount = (get-itemcount -Path $o.Path)
                write-verbose -message "$($o.name) has changed with $AmountofNewItems var is $loopervar and $compare"
                for ($loopervar; $loopervar -lt $compare; $loopervar++) {
                    Write-verbose -Message "lets get $($o.Path) -Index $loopervar"
                    $item = Get-Item -Path $($o.Path) -Index $loopervar
                    if ($IgnoreItems.Contains($item.nameEN) -or 
                        (
                            $item.nameEN.EndsWith(" Rune") -and 
                            $RuneList.Contains($item.nameEN.split(" ")[0]) -and
                            $RuneList[$item.nameEN.split(" ")[0]] -le 19
                        )
                    ) { 
                        write-host -message "ignoring $($item.nameEN)" 
                        continue
                    }
                    Show-Item -item $item
                    SendToWebhook -item $item -name $o.Name
                }
                write-verbose -message "$loopervar is now"
            }
        }
    }
}

function test-chinese-chars {
    param(
        [String] $string
    )
    foreach ($char in $string.ToCharArray()) {
        if ([int]$char -ge 11904) {
            return $True
        }
    }
    return $False
}

function sendToWebhook {
    param(
        [PSCustomObject]$item,
        [string]$name
    )
    #for privacy reasons
    $name = $name.split("@")[0]
    $description = ""
    $title += "$($item.nameEN)`n"
    for ($i=0;$i -lt $item.mods.length;$i++) {
        if($i -eq 0){
            $description+="`n"
        }
        $description+= $item.modsEN[$i]+"`n"
    }
    $description += "*$name $($item.Timestamp)*"

    #https://birdie0.github.io/discord-webhooks-guide/structure/embeds.html
    $payload = [PSCustomObject]@{
        embeds = @([PSCustomObject]@{
            color = $item.Color
            title = $title
            description = $description
        })
    }
    Invoke-RestMethod -Uri $hookUrl -Method Post -Body ($payload | ConvertTo-Json) -ContentType 'application/json; charset=utf-8' 
}

Function Show-Item {
    write-host -ForegroundColor red $($o.name) $($item.timestamp | Out-String -NoNewline)
    write-host -ForegroundColor red ($($item.nameEN + " - " + $item.name) | Out-String -NoNewline)
    write-host -ForegroundColor DarkGray ($($item.modsEN) | Out-String)
}

function helper {
    if ($PSVersionTable.PSVersion -le 7.1) {
        return "This powershell version is too old! You need 7+" 
    }

    if ($null -eq (Get-ChildItem $PSScriptRoot\$dict_file -ErrorAction SilentlyContinue)) {
        Write-Warning "The translation file does not exist -> trying to download"
        try {
            invoke-RestMethod $dict_source -OutFile $dict_file
        }
        catch {
            Write-Warning "Download seems to have failed -> terminating"
            Exit -1
        }
    }
}

$tw_dict = Get-Content $PSScriptRoot\twdict.txt -raw | ConvertFrom-Json
$global:staticmaps = Import-Csv $PSScriptRoot\static-name.txt -Header cn,en
$global:regexmaps = Import-Csv $PSScriptRoot\regex.txt -Delimiter ";" -Header cn,en
$global:prefix_rare = Import-Csv $PSScriptRoot\prefix_rare.txt -Header cn,en 
$global:suffix_rare = Import-Csv $PSScriptRoot\suffix_rare.txt -Header cn,en 
$global:prefix_magic = Import-Csv $PSScriptRoot\prefix_magic.txt -Header cn,en 
$global:suffix_magic = Import-Csv $PSScriptRoot\suffix_magic.txt -Header cn,en 
helper
Watch-Folder $path