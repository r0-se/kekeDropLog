function Test-Chinese-Chars {
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

function Set-Globals {
    try {
        Set-Variable -name twDict -scope Global -value $(Get-Content "$PSScriptRoot\..\data\twdict.json" -raw | ConvertFrom-Json)
        Set-Variable -name staticMaps -scope Global -value $(Import-Csv "$PSScriptRoot\..\data\static_mapping.csv" -Header cn, en)
        Set-Variable -name regexMaps  -scope Global -value $(Import-Csv "$PSScriptRoot\..\data\regex.csv" -Delimiter ";" -Header cn, en)
        Set-Variable -name prefixRare -scope Global -value $(Import-Csv "$PSScriptRoot\..\data\prefix_rare.csv" -Header cn, en)
        Set-Variable -name suffixRare  -scope Global -value $(Import-Csv "$PSScriptRoot\..\data\suffix_rare.csv" -Header cn, en)
        Set-Variable -name prefixMagic -scope Global -value $(Import-Csv "$PSScriptRoot\..\data\prefix_magic.csv" -Header cn, en)
        Set-Variable -name suffixMagic -scope Global -value $(Import-Csv "$PSScriptRoot\..\data\suffix_magic.csv" -Header cn, en)
    }
    catch {
        Write-Host $_.Exception.Message
        exit
    }
}

function New-Config {
    $configSave = Read-Host "Press enter your savepath [c:\temp\save\]"
    $configSave = ("c:\temp\save\", $configSave)[[bool]$configSave]
    $configWebhook = Read-Host "Enter your webhook URL"
    $configMinRune = Read-Host "Whats the lowest rune you would like to get notified by?"
    $configMinRune = ("", $configMinRune)[[bool]$configMinRune]
    $configJSONDump = Read-Host "Would you like items logged to jsonfile on disk? Y/N"
    if ($configJSONDump -match '^Y$') { } else { $configJSONDump = "" }
    New-Item -ItemType File "$PSScriptRoot\..\config.ini" -Value ("[General]`nsavepath={0}`nhookurl={1}`nminrune={2}`njsondump={3}" -f $configSave, $configWebhook, $configMinRune, $configJSONDump) -Confirm
}

function Get-Config {
    if (-not (Test-Path "$PSScriptRoot\..\config.ini")) {
        $null = New-Config
    }
    $h = @{}
    Get-Content "$PSScriptRoot\..\config.ini" | foreach-object -process { $k = [regex]::split($_, '='); if (($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
    return $h
}

function Update-Regex-File {
    #reloads the regex file
    Set-variable -Name regexmaps -scope global -value $(Import-Csv "$PSScriptRoot\..\data\regex.csv" -Delimiter ";" -Header cn, en)
}