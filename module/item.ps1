$magicExceptions = @('銳利之斧')
$nameMap = @{"超強的" = "Superior"; }

$discColor = @{
    "white"  = 16777215;
    "gold"   = 13351039; 
    "green"  = 65280;
    "yellow" = 15658613;
    "blue"   = 8421619;
    "orange" = 15628803;
    "grey"   = 5592405;
}

function Get-ItemObject {
    #takes the chinese input and creates a custom object from it
    param([string]$item)

    $returnItem = [PSCustomObject]@{
        Timestamp = ''
        Name      = ''
        NameEN    = ''
        Mods      = $null
        ModsEN    = New-Object System.Collections.ArrayList($null)
        Color     = 16711680
        source    = 'John Doe'
    }
    $item = $item -replace '\x00', ''
    
    #timestamp - easy
    if ($item -match '(?<first>[0-9]{4}\/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2})') {
        $returnItem.Timestamp = $matches[0]
    }

    #heres the name
    if ($item -match '.*(?=\d{4}\/)') {
        $returnItem.Name = $matches[0]
        #if it starts with rune - make it orange
        if ($returnItem.Name.StartsWith("符文：")) {
            $returnItem.Color = $DiscColor.orange
        }

        #find out if its magic by looking for prefix/suffix
        $magic = Get-MagicItem -name $returnItem.Name
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
            $rare = Get-RareItem -name $returnItem.Mods[0]
            if ($rare) {
                $returnItem.NameEN = $rare
                $returnItem.Color = $DiscColor.yellow
            }
            else {
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
            if ($i -eq 0 -and $returnItem.color -ne $DiscColor.blue) {
                #non named items (white/grey) have def or damage in the first line
                if (($returnItem.mods[$i].StartsWith("雙手傷害：") -or 
                        $returnItem.mods[$i].StartsWith("防禦：") -or 
                        $returnItem.mods[$i].StartsWith("單手傷害："))) {
                    $returnItem.Color = $DiscColor.white
                    #stupid workaround to supress .Add method
                    $null = $returnItem.ModsEN.Add((Get-Mod-Translation -original $returnItem.mods[$i]))
                }
                else {
                    #colored items (yellow/green/gold) have itemtype as first attribute -> translate as name
                    #stupid workaround to supress .Add method
                    $null = $returnItem.ModsEN.Add((Get-Name-Translation -original $returnItem.mods[$i]))
                }
            }
            else {
                #normal mod
                #stupid workaround to supress .Add method
                $null = $returnItem.ModsEN.Add((Get-Mod-Translation -original $returnItem.mods[$i]))
            }
            
        }
        if ($returnItem.color -eq $DiscColor.white -and ($returnItem.modsEN[-1].Contains("Socketed") -or $returnItem.modsEN[-1].Contains("Ethereal"))) {
            $returnItem.color = $DiscColor.grey
        }
    }

    return $returnItem
}

function Get-RareItem {
    #determines if a item is rare by its name and returns the translation if it is
    param([string]$name)
    $splitted = $name.split(" ")

    if ($splitted.Count -eq 2) {
        if ($prefixRare.cn.Contains($splitted[0]) -and $suffixRare.cn.Contains($splitted[1])) {
            return ($prefixRare | Where-Object CN -eq $splitted[0]).en + " " + ($suffixRare | Where-Object CN -eq $splitted[1]).en
        }
    }
    return $false
}

function Get-MagicItem {
    #determines if a item is magic by its name and returns the translation if it is
    param([string]$name)
    $splitted = $name.split(" ")
    
    if ($splitted.Count -eq 1) {
        #stupid workaround for itemnames which match <prefix><type> but are actually white
        if ($magicExceptions.Contains($name)) {
            break
        }

        #this is for names in the form "<prefix><type>" - NOT separated by a space
        #example 魚叉手之超大型護身符 harpoonists(魚叉手之) grand charm(超大型護身符)
        foreach ($prefix in $prefixMagic) {
            if ($name.StartsWith($prefix.cn)) {
                $splitted = $name.insert($prefix.cn.length, ' ').split(" ")
                break
            }
        }

        #this is for names in the form "<type><suffix>" - NOT separated by a space
        #example 小護身符幸運 small charm (小護身符) of luck(幸運)
        foreach ($suffix in $suffixMagic) {
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
            $current_suffix = ($suffixMagic | Where-Object cn -eq $splitted[0] | Select-Object -Last 1).en 
            return "$type $current_suffix"
        }
    }

    #this is for names in the form "<suffix> <suffix> <type>" - separated by a space; this is weird yo
    #example 火光之 品質的 超大型護身符 sparking(火光之) of quality(品質的) grand charm(超大型護身符)
    if ($splitted.Count -eq 3) {
        if ($prefixMagic.cn.Contains($splitted[0]) -and $suffixMagic.cn.Contains($splitted[1])) {
            $type = Get-Name-Translation -original $splitted[2]
            $current_prefix = ($prefixMagic | Where-Object cn -eq $splitted[0] | Select-Object -Last 1).en
            $current_suffix = ($suffixMagic | Where-Object cn -eq $splitted[1] | Select-Object -Last 1).en 
            return "$current_prefix $type $current_suffix"
        }
    }   
    return $false
}
function Get-Mod-Translation {
    #returns the translation of an items mod (e.g. +3 to Strength)
    param([string]$original)

    if (-not (test-chinese-chars -string $original)) {
        return $original
    }

    #remove all of those horrible brackets
    $original = $original.replace('（', '(').replace('）', ')')

    foreach ($s in $regexMaps) {
        if ($original -match $s.cn) {
            $result = $s.en
            for ($i = 1; $i -lt $Matches.count; $i++) {
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

    return "not in dict: $original"
}

function Get-Name-Translation {
    #returns the translation for itemnames
    param([string]$original)
    if ($original -eq '') {
        return ''
    }
    foreach ($s in $nameMap.Keys) {
        if ($original.Contains($s)) {
            $pre = Get-Name-Translation -original $original.Substring(0, $original.IndexOf($s)).Trim()
            $post = Get-Name-Translation -original $original.Substring($original.IndexOf($s) + ($s.length)).Trim()
            return "$pre $($nameMap.$s) $post".Trim()
        }
    }
    $out = $twdict |  Where-Object { $_."tw-old" -eq $original } | Select-Object -Last 1
    if ($out.enUS) {
        return $out.EnUS
    }

    return $original
}

function Get-Items {
    param(
        [PSCustomObject]$bot,
        [int]$newCount
    )
    Update-Regex-File
    $result = @()
    for ($index=$($bot.ItemCount); $index -lt $newCount; $index++) {
        $result += (Get-Item -Bot $bot -Index $index)
    }
    return $result
}