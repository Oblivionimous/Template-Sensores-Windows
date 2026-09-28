# Monitoramento de sensores de hardware do Windows com LibreHardwareMonitor e Zabbix

Este repositório documenta a coleta de sensores de hardware de um desktop Windows no Zabbix. O LibreHardwareMonitor (LHM) lê os sensores, um script PowerShell gera um JSON plano, e o Zabbix Agent 2 entrega o resultado ao servidor. Um template cria um item por sensor por descoberta automática (LLD).

## Requisitos

- Windows com PowerShell 5.1 e acesso de administrador.
- Zabbix Agent 2 instalado, host cadastrado no Zabbix e comunicação ativa já funcionando.
- Zabbix 7.0, versão do template exportado.
- LibreHardwareMonitor, testado com a versão 0.9.6.

Este repositório não cobre instalação do agente, PSK, IP nem rede.

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `docs/` | Passo a passo detalhado, em ordem de execução |
| `scripts/sensors_json.ps1` | Script coletor |
| `agent/userparameter_lhm.conf` | UserParameter `lhm.sensors` |
| `zabbix/template_sensores_windows.yaml` | Template com item mestre, LLD e dashboard |

## Início rápido

1. Instalar e configurar o LHM em [docs/02-librehardwaremonitor.md](docs/02-librehardwaremonitor.md).
2. Criar e validar o script em [docs/03-script-coletor.md](docs/03-script-coletor.md).
3. Criar o UserParameter em [docs/04-userparameter.md](docs/04-userparameter.md).
4. Importar e vincular o template em [docs/05-template-zabbix.md](docs/05-template-zabbix.md).
5. Validar a coleta em [docs/06-validacao-no-zabbix.md](docs/06-validacao-no-zabbix.md).

## Documentação

1. [Visão geral](docs/01-visao-geral.md)
2. [LibreHardwareMonitor](docs/02-librehardwaremonitor.md)
3. [Script coletor](docs/03-script-coletor.md)
4. [UserParameter](docs/04-userparameter.md)
5. [Template no Zabbix](docs/05-template-zabbix.md)
6. [Validação no Zabbix](docs/06-validacao-no-zabbix.md)
7. [Solução de problemas](docs/07-solucao-de-problemas.md)
8. [Limitações e pendências](docs/08-limitacoes-e-pendencias.md)

## Arquivos que não devem ser versionados

O `zabbix_agent2.conf`, o `zabbix_agent2.psk` e os logs do agente contêm dados do ambiente. O `.gitignore` bloqueia esses arquivos.
