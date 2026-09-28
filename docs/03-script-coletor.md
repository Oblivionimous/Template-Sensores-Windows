# 3. Script coletor

## 3.1 Por que uma lista plana

O JSON original do LHM é uma árvore aninhada com campos que o Zabbix não usa. Os valores vêm como texto (`"57,0 °C"`), e nomes como "CPU Package" se repetem em tipos diferentes.

O script devolve um objeto por sensor com `id`, `hardware`, `name`, `type`, `value` numérico e `unit`. O `id` é o `SensorId` do LHM.

A saída é ASCII puro, com `°` escrito como `\u00B0`. Isso elimina problemas de code page entre o PowerShell e o agente. O JSON é montado manualmente porque o `ConvertTo-Json` do PowerShell 5.1 falhou com "Os tipos de argumento não correspondem".

Decisões do código que valem registro.

- `Trim([char]0)` remove os caracteres nulos que o LHM acrescenta ao nome de alguns SSDs NVMe.
- A regex converte a vírgula decimal brasileira em ponto.
- O `catch` devolve a mensagem de erro e a linha, e o motivo aparece direto no Zabbix.

## 3.2 Criar o arquivo do script

O script fica em `C:\Program Files\Zabbix Agent 2\Scripts\sensors_json.ps1`. A cópia versionada está em [../scripts/sensors_json.ps1](../scripts/sensors_json.ps1).

### Opção A. Gravar por comando

Cole o bloco inteiro na janela do PowerShell como administrador no DESKTOP-MAURO. Ele cria a pasta `Scripts` se necessário e grava o arquivo em UTF-8 sem BOM. O comando `notepad` não serve aqui, porque só abre arquivos que já existem.

```powershell
$dir = "C:\Program Files\Zabbix Agent 2\Scripts"
New-Item -ItemType Directory -Path $dir -Force | Out-Null

$script = @'
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
'@

[IO.File]::WriteAllText("$dir\sensors_json.ps1", $script, (New-Object Text.UTF8Encoding($false)))
```

O conteúdo é ASCII puro, então o PowerShell 5.1 lê o arquivo sem problema mesmo sem BOM.

Cole o bloco na janela do PowerShell, e não dentro de um arquivo aberto em editor. Se o bloco entrar dentro do próprio `.ps1`, aparece o erro "A cadeia de caracteres não tem o terminador". Para regravar o script no futuro, o mesmo comando sobrescreve o arquivo.

### Opção B. Copiar do repositório clonado

Na pasta raiz do repositório clonado no DESKTOP-MAURO, em PowerShell como administrador.

```powershell
New-Item -ItemType Directory -Path "C:\Program Files\Zabbix Agent 2\Scripts" -Force | Out-Null
Copy-Item .\scripts\sensors_json.ps1 "C:\Program Files\Zabbix Agent 2\Scripts\sensors_json.ps1" -Force
```

## 3.3 Validar o arquivo criado

Rode cada passo e confira o resultado esperado antes de seguir.

### Passo 1. Confirmar que o arquivo existe

```powershell
$p = "C:\Program Files\Zabbix Agent 2\Scripts\sensors_json.ps1"
Get-Item $p | Select-Object FullName, Length, LastWriteTime
```

O resultado esperado é o caminho completo, tamanho próximo de 2 KB e data de gravação atual. Se aparecer "Cannot find path", o bloco do item 3.2 não foi executado por inteiro.

### Passo 2. Conferir a codificação

```powershell
$b = [IO.File]::ReadAllBytes($p)
"Primeiros bytes: " + ($b[0..2] -join ' ')
"Bytes acima de 127: " + @($b | Where-Object { $_ -gt 127 }).Count
```

O resultado esperado é `Primeiros bytes: 36 69 114` e `Bytes acima de 127: 0`. Os três primeiros números correspondem a `$Er`, o início de `$ErrorActionPreference`. Se aparecer `239 187 191`, o arquivo tem BOM. O PowerShell ainda o executa, mas regrave com o item 3.2 para manter o padrão.

