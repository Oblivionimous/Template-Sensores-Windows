# 7. Solução de problemas

| Sintoma | Causa | Ação |
|---|---|---|
| Bloco de Notas informa "O sistema não pode encontrar o caminho especificado" | A pasta `Scripts` ainda não existe | Executar o bloco do item 3.2, que cria a pasta e o arquivo |
| "A cadeia de caracteres não tem o terminador" | Bloco de criação colado dentro do arquivo `.ps1` | Colar o bloco na janela do PowerShell e regravar o arquivo |
| `ZBX_NOTSUPPORTED` sem mensagem | Versão antiga do script sem detalhe no `catch` | Regravar o script do item 3.2 |
| `ZBX_NOTSUPPORTED: ... (linha N)` | Falha na linha indicada, geralmente LHM fechado | Reabrir o LHM como administrador e ativar o Web Server |
| Sensores de CPU ou placa-mãe ausentes na árvore | LHM aberto sem elevação | Fechar e abrir conforme o item 2.2 |
| LHM não sobe após reinicialização | Início automático não criado ou sem privilégio máximo | Validar o item 2.5 e criar a tarefa manual, se preciso |
| Serviço não inicia, log cita "duplicate user parameter" | `Include` da pasta `zabbix_agent2.d` repetido | Manter um único `Include` da pasta |
| Agente falha ao ler a configuração | Arquivo gravado com BOM | Regravar com `WriteAllLines` e UTF-8 sem BOM |
| "Os tipos de argumento não correspondem" | Bug do `ConvertTo-Json` no PowerShell 5.1 | Usar o script com JSON manual |
| `Â°C` no lugar de `°C` | Saída não ASCII lida em outra code page | Usar o script atual, que escreve `\u00B0` |
| Out-GridView com uma única linha | O `ConvertFrom-Json` do PowerShell 5.1 entrega o array como um objeto só | Guardar a saída em uma variável e enviar a variável ao Out-GridView |
| Item mestre sem dados | Timeout de 3 s ou LHM parado | Definir `Timeout=15` e validar o item 2.4 |
