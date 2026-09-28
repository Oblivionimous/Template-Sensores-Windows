# 6. Validação no Zabbix

1. No DESKTOP-MAURO, execute `zabbix_agent2.exe -t lhm.sensors` e confirme o JSON.
2. Aguarde até 2 minutos pelo primeiro valor.
3. No frontend, abra Monitoring > Latest data, filtre por DESKTOP-MAURO e abra o valor de `Sensores de Hardware (LHM JSON)`.
4. Vá em Data collection > Hosts > DESKTOP-MAURO > Discovery, abra `Hardware Sensors Discovery` e use Execute now.
5. Confirme em Latest data que os itens `Hardware: ...` têm valores numéricos.
6. Abra o dashboard do template e confira os gráficos.

Em caso de erro, consulte o log do agente no DESKTOP-MAURO.

```powershell
Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.log" -Tail 50
```

Se algo falhar, veja [Solução de problemas](07-solucao-de-problemas.md).
