$Host.UI.RawUI.WindowTitle = "ErrorX MacroCheck"

$boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$recent = (Get-Date).AddMinutes(-30)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$script:hits = 0
$script:weak = 0

$macroTools = "autohotkey", "\bahk", "autoit", "tinytask", "jitbit", "pulover", "macro", "x-?mouse", "rewasd", "ds4windows",
              "inputmapper", "joytokey", "antimicro", "auto ?click", "clicker", "ptfb", "ghost ?mouse", "key ?presser",
              "auto ?typer", "murgee", "^ucr\b"
$vendors = "g ?hub", "logitech gaming", "logi options", "setpoint", "razer", "steelseries", "icue", "corsair", "armoury crate",
           "bloody", "ngenuity", "glorious", "roccat", "masterplus", "dragon center", "msi center", "redragon", "attack ?shark",
           "wootility", "swiftpoint", "mad ?catz", "lamzu", "pwnage", "darmoshark", "wlmouse", "atk ?hub", "vgn", "machenike",
           "endgame gear", "finalmouse", "zowie", "pulsar"
$vendorProcs = "lghub", "lcore", "logioptions", "razer", "steelseries", "icue", "corsair", "armourycrate", "bloody", "ngenuity",
               "glorious", "roccat", "masterplus", "dragoncenter", "msi ?center", "wootility", "swiftpoint", "madcatz", "lamzu",
               "pwnage", "darmoshark", "wlmouse", "atk", "vgn"
$ignore = "macroscanner", "macrodetector", "macrocheck", "errorx", "macromedia"
$notTheTool = "unins", "uninst", "setup", "update", "crash", "helper", "install"
$skipDirs = "Cache", "Code Cache", "GPUCache", "Service Worker", "Crashpad", "CrashReports", "IndexedDB", "Session Storage", "Dictionaries", "node_modules", "\.git"

$toolPattern = $macroTools -join "|"
$vendorPattern = $vendors -join "|"
$vendorProcPattern = "^(" + ($vendorProcs -join "|") + ")"
$ignorePattern = $ignore -join "|"
$notTheToolPattern = $notTheTool -join "|"
$skipDirPattern = "\\(" + ($skipDirs -join "|") + ")$"

$macroExt = ".ahk", ".ahk2", ".au3", ".mcr", ".rec", ".pmc", ".tkm", ".mmmac", ".rms", ".amc", ".kbs", ".cuecfg", ".rewasd", ".emr", ".akp"
$configExt = ".json", ".xml", ".txt", ".cfg", ".ini", ".lua", ".log", ".dat", ".db", ".ldb", ".cueprofile", ".cuecfg", ".pr0", ".dct", ".mac", ".macro"

