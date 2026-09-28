# 4. UserParameter em arquivo separado

Comandos em PowerShell como administrador no DESKTOP-MAURO. A cópia versionada do arquivo está em [../agent/userparameter_lhm.conf](../agent/userparameter_lhm.conf).

## 4.1 Conferir o Include da pasta

```powershell
$conf = "C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf"
Select-String -Path $conf -Pattern '^\s*Include='
```

O arquivo já contém `Include=C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\`, que carrega todos os arquivos da pasta. Não adicione outro `Include` para ela. O arquivo seria lido duas vezes e o agente falharia com "duplicate user parameter".

## 4.2 Criar o arquivo do UserParameter

O agente exige UTF-8 sem BOM. O `Set-Content -Encoding UTF8` do PowerShell 5.1 grava com BOM, então use `WriteAllLines`.

```powershell
$dir = "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d"
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$up = 'UserParameter=lhm.sensors,powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\Scripts\sensors_json.ps1"'
[IO.File]::WriteAllLines("$dir\userparameter_lhm.conf", @($up), (New-Object Text.UTF8Encoding($false)))
```

A key é `lhm.sensors` e não menciona CPU. Ela serve para qualquer sensor do LHM.

## 4.3 Ajustar o timeout do agente

Se o `zabbix_agent2.conf` não definir `Timeout`, vale o padrão de 3 segundos. O script inicia o PowerShell e consulta o LHM, e pode passar disso. O máximo permitido é 30.

```powershell
Add-Content -Path $conf -Value ("`r`n" + 'Timeout=15') -Encoding ASCII
```

## 4.4 Testar e reiniciar

Teste antes de reiniciar. Se houver erro de configuração, o teste mostra o motivo.

```powershell
& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -c $conf -t lhm.sensors
Restart-Service "Zabbix Agent 2"
Get-Service "Zabbix Agent 2"
```

O teste deve imprimir `lhm.sensors [s|[{"id":...` e o serviço deve estar em `Running`.

Próximo passo: [Template no Zabbix](05-template-zabbix.md).
