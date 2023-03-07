<<<<<<< HEAD
﻿$ignoreItems = @()
$magicExceptions = @('銳利之斧')
$nameMap = @{"超強的" = "Superior";}
$dictSource = "https://gist.githubusercontent.com/r0-se/4f72452ac805fde9ff018df81867b49d/raw"
$dictFile = "twdict.txt"

$runeList=@{
    "El" = 1;"Eld" = 2;"Tir" = 3;"Nef" = 4;"Eth" = 5;"Ith" = 6;"Tal" = 7;"Ral" = 8;"Ort" = 9; "Thul" = 10;"Amn" = 11;"Sol" = 12;"Shael" = 13;"Dol" = 14;"Hel" = 15;"Io" = 16; "Lum" = 17;"Ko" = 18;"Fal" = 19;"Lem" = 20;"Pul" = 21;"Um" = 22;"Mal" = 23;"Ist" = 24;"Gul" = 25;"Vex" = 26;"Ohm" = 27;"Lo" = 28; "Sur" = 29;"Ber" = 30;"Jah" = 31;"Cham" = 32;"Zod" = 33;
}

$discColor=@{
    "white" = 16777215;
    "gold" = 13351039; 
    "green" = 65280;
=======
﻿$DiscColor = @{
    "white"  = 16777215;
    "gold"   = 13351039; 
    "green"  = 65280;
>>>>>>> refs/remotes/origin/main
    "yellow" = 15658613;
    "blue"   = 8421619;
    "orange" = 15628803;
    "grey"   = 5592405;
}
<<<<<<< HEAD

#loading config file
Get-Content "$PSScriptRoot\config.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
$path = $h.Get_Item("savepath")
$hookUrl = $h.Get_Item("hookurl")#
$minRune = If ($RuneList.Contains($h.Get_Item("min_rune"))) {$RuneList[$h.Get_Item("min_rune")]} Else {0}

=======
$IgnoreItems = @('Tir Rune', 'Ko Rune', 'Ral Rune', 'Ort Rune', 'Nef Rune', 'Sol Rune', 'Hel Rune', 'Lem Rune', 'Amn Rune', 'Tal Rune', 'Thul Rune')
$magic_exceptions = @('銳利之斧')
>>>>>>> refs/remotes/origin/main
function Get-rare-item {
    param([string]$name)
    $splitted = $name.split(" ")

<<<<<<< HEAD
    if($splitted.Count -eq 2) {
        if ($prefixRare.cn.Contains($splitted[0]) -and $suffixRare.cn.Contains($splitted[1])) {
            return ($prefixRare | Where-Object CN -eq $splitted[0]).en + " " + ($suffixRare | Where-Object CN -eq $splitted[1]).en
=======
    if ($splitted.Count -eq 2) {
        if ($prefix_rare.cn.Contains($splitted[0]) -and $suffix_rare.cn.Contains($splitted[1])) {
            return ($prefix_rare | Where-Object CN -eq $splitted[0]).en + " " + ($suffix_rare | Where-Object CN -eq $splitted[1]).en
>>>>>>> refs/remotes/origin/main
        }
    }
    return $false
}

function Get-magic-item {
    param([string]$name)
    $splitted = $name.split(" ")
    
    if ($splitted.Count -eq 1) {
        #stupid workaround for itemnames which match <prefix><type> but are actually white
<<<<<<< HEAD
        if($magicExceptions.Contains($name)){
=======
        if ($magic_exceptions.Contains($name)) {
>>>>>>> refs/remotes/origin/main
            break
        }

        #this is for names in the form "<prefix><type>" - NOT separated by a space
        #example 魚叉手之超大型護身符 harpoonists(魚叉手之) grand charm(超大型護身符)
<<<<<<< HEAD
        foreach($prefix in $prefixMagic){
=======
        foreach ($prefix in $prefix_magic) {
>>>>>>> refs/remotes/origin/main
            if ($name.StartsWith($prefix.cn)) {
                $splitted = $name.insert($prefix.cn.length, ' ').split(" ")
                break
            }
        }

        #this is for names in the form "<type><suffix>" - NOT separated by a space
        #example 小護身符幸運 small charm (小護身符) of luck(幸運)
<<<<<<< HEAD
        foreach($suffix in $suffixMagic){
=======
        foreach ($suffix in $suffix_magic) {
>>>>>>> refs/remotes/origin/main
            if ($name.EndsWith($suffix.cn)) {
                #also turns around the order so this is processed by the translation later
                $splitted = ($suffix.cn, $name.Substring(0, $name.length - $suffix.cn.length))
                break
            }
        }
    }

    if ($splitted.Count -eq 2) {
        #this is for names in the form "<prefix> <type>" - separated by a space
        if ($prefixMagic.cn.Contains($splitted[0])) {
            $type = Get-Name-Translation -original $splitted[1]
            $current_prefix = ($prefixMagic | Where-Object cn -eq $splitted[0] | Select-Object -Last 1).en
            return "$current_prefix $type"
        }

        #this is for names in the form "<suffix> <type>" - separated by a space -> not sure if that even happens naturally anymore
        if ($suffixMagic.cn.Contains($splitted[0])) {
            $type = Get-Name-Translation -original $splitted[1]
<<<<<<< HEAD
            $current_suffix = ($suffixMagic | Where-Object cn -eq $splitted[0]| Select-Object -Last 1).en 
=======
            $current_suffix = ($suffix_magic | Where-Object cn -eq $splitted[0] | Select-Object -Last 1).en 
>>>>>>> refs/remotes/origin/main
            return "$type $current_suffix"
        }
    }

    #this is for names in the form "<suffix> <suffix> <type>" - separated by a space; this is weird yo
    #example 火光之 品質的 超大型護身符 sparking(火光之) of quality(品質的) grand charm(超大型護身符)
<<<<<<< HEAD
    if($splitted.Count -eq 3) {
        if ($prefixMagic.cn.Contains($splitted[0]) -and $suffixMagic.cn.Contains($splitted[1])) {
=======
    if ($splitted.Count -eq 3) {
        if ($prefix_magic.cn.Contains($splitted[0]) -and $suffix_magic.cn.Contains($splitted[1])) {
>>>>>>> refs/remotes/origin/main
            $type = Get-Name-Translation -original $splitted[2]
            $current_prefix = ($prefixMagic | Where-Object cn -eq $splitted[0] | Select-Object -Last 1).en
            $current_suffix = ($suffixMagic | Where-Object cn -eq $splitted[1] | Select-Object -Last 1).en 
            return "$current_prefix $type $current_suffix"
        }
    }   
    return $false
}
function Get-Mod-Translation {
    param([string]$original)

    if (-not (test-chinese-chars -string $original)) {
        return $original
    }

    #remove all of those horrible brackets
    $original = $original.replace('（','(').replace('）',')')

    foreach ($s in $regexMaps) {
        if ($original -match $s.cn) {
            $result = $s.en
            for($i=1;$i -lt $Matches.count;$i++) {
                $result = $result -replace "\{$($i-1)\}", $Matches[$i]
            }
            return Get-Mod-Translation -original $result
        }
    }

    #this is supposed to insert skill and class names or weapon speeds
    foreach ($s in $staticMaps) {
        if ($original.Contains($s.cn)) {
            $pre = Get-Name-Translation -original $original.Substring(0, $original.IndexOf($s.cn)).Trim()
            $post = Get-Name-Translation -original $original.Substring($original.IndexOf($s.cn) + ($s.cn.length)).Trim()
            return Get-Mod-Translation -original "$pre $($s.en) $post".Trim()
        }
    }
<<<<<<< HEAD

=======
    
    foreach ($s in $regexmaps) {
        Write-verbose "Checking $original vs $s.cn"
        if ($original -match $s.cn) {
            $result = $s.en
            for ($i = 1; $i -lt $Matches.count; $i++) {
                $result = $result -replace "\{$($i-1)\}", $Matches[$i]
            }
            return $result
        }
    }
>>>>>>> refs/remotes/origin/main
    return "not in dict: $original"
}

function Get-Name-Translation {
    param([string]$original)
    if ($original -eq '') {
        return ''
    }
<<<<<<< HEAD
    foreach ($s in $nameMap.Keys) {
        if ($original.Contains($s)) {
            $pre = Get-Name-Translation -original $original.Substring(0, $original.IndexOf($s)).Trim()
            $post = Get-Name-Translation -original $original.Substring($original.IndexOf($s)+($s.length)).Trim()
            return "$pre $($nameMap.$s) $post".Trim()
=======
    foreach ($s in $staticmaps) {
        if ($original.Contains($s.cn)) {
            $pre = Get-Name-Translation -original $original.Substring(0, $original.IndexOf($s.cn)).Trim()
            $post = Get-Name-Translation -original $original.Substring($original.IndexOf($s.cn) + ($s.cn.length)).Trim()
            return "$pre $($s.en) $post".Trim()
>>>>>>> refs/remotes/origin/main
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
    
    #timestamp - easy
    if ($item -match '(?<first>[0-9]{4}\/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2})') {
        $returnItem.Timestamp = $matches[0]
    }

    #heres the name
    if ($item -match '.*(?=\d{4}\/)') {
        $returnItem.Name = $matches[0]
<<<<<<< HEAD
        #if it starts with rune - make it orange
        if($returnItem.Name.StartsWith("符文：")) {
=======
        if ($returnItem.Name.StartsWith("符文：")) {
>>>>>>> refs/remotes/origin/main
            $returnItem.Color = $DiscColor.orange
        }

        #find out if its magic by looking for prefix/suffix
        $magic = Get-magic-item -name $returnItem.Name
        if ($magic) {
            $returnItem.Color = $DiscColor.blue
            $returnItem.NameEN = $magic
        }
        else {
            $returnItem.NameEN = Get-Name-Translation -original $returnItem.Name
        }
    }

    #here we get the mods of the item
    if ($item -match '(?<=\d{4}\/\d{2}\/\d{2} \d{2}:\d{2})[\s\S]*') {
        $returnItem.Mods = New-Object System.Collections.ArrayList(, $matches[0].split("`n"))
        $returnItem.Mods.Reverse()
        
        #yellow//green//gold items seem to have their full name to be equal to first and second mod
        # $returnItem.Mods[0] <-- name
        # $returnItem.Mods[1] <-- type
        if ($returnItem.Name -eq $returnItem.Mods[1] + $returnItem.Mods[0]) {
            $rare = Get-rare-item -name $returnItem.Mods[0]
            if ($rare) {
                $returnItem.NameEN = $rare
                $returnItem.Color = $DiscColor.yellow
            }
            else {
                "Setting color to gold"
                $returnItem.Color = $DiscColor.gold
                $returnItem.NameEN = Get-Name-Translation -original $returnItem.Mods[0]
            }
            #only return the item name without type
        }
        $returnItem.Mods.RemoveAt(0)


        for ($i = 0; $i -lt $returnItem.mods.count; $i++) {
            if ($returnItem.mods[$i] -eq "") {
                #kills set summary
                $returnItem.Color = $DiscColor.green
                $returnItem.mods.RemoveRange($i, $returnItem.mods.count - $i)
                break;
            }

            #handle the first line of mods
<<<<<<< HEAD
            if($i -eq 0 -and $returnItem.color -ne $DiscColor.blue) {
                #non named items (white/grey) have def or damage in the first line
                if (($returnItem.mods[$i].StartsWith("雙手傷害：") -or 
                    $returnItem.mods[$i].StartsWith("防禦：") -or 
                    $returnItem.mods[$i].StartsWith("單手傷害：")))
                {
                    $returnItem.Color = $DiscColor.white
                    $returnItem.ModsEN.Add((Get-Mod-Translation -original $returnItem.mods[$i]))
                } else {
                    #colored items (yellow/green/gold) have itemtype as first attribute -> translate as name
                    $returnItem.ModsEN.Add((Get-Name-Translation -original $returnItem.mods[$i]))
                }
            } else {
=======
            if ($i -eq 0) {
                #non named items (white blue yellow grey) have def or damage in the first line
                if (($returnItem.mods[$i].StartsWith("雙手傷害：") -or $returnItem.mods[$i].StartsWith("防禦：") -or $returnItem.mods[$i].StartsWith("單手傷害："))) {
                    if ($returnItem.color -ne $DiscColor.blue -and $returnItem.color -ne $DiscColor.blue) {
                        $returnItem.Color = $DiscColor.white
                    }
                    $returnItem.ModsEN.Add((Get-Mod-Translation -original $returnItem.mods[$i]))
                }
                else {
                    #colored item have itemtype as first attribute -> translate as name
                    $returnItem.ModsEN.Add((Get-Name-Translation -original $returnItem.mods[$i]))
                }
                
            }
            else {
>>>>>>> refs/remotes/origin/main
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

    $currentSize = Get-ChildItem -path $path -Filter "入庫記錄.txt" -Recurse | Select-Object Length, PsPath
    if ($null -eq $currentSize) { 
        Write-Warning "no droplogs found in $path -> terminating"
        Exit -1    
    }

    
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
            write-host "Adding $($obj.name) at $($obj.path.replace("Microsoft.PowerShell.Core\FileSystem::",'')) to monitor"
        
            $mons += $obj
        }
    }

    write-host "Starting monitor loop.. all should be well (:"

    while ($true) {
        Start-Sleep 5
      
        foreach ($o in $mons) {
            $compare = (get-itemcount -Path $o.Path)
            if ($compare -ne $($o.ItemCount)) { 
                (Get-Process -pid $PID).MainWindowHandle | out-null
                
                $amountOfNewItems = $compare - $($o.ItemCount)
                $looperVar = $($o.ItemCount)
                $o.ItemCount = (get-itemcount -Path $o.Path)
<<<<<<< HEAD
                write-verbose -message "$($o.name) has changed with $amountOfNewItems var is $loopervar and $compare"
                for ($looperVar; $looperVar -lt $compare; $looperVar++) {
                    Write-verbose -Message "lets get $($o.Path) -Index $looperVar"
                    $item = Get-Item -Path $($o.Path) -Index $looperVar
                    if ($ignoreItems.Contains($item.nameEN) -or 
                        (
                            $item.nameEN.EndsWith(" Rune") -and 
                            $RuneList.Contains($item.nameEN.split(" ")[0]) -and
                            $RuneList[$item.nameEN.split(" ")[0]] -lt $minRune
                        )
                    ) { 
                        write-host -message "ignoring $($item.nameEN)" 
=======
                #regex map refresh here while workingon it so that dont have to restart script for changes
                $global:regexmaps = Import-Csv $PSScriptRoot\regex.txt -Delimiter ";" -Header cn, en
                write-verbose -message "$($o.name) has changed with $AmountofNewItems var is $loopervar and $compare"
                for ($loopervar; $loopervar -lt $compare; $loopervar++) {
                    Write-verbose -Message "lets get $($o.Path) -Index $loopervar"
                    $item = Get-Item -Path $($o.Path) -Index $loopervar
                    if ($IgnoreItems.Contains($item.nameEN)) { 
                        write-verbose -message "ignoring $($item.nameEN)" 
>>>>>>> refs/remotes/origin/main
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
    #for privacy reasons remove domain
    $name = $name.split("@")[0]
    $description = ""
    $title += "$($item.nameEN)`n"
    for ($i = 0; $i -lt $item.mods.length; $i++) {
        if ($i -eq 0) {
            $description += "`n"
        }
        $description += $item.modsEN[$i] + "`n"
    }
    $description += "*$name $($item.Timestamp)*"

    #https://birdie0.github.io/discord-webhooks-guide/structure/embeds.html
    $payload = [PSCustomObject]@{
        embeds = @([PSCustomObject]@{
                color       = $item.Color
                title       = $title
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
    $exit = $false
    $requiredfiles = @(
        "files\prefix_magic.txt",
        "files\prefix_rare.txt",
        "files\regex.txt",
        "files\static-name.txt",
        "files\suffix_magic.txt",
        "files\suffix_rare.txt",
        "files\twdict.txt"
    )
    if ($PSVersionTable.PSVersion -le 7.1) {
        "This powershell version is too old! You need 7+" 
        if ((Test-Path ("$env:programfiles\PowerShell\7\pwsh.exe"))) {
            "Found newer powershell attempting to restart with it..."
            $CommandLine = "-File `"" + $MyInvocation.ScriptName + "`" "
            Start-Process -FilePath "$env:programfiles\PowerShell\7\pwsh.exe" -ArgumentList $CommandLine
            write-host "Started with correct powershell version... closing in 5sec"
            Start-Sleep 5
            exit
        }
        else {
            Write-host "You need a modern powershell to run this script`ndownload and rerun this script`nhttps://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3"
            read-host "press enter to exit"
            exit

<<<<<<< HEAD
    if ($null -eq (Get-ChildItem "$PSScriptRoot\$dictFile" -ErrorAction SilentlyContinue)) {
        Write-Warning "The translation file does not exist -> trying to download"
        try {
            invoke-RestMethod $dictSource -OutFile $dictFile
        }
        catch {
            Write-Warning "Download seems to have failed -> terminating"
            Exit -1
=======
>>>>>>> refs/remotes/origin/main
        }
    }
    #Check that we havee required files
    foreach ($file in $requiredfiles) {
        if (-not (Test-Path $file)) {
            "$file is missing!"
            $exit = $true
        }
    }
    #Try to initialize the variables
    try {
        $tw_dict = Get-Content $PSScriptRoot\files\twdict.txt -raw | ConvertFrom-Json
        $global:staticmaps = Import-Csv $PSScriptRoot\files\static-name.txt -Header cn, en
        $global:regexmaps = Import-Csv $PSScriptRoot\files\regex.txt -Delimiter ";" -Header cn, en
        $global:prefix_rare = Import-Csv $PSScriptRoot\files\prefix_rare.txt -Header cn, en 
        $global:suffix_rare = Import-Csv $PSScriptRoot\files\suffix_rare.txt -Header cn, en 
        $global:prefix_magic = Import-Csv $PSScriptRoot\files\prefix_magic.txt -Header cn, en 
        $global:suffix_magic = Import-Csv $PSScriptRoot\files\suffix_magic.txt -Header cn, en 
    }
    catch {
        #Add some error msgs verbose peerhaps
        write-host "Could not setup variables!"
        Write-Host $_
        $exit = $true
    }
    if ($exit) { 
        Read-host "Could not start the script because of above issues, press enter key to exit"
        exit
    }
    #Lets try to parse config.ini
    if (-not (Test-path $psscriptroot\config.ini)) {
        Write-Host "No config file found, lets create one..in"
        New-Item -ItemType File "$psscriptroot\config.ini"
        "[General]" | Out-File -FilePath "$psscriptroot\config.ini"
        $url = Read-Host Enter your webhook URL
        "hookurl=$url" | Out-File -FilePath "$psscriptroot\config.ini" -Append
        $savepath = Read-Host Enter your savepath
        "savepath=$savepath"  | Out-File -FilePath "$psscriptroot\config.ini" -Append
    }
    Get-Content "$PSScriptRoot\config.ini" | foreach-object -begin { $h = @{} } -process { $k = [regex]::split($_, '='); if (($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } } -ErrorAction SilentlyContinue
    $Path = $h.Get_Item("savepath")
    $hookurl = $h.Get_Item("hookurl")
    #check if config has actual values
    if (-not $path -or -not $hookurl)
    {
        write-host "config.ini is broken please fix!"
        read-host 
        exit
    }
    Write-host "Starting droplog monitoring`npath=$path`nurl=$hookurl"
    Watch-Folder $path
}
<<<<<<< HEAD

$global:twDict = Get-Content "$PSScriptRoot\data\twdict.json" -raw | ConvertFrom-Json
$global:staticMaps = Import-Csv "$PSScriptRoot\data\static_mapping.csv" -Header cn,en
$global:regexMaps = Import-Csv "$PSScriptRoot\data\regex.csv" -Delimiter ";" -Header cn,en
$global:prefixRare = Import-Csv "$PSScriptRoot\data\prefix_rare.csv" -Header cn,en 
$global:suffixRare = Import-Csv "$PSScriptRoot\data\suffix_rare.csv" -Header cn,en 
$global:prefixMagic = Import-Csv "$PSScriptRoot\data\prefix_magic.csv" -Header cn,en 
$global:suffixMagic = Import-Csv "$PSScriptRoot\data\suffix_magic.csv" -Header cn,en 
helper
Watch-Folder $path
=======
helper
>>>>>>> refs/remotes/origin/main