$x86 = ${env:ProgramFiles(x86)}
$vendorPaths = [ordered]@{
    "G HUB"        = "$env:LOCALAPPDATA\LGHUB", "$env:APPDATA\LGHUB", "$env:PROGRAMDATA\LGHUB", "$env:APPDATA\LGHUB_BKP", "$env:PROGRAMDATA\LGHUBData"
    "Logitech"     = "$env:APPDATA\Logitech", "$env:LOCALAPPDATA\Logitech"
    "Razer"        = "$env:APPDATA\Razer", "$env:LOCALAPPDATA\Razer", "$env:PROGRAMDATA\Razer"
    "SteelSeries"  = "$env:APPDATA\SteelSeries", "$env:LOCALAPPDATA\SteelSeries"
    "Corsair"      = "$env:APPDATA\Corsair"
    "ROCCAT"       = "$env:APPDATA\ROCCAT"
    "Glorious"     = "$env:APPDATA\Glorious", "$env:LOCALAPPDATA\Glorious", "$env:LOCALAPPDATA\GloriousCore", "$env:APPDATA\glorious-core-app"
    "ASUS"         = "$env:LOCALAPPDATA\ASUS\ArmouryCrate", "$env:PROGRAMDATA\ASUS\ArmouryCrate", "$env:USERPROFILE\Documents\ASUS\ROG\ROG Armoury"
    "Bloody"       = "$env:APPDATA\Bloody", "$env:LOCALAPPDATA\Bloody", "$env:PROGRAMDATA\Bloody", "$x86\Bloody7\Bloody7\Data\Mouse\English\ScriptsMacros"
    "MSI"          = "$env:APPDATA\MSI"
    "HyperX"       = "$env:APPDATA\HyperX", "$env:LOCALAPPDATA\Packages\33C30B79.HyperXNGenuity_0a78dr3hq0pvt\LocalState"
    "Redragon"     = "$env:APPDATA\REDRAGON"
    "Attack Shark" = "$env:APPDATA\AttackShark", "$env:LOCALAPPDATA\AttackShark", "$env:PROGRAMDATA\AttackShark"
    "Pulsar"       = "$env:APPDATA\Pulsar"
    "Finalmouse"   = "$env:APPDATA\Finalmouse"
    "ZOWIE"        = "$env:APPDATA\ZOWIE"
    "Endgame Gear" = "$env:APPDATA\Endgame Gear"
    "Alienware"    = "$env:PROGRAMDATA\Alienware"
    "Kensington"   = "$env:APPDATA\Kensington"
    "Cougar"       = "$env:APPDATA\Cougar"
    "LAMZU"        = "$env:LOCALAPPDATA\LAMZU"
    "Pwnage"       = "$env:LOCALAPPDATA\Pwnage"
    "VGN"          = "$env:APPDATA\ATK Hub", "$env:LOCALAPPDATA\VGN Hub"
    "Darmoshark"   = "$env:LOCALAPPDATA\Darmoshark"
    "WLmouse"      = "$env:APPDATA\WLmouse"
    "Machenike"    = "$env:APPDATA\Machenike"
    "Delux"        = "$env:LOCALAPPDATA\Delux"
    "Mad Catz"     = "$env:PUBLIC\Documents\Mad Catz"
    "Swiftpoint"   = "$env:LOCALAPPDATA\Swiftpoint"
    "UtechSmart"   = "$env:APPDATA\UtechSmart"
    "BY-COMBO"     = "$env:LOCALAPPDATA\BY-COMBO", "$env:APPDATA\BYCOMBO-2", "$env:LOCALAPPDATA\BYCOMBO-2", "$env:LOCALAPPDATA\BY-8801-GM917-v108"
    "KROM KOLT"    = "$env:LOCALAPPDATA\VirtualStore\Program Files (x86)\KROM KOLT"
    "Xenon200"     = "$x86\Xenon200"
    "Blackweb"     = "C:\Blackweb Gaming AP"
    "SPC Gear"     = "$x86\SPC Gear"
    "Ayax"         = "$env:ProgramFiles\AYAX GamingMouse"
    "Marsgaming"   = "$x86\MARSGAMING\MMGX"
    "Motospeed"    = "$x86\MotoSpeed Gaming Mouse"
    "CoolerMaster" = "$x86\CoolerMaster\MasterPlus"
    "Fantech"      = "$x86\FANTECH VX7 Gaming Mouse"
    "Wooting"      = "$env:APPDATA\wootility"
    "VIA"          = "$env:APPDATA\VIA"
}

$toolFolders = @(
    "$env:APPDATA\Highresolution Enterprises\XMouseButtonControl"
    "$env:APPDATA\MacroGamer"
    "$env:APPDATA\OPAutoClicker"
    "$env:APPDATA\GSAutoClicker"
    "$env:APPDATA\SpeedAutoClicker"
    "$env:APPDATA\TinyTask"
    "$env:PROGRAMDATA\Disc Soft\reWASD"
    "$env:USERPROFILE\Documents\JoyToKey"
    "$env:LOCALAPPDATA\antimicrox"
    "$env:APPDATA\Jitbit\MacroRecorder"
    "$env:APPDATA\MacroCreator"
    "$env:APPDATA\Murgee\Auto Clicker"
    "$env:PROGRAMDATA\Technology Lighthouse\PTFB Pro"
    "$env:APPDATA\GhostMouse"
    "$env:APPDATA\DS4Windows"
    "$env:APPDATA\InputMapper"
    "$env:APPDATA\TGMacro"
    "$env:APPDATA\MiniMouseMacro"
    "$env:APPDATA\MacroToolworks"
    "$env:APPDATA\UCR"
    "$env:APPDATA\Perfect Automation"
    "$env:APPDATA\AutoClickTyper"
    "$env:APPDATA\Free Mouse Auto Clicker"
    "$env:APPDATA\Auto Keyboard Presser"
    "$env:APPDATA\Easy Macro Recorder"
    "$env:LOCALAPPDATA\AutoHotkey"
    "$env:ProgramFiles\AutoHotkey"
    "$x86\AutoIt3"
)

