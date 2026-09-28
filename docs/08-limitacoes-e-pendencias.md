# 8. Limitações e pendências

- Início automático do LHM. O item 2.5 do documento do LibreHardwareMonitor não foi validado com reinicialização.
- Timeout do agente. O `Timeout=15` do documento do UserParameter não estava no conf usado nos testes.
- ID duplicado no LHM. Nos dados coletados, `/gpu-nvidia/0/load/3` aparece duas vezes, para "GPU Memory" e "GPU Bus". A LLD deve acusar conflito de key para um deles. Uma correção possível é o script acrescentar um sufixo ao segundo `id` repetido.
- Exposição da porta 8085. Confirme com `netstat -ano | findstr 8085` se o LHM escuta só em localhost.
- Volume de itens. O filtro cria um item por sensor de temperatura, ventoinha, carga, tensão e potência. Restrinja o filtro se o volume incomodar.
