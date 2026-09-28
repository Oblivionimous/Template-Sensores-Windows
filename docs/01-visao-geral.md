# 1. Visão geral

Este documento parte do princípio de que o Zabbix Agent 2 já está instalado, o host já existe no Zabbix e a comunicação entre os dois já funciona.

O LibreHardwareMonitor (LHM) lê os sensores do desktop e publica um JSON em HTTP local. Um script PowerShell converte esse JSON em uma lista plana. O agente executa o script pela key `lhm.sensors`, e o template cria um item por sensor por descoberta automática (LLD).

## Fluxo de coleta

1. O LHM expõe `http://localhost:8085/data.json`.
2. O script `sensors_json.ps1` lê esse endereço e devolve um array JSON, um objeto por sensor.
3. O UserParameter `lhm.sensors` executa o script.
4. O item mestre do template recebe o JSON, e os itens dependentes extraem cada sensor.

## Arquivos no DESKTOP-MAURO

| Caminho | Função |
|---|---|
| `C:\Program Files\Zabbix Agent 2\Scripts\sensors_json.ps1` | Script coletor |
| `C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\userparameter_lhm.conf` | UserParameter `lhm.sensors` |
| `C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf` | Configuração principal do agente |
| `C:\Program Files\Zabbix Agent 2\zabbix_agent2.log` | Log do agente |

## Ordem de execução

1. [LibreHardwareMonitor](02-librehardwaremonitor.md)
2. [Script coletor](03-script-coletor.md)
3. [UserParameter](04-userparameter.md)
4. [Template no Zabbix](05-template-zabbix.md)
5. [Validação no Zabbix](06-validacao-no-zabbix.md)