$vendorIds = @{
    "046D" = "Logitech"
    "1532" = "Razer"
    "1038" = "SteelSeries"
    "1B1C" = "Corsair"
    "1E7D" = "ROCCAT"
    "0B05" = "ASUS"
    "09DA" = "A4Tech/Bloody"
    "0951" = "HyperX"
    "03F0" = "HP/HyperX"
    "045E" = "Microsoft"
    "093A" = "PixArt"
    "258A" = "SinoWealth"
    "04D9" = "Holtek"
    "3554" = "Compx"
}

Add-Type @'
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class MacroCheckNative {
    delegate bool EnumProc(IntPtr hwnd, IntPtr lParam);

    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc callback, IntPtr lParam);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr hwnd, StringBuilder text, int max);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr hwnd, StringBuilder text, int max);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr hwnd, out uint pid);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)] static extern uint QueryDosDevice(string drive, StringBuilder target, int max);

    public static List<string[]> Windows() {
        var list = new List<string[]>();
        EnumWindows(delegate (IntPtr hwnd, IntPtr lParam) {
            var title = new StringBuilder(512);
            var cls = new StringBuilder(256);
            uint pid;
            GetWindowText(hwnd, title, 512);
            GetClassName(hwnd, cls, 256);
            GetWindowThreadProcessId(hwnd, out pid);
            list.Add(new string[] { cls.ToString(), title.ToString(), pid.ToString() });
            return true;
        }, IntPtr.Zero);
        return list;
    }

    public static string DevicePath(string drive) {
        var target = new StringBuilder(260);
        return QueryDosDevice(drive, target, 260) > 0 ? target.ToString() : null;
    }
}
'@

function Write-Head($title) {
    Write-Host ""
    Write-Host "  $title" -ForegroundColor Cyan
    $script:mark = $script:hits + $script:weak
}

function Write-Hit($text) {
    $script:hits++
    Write-Host "  [!] $text" -ForegroundColor Red
}

function Write-Weak($text) {
    $script:weak++
    Write-Host "  [?] $text" -ForegroundColor Yellow
}

function Write-Note($text) { Write-Host "      $text" -ForegroundColor Gray }

function Write-Clean {
    if ($script:hits + $script:weak -eq $script:mark) { Write-Host "  [+] nothing" -ForegroundColor Green }
}

function Format-When($time) {
    if (-not $time) { return "unknown" }
    $ago = (Get-Date) - $time
    $agoText = if ($ago.TotalMinutes -lt 1) { "just now" }
        elseif ($ago.TotalHours -lt 1) { "{0} min ago" -f $ago.Minutes }
        elseif ($ago.TotalDays -lt 1) { "{0} h {1} min ago" -f $ago.Hours, $ago.Minutes }
        else { "{0} d {1} h ago" -f [int][math]::Floor($ago.TotalDays), $ago.Hours }
    "$($time.ToString('dd.MM.yyyy HH:mm:ss')) ($agoText)"
}

function Write-Trace($time, $text) {
    if ($time -ge $boot) { Write-Hit "$text  $(Format-When $time)" } else { Write-Weak "$text  $(Format-When $time)" }
}

function Test-Tool($name) { $name -match $toolPattern -and $name -notmatch $ignorePattern }

