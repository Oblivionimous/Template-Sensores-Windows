# 5. Template no frontend do Zabbix

Estes passos rodam no frontend web do Zabbix Server. O arquivo do template está em [../zabbix/template_sensores_windows.yaml](../zabbix/template_sensores_windows.yaml).

## 5.1 Importar

1. Vá em Data collection > Templates > Import.
2. Selecione `template_sensores_windows.yaml` e importe.

O template se chama `Template Sensores Windows` e fica no grupo `Personalizados`.

<img width="1675" height="444" alt="image" src="https://github.com/user-attachments/assets/4e996b4b-1ed5-429c-87b8-96c30cc8b634" />


## 5.2 Vincular ao host

1. Vá em Data collection > Hosts > Seu Host.
2. Na aba Templates, adicione `Template Sensores Windows`.
3. Salve.

## 5.3 Estrutura do template

### Item mestre

- Name: `Sensores de Hardware (LHM JSON)`
- Type: Zabbix agent (active)
- Key: `lhm.sensors`
- Type of information: Text
- History: Do not store
- Trends: 0

O histórico fica desligado porque o valor é grande. Os itens dependentes recebem o JSON completo antes do descarte, então nenhum dado se perde.

### Regra de descoberta

- Name: `Hardware Sensors Discovery`
- Type: Dependent item
- Key: `lhm.sensors.discovery`
- Master item: `lhm.sensors`
- Filtro: `{#SENSOR_TYPE}` corresponde a `^(Temperature|Fan|Load|Voltage|Power)$`

### Macros LLD

| Macro | JSONPath |
|---|---|
| `{#SENSOR_HW}` | `$.hardware` |
| `{#SENSOR_ID}` | `$.id` |
| `{#SENSOR_NAME}` | `$.name` |
| `{#SENSOR_TYPE}` | `$.type` |
| `{#SENSOR_UNIT}` | `$.unit` |

### Protótipo de item

- Name: `Hardware: {#SENSOR_HW} - {#SENSOR_NAME} ({#SENSOR_TYPE})`
- Type: Dependent item
- Key: `lhm.sensor[{#SENSOR_ID}]`
- Master item: `lhm.sensors`
- Type of information: Numeric (float)
- Units: `{#SENSOR_UNIT}`
- Preprocessing, JSONPath: `$[?(@.id == '{#SENSOR_ID}')].value.first()`
- Tags: `component`, `sensor.hw` e `sensor.type`

Como o script já entrega `value` numérico, o pré-processamento dispensa etapa de regex.

### Dashboard

O dashboard `Temperaturas Críticas (CPU, GPU e Armazenamento)` acompanha o template. Os gráficos referenciam itens pelo nome, com curinga no hardware, por exemplo `Hardware: * - CPU Package (Temperature)`. Isso funciona em qualquer máquina que exponha os mesmos nomes de sensor.

Próximo passo: [Validação no Zabbix](06-validacao-no-zabbix.md).
