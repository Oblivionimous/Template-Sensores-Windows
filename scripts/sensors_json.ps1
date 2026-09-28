$ErrorActionPreference = "Stop"
try {
    $inv  = [Globalization.CultureInfo]::InvariantCulture
    $data = Invoke-RestMethod -Uri "http://localhost:8085/data.json" -TimeoutSec 8
    $items = New-Object System.Collections.Generic.List[string]

    function Esc($s) {
        $sb = New-Object System.Text.StringBuilder
        foreach ($ch in ([string]$s).ToCharArray()) {
            $code = [int]$ch
            if ($code -eq 34)      { [void]$sb.Append('\"') }
            elseif ($code -eq 92)  { [void]$sb.Append('\\') }
            elseif ($code -lt 32 -or $code -gt 126) { [void]$sb.Append(('\u{0:X4}' -f $code)) }
            else                   { [void]$sb.Append($ch) }
        }
        return '"' + $sb.ToString() + '"'
    }

    function Walk($node, $hw) {
        if ($node.HardwareId) { $hw = ([string]$node.Text).Trim([char]0).Trim() }
        if ($node.SensorId) {
            $m = [regex]::Match([string]$node.RawValue, '^\s*(-?\d+(?:,\d+)?)\s*(.*)$')
            if ($m.Success) {
                $val  = [double]::Parse($m.Groups[1].Value.Replace(',', '.'), $inv)
                $unit = $m.Groups[2].Value.Trim()
                $items.Add('{"id":' + (Esc $node.SensorId) +
                           ',"hardware":' + (Esc $hw) +
                           ',"name":' + (Esc $node.Text) +
                           ',"type":' + (Esc $node.Type) +
                           ',"value":' + $val.ToString('R', $inv) +
                           ',"unit":' + (Esc $unit) + '}')
            }
        }
        foreach ($c in @($node.Children)) {
            if ($c -and $c.PSObject.Properties['Text']) { Walk $c $hw }
        }
    }

    Walk $data ''
    Write-Output ('[' + ($items -join ',') + ']')
} catch {
    Write-Output ("ZBX_NOTSUPPORTED: " + $_.Exception.Message + " (linha " + $_.InvocationInfo.ScriptLineNumber + ")")
}