function Find-Files($root, [int]$maxDepth, $extensions) {
    if (-not $root -or -not (Test-Path -LiteralPath $root)) { return }
    if (Test-Path -LiteralPath $root -PathType Leaf) { return $root }

    $stack = New-Object Collections.Stack
    $stack.Push(@($root, 0))
    while ($stack.Count -gt 0) {
        $dir, $depth = $stack.Pop()
        try {
            foreach ($f in [IO.Directory]::GetFiles($dir)) {
                if ($extensions -contains [IO.Path]::GetExtension($f).ToLower()) { $f }
            }
            if ($depth -ge $maxDepth) { continue }
            foreach ($d in [IO.Directory]::GetDirectories($dir)) {
                if ($d -notmatch $skipDirPattern) { $stack.Push(@($d, ($depth + 1))) }
            }
        } catch {
            continue
        }
    }
}

function Test-MacroText($path) {
    try {
        $stream = [IO.File]::Open($path, "Open", "Read", "ReadWrite")
        if ($stream.Length -gt 20MB) { $stream.Close(); return $false }
        $reader = New-Object IO.StreamReader($stream)
        $t = $reader.ReadToEnd().ToLower()
        $reader.Close()
    } catch {
        return $false
    }

    if ($t -match '"macros?"\s*:\s*[\[{]\s*[^\]}\s]') { return $true }
    if ($t -match '"macromanager"|"macrodata"|<macros?[\s>]|\[macro|macro\s*=') { return $true }
    if ($t.Contains("onevent") -and $t -match "pressmousebutton|movemouserelative|pressandreleasekey") { return $true }
    if ($t.Contains('"assignments"') -and ($t.Contains('"delay"') -or $t.Contains('"script"'))) { return $true }
    if ($t.Contains("macro") -and ($t.Contains("delay") -or $t.Contains("action"))) { return $true }
    if ($t.Contains("sequence") -and $t.Contains("delay")) { return $true }
    if ($t.Contains("::") -and $t.Contains("send")) { return $true }
    return $t.Contains("click") -and $t.Contains("sleep")
}

Write-Host ""
Write-Host "  ErrorX MacroCheck" -ForegroundColor Magenta
Write-Host "  boot $(Format-When $boot)" -ForegroundColor DarkGray
Write-Host "  red = since boot, yellow = older" -ForegroundColor DarkGray
if (-not $isAdmin) { Write-Host "  not admin, skipping prefetch and bam" -ForegroundColor Yellow }