### Passo 3. Validar a sintaxe

```powershell
$tokens = $null; $errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($p, [ref]$tokens, [ref]$errors)
"Erros de sintaxe: " + $errors.Count
```

O resultado esperado é `Erros de sintaxe: 0`. Se houver erros, liste a linha de cada um.

```powershell
$errors | Select-Object Message, @{n='Linha';e={$_.Extent.StartLineNumber}}
```

### Passo 4. Executar o script

```powershell
$raw = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p) -join ""
"Tamanho da saída: " + $raw.Length
$raw.Substring(0, [Math]::Min(100, $raw.Length))
```

O resultado esperado é um tamanho de dezenas de milhares de caracteres e um texto começando com `[{"id":"/lpc/it8689e/0/voltage/0"`. Se começar com `ZBX_NOTSUPPORTED:`, a mensagem seguinte indica o motivo, geralmente o LHM fechado ou sem Web Server.

### Passo 5. Validar o JSON e o conteúdo

```powershell
"Saída só ASCII: " + (-not [regex]::IsMatch($raw, '[^\x00-\x7F]'))
$dados = $raw | ConvertFrom-Json
"Sensores lidos: " + $dados.Count
$dados | Where-Object { $_.id -eq '/intelcpu/0/temperature/18' } | Format-List id, hardware, name, type, value, unit
```

O resultado esperado tem três partes.

- `Saída só ASCII: True`.
- `Sensores lidos` com algumas centenas de itens. Na coleta anterior foram 414, e o número varia com o hardware.
- Um registro `CPU Package` do tipo `Temperature`, com `value` numérico e `unit` em `°C`.

Se `Sensores lidos` mostrar `1`, o JSON está aninhado e o script precisa de revisão.

### Passo 6. Conferir IDs duplicados

```powershell
$dados | Group-Object id | Where-Object { $_.Count -gt 1 } | Select-Object Name, Count
```

No ambiente de teste deve aparecer `/gpu-nvidia/0/load/3` com contagem 2. Isso é a limitação registrada em [Limitações e pendências](08-limitacoes-e-pendencias.md) e não impede a validação do arquivo.

### Passo 7. Testar pela key do agente

Execute este passo somente depois de criar o UserParameter, descrito em [UserParameter](04-userparameter.md).

```powershell
& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -c "C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf" -t lhm.sensors
```

O resultado esperado começa com `lhm.sensors [s|[{"id":"/lpc/it8689e/0/voltage/0"`.

### Resumo dos resultados esperados

| Passo | Verifica | Esperado |
|---|---|---|
| 1 | Existência | Arquivo com cerca de 2 KB |
| 2 | Codificação | Primeiros bytes `36 69 114` e nenhum byte acima de 127 |
| 3 | Sintaxe | 0 erros |
| 4 | Execução | Saída iniciando com `[{"id":` |
| 5 | JSON | ASCII `True`, centenas de sensores, `CPU Package` presente |
| 6 | IDs | Apenas `/gpu-nvidia/0/load/3` duplicado |
| 7 | Agente | Retorno da key com o mesmo JSON |

## 3.4 Ver os sensores em tabela

O `ConvertFrom-Json` do PowerShell 5.1 entrega o array como um único objeto ao pipeline. Encadeado direto no Out-GridView, ele aparece como uma linha só. Guarde o resultado em uma variável e envie a variável.

```powershell
$dados = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\Scripts\sensors_json.ps1") -join "" | ConvertFrom-Json
$dados | Out-GridView
```

A janela deve abrir com uma linha por sensor e as colunas `id`, `hardware`, `name`, `type`, `value` e `unit`. Use o campo de filtro no topo para localizar sensores, por exemplo `Temperature`.

Próximo passo: [UserParameter](04-userparameter.md).