$prefetch = @{}
$bam = @{}
if ($isAdmin) {
    foreach ($pf in Get-ChildItem "$env:SystemRoot\Prefetch" -Filter *.pf -ErrorAction SilentlyContinue) {
        $exe = $pf.Name.Substring(0, $pf.Name.LastIndexOf("-"))
        if (-not $prefetch[$exe] -or $pf.LastWriteTime -gt $prefetch[$exe].LastWriteTime) { $prefetch[$exe] = $pf }
    }

    $devices = @{}
    foreach ($drive in [IO.DriveInfo]::GetDrives()) {
        $letter = $drive.Name.TrimEnd("\")
        $dev = [MacroCheckNative]::DevicePath($letter)
        if ($dev) { $devices[$dev] = $letter }
    }

    foreach ($key in Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings" -ErrorAction SilentlyContinue) {
        foreach ($value in $key.GetValueNames()) {
            $bytes = $key.GetValue($value)
            if ($bytes -isnot [byte[]] -or $bytes.Length -lt 8 -or $value -notlike "\Device\*") { continue }

            $path = $value
            foreach ($dev in $devices.Keys) {
                if ($path.StartsWith("$dev\")) { $path = $devices[$dev] + $path.Substring($dev.Length); break }
            }
            $time = [DateTime]::FromFileTime([BitConverter]::ToInt64($bytes, 0))
            $exe = Split-Path $path -Leaf
            if (-not $bam[$exe] -or $time -gt $bam[$exe].Time) { $bam[$exe] = @{ Path = $path; Time = $time } }
        }
    }
}

function Get-LastRun([string[]]$exeNames) {
    $last = $null
    foreach ($exe in $exeNames) {
        if ($prefetch[$exe] -and $prefetch[$exe].LastWriteTime -gt $last) { $last = $prefetch[$exe].LastWriteTime }
        if ($bam[$exe] -and $bam[$exe].Time -gt $last) { $last = $bam[$exe].Time }
    }
    $last
}


Write-Head "Mice"
$older = 0
foreach ($m in @(Get-PnpDevice -Class Mouse -ErrorAction SilentlyContinue)) {
    $props = @(Get-PnpDeviceProperty -InstanceId $m.InstanceId -KeyName DEVPKEY_Device_LastArrivalDate, DEVPKEY_Device_LastRemovalDate -ErrorAction SilentlyContinue)
    $arrived = ($props | Where-Object KeyName -eq "DEVPKEY_Device_LastArrivalDate").Data
    $removed = ($props | Where-Object KeyName -eq "DEVPKEY_Device_LastRemovalDate").Data

    $brand = "?"
    if ($m.InstanceId -match "VID[_&](?:02)?([0-9A-F]{4})") {
        $brand = if ($vendorIds[$Matches[1]]) { $vendorIds[$Matches[1]] } else { "VID $($Matches[1])" }
    }

    if ($m.Present) {
        Write-Host "  [+] $($m.FriendlyName) ($brand), plugged in $(Format-When $arrived)" -ForegroundColor Green
    } elseif ($removed -and $removed -ge $boot) {
        Write-Weak "unplugged $($m.FriendlyName) ($brand)  $(Format-When $removed)"
    } else {
        $older++
    }
}
if ($older) { Write-Note "$older old mice in device history" }


Write-Head "Software"
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                 "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                 "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
$apps = Get-ItemProperty $uninstallKeys -ErrorAction SilentlyContinue | Where-Object DisplayName | Sort-Object DisplayName -Unique

foreach ($app in $apps) {
    $isTool = Test-Tool $app.DisplayName
    if (-not $isTool -and $app.DisplayName -notmatch $vendorPattern) { continue }

    $exes = @()
    $folder = "$($app.InstallLocation)".Trim('"')
    if ($folder -and (Test-Path -LiteralPath $folder)) {
        $exes += Get-ChildItem -LiteralPath $folder -Filter *.exe -Recurse -Depth 2 -ErrorAction SilentlyContinue | ForEach-Object Name
    }
    if ($app.DisplayIcon) {
        $exes += Split-Path ("$($app.DisplayIcon)" -replace ",\d+$", "").Trim('"') -Leaf
    }
    $exes = @($exes | Where-Object { $_ -like "*.exe" -and $_ -notmatch $notTheToolPattern } | Select-Object -Unique)

    $name = "$($app.DisplayName) $($app.DisplayVersion)".Trim()
    $last = Get-LastRun $exes
    $run = if ($last) { "last run $(Format-When $last)" } elseif ($isAdmin) { "never run" } else { "last run unknown" }

    if (-not $isTool) {
        Write-Note "$name, $run"
    } elseif ($last -and $last -ge $boot) {
        Write-Hit "$name, $run"
    } else {
        Write-Weak "$name, $run"
    }
}
Write-Clean


Write-Head "Processes"
$seen = @{}
$flagged = @{}
foreach ($p in Get-CimInstance Win32_Process) {
    $name = [IO.Path]::GetFileNameWithoutExtension($p.Name)
    if (Test-Tool $name) {
        Write-Hit "$($p.Name) ($($p.ProcessId)) $($p.ExecutablePath)"
        $flagged[[int]$p.ProcessId] = $true
    } elseif ($p.Name -match "^(wscript|cscript|pythonw?|pyw?)\.exe$" -and $p.CommandLine -match "\.(pyw?|vbs|vbe|js|jse|wsf)\b") {
        Write-Weak "script: $($p.CommandLine)"
    } elseif ($name -match $vendorProcPattern -and -not $seen[$name]) {
        $seen[$name] = $true
        Write-Note $p.Name
    }
}

foreach ($w in [MacroCheckNative]::Windows()) {
    $cls, $title, $wpid = $w
    if ($flagged[[int]$wpid]) { continue }
    if ($cls -like "AutoHotkey*") {
        Write-Hit "ahk script: $title ($wpid)"
        $flagged[[int]$wpid] = $true
    } elseif (Test-Tool $title) {
        Write-Weak "window: $title ($wpid)"
        $flagged[[int]$wpid] = $true
    }
}
Write-Clean


Write-Head "Configs changed since boot"
$checked = New-Object "Collections.Generic.HashSet[string]" ([StringComparer]::OrdinalIgnoreCase)
foreach ($vendor in $vendorPaths.Keys) {
    foreach ($root in $vendorPaths[$vendor]) {
        foreach ($file in Find-Files $root 8 $configExt) {
            if (-not $checked.Add($file)) { continue }
            $changed = [IO.File]::GetLastWriteTime($file)
            if ($changed -lt $boot -or -not (Test-MacroText $file)) { continue }

            $text = "${vendor}: $file  $(Format-When $changed)"
            if ($changed -ge $recent) { Write-Hit $text } else { Write-Weak $text }
        }
    }
}
Write-Clean


Write-Head "Tool folders"
foreach ($dir in $toolFolders) {
    if (-not $dir -or -not (Test-Path -LiteralPath $dir)) { continue }
    $newest = Get-ChildItem -LiteralPath $dir -Recurse -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $time = if ($newest) { $newest.LastWriteTime } else { (Get-Item -LiteralPath $dir).LastWriteTime }
    Write-Trace $time $dir
}
Write-Clean


Write-Head "Macro files"
$roots = @(
    [Environment]::GetFolderPath("Desktop")
    [Environment]::GetFolderPath("MyDocuments")
    "$env:USERPROFILE\Downloads"
    $env:APPDATA
    $env:TEMP
    $env:OneDrive
    $env:PUBLIC
) | Where-Object { $_ } | Select-Object -Unique

$files = New-Object "Collections.Generic.HashSet[string]" ([StringComparer]::OrdinalIgnoreCase)
foreach ($root in $roots) {
    foreach ($f in Find-Files $root 8 $macroExt) { [void]$files.Add($f) }
}
foreach ($drive in [IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq "Fixed" -and $_.IsReady -and $_.Name -ne "$env:SystemDrive\" }) {
    foreach ($f in Find-Files $drive.RootDirectory.FullName 3 $macroExt) { [void]$files.Add($f) }
}

$sorted = @($files | Sort-Object { [IO.File]::GetLastWriteTime($_) } -Descending)
foreach ($f in $sorted | Select-Object -First 40) { Write-Trace ([IO.File]::GetLastWriteTime($f)) $f }
if ($sorted.Count -gt 40) { Write-Note "$($sorted.Count - 40) more" }
Write-Clean


Write-Head "Execution"
if ($isAdmin) {
    foreach ($exe in $prefetch.Keys | Sort-Object { $prefetch[$_].LastWriteTime } -Descending) {
        if (-not (Test-Tool $exe)) { continue }
        $pf = $prefetch[$exe]
        Write-Trace $pf.LastWriteTime "prefetch $exe, first ~$($pf.CreationTime.ToString('dd.MM.yyyy HH:mm')), last"
    }
    foreach ($exe in $bam.Keys | Sort-Object { $bam[$_].Time } -Descending) {
        if (-not (Test-Tool $exe)) { continue }
        Write-Trace $bam[$exe].Time "bam $($bam[$exe].Path)"
    }
} else {
    Write-Note "prefetch and bam need admin"
}

foreach ($lnk in Get-ChildItem "$env:APPDATA\Microsoft\Windows\Recent" -Filter *.lnk -ErrorAction SilentlyContinue) {
    $target = $lnk.BaseName
    if (($macroExt -contains [IO.Path]::GetExtension($target).ToLower()) -or (Test-Tool $target)) {
        Write-Trace $lnk.LastWriteTime "recent $target"
    }
}
Write-Clean


Write-Head "Result"
if ($script:hits) {
    Write-Host "  $($script:hits) since boot, $($script:weak) older" -ForegroundColor Red
} elseif ($script:weak) {
    Write-Host "  $($script:weak) older" -ForegroundColor Yellow
} else {
    Write-Host "  clean" -ForegroundColor Green
}
Write-Host ""
