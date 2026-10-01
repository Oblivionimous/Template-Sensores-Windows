# 2. LibreHardwareMonitor no DESKTOP-MAURO

Os comandos deste documento rodam em PowerShell como administrador.

## 2.1 Instalar

```powershell
winget install LibreHardwareMonitor.LibreHardwareMonitor
```

## 2.2 Abrir o LibreHardwareMonitor como administrador

O LHM precisa de elevação para ler os sensores da placa-mãe, da CPU e dos discos. Sem ela, várias temperaturas não aparecem na árvore e o Zabbix recebe uma lista incompleta.

### Pelo menu Iniciar

1. Pressione a tecla Windows e digite `LibreHardwareMonitor`.
2. Clique com o botão direito no resultado e escolha "Executar como administrador".
3. Confirme o aviso do Controle de Conta de Usuário.

O atalho `Ctrl+Shift+Enter` na pesquisa abre o programa direto como administrador.

### Quando o programa não aparece na pesquisa

A instalação pelo winget pode não criar entrada no menu Iniciar. Nesse caso, crie um atalho que sempre abra como administrador.

1. Abra a pasta de pacotes do winget.

   ```powershell
   explorer "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"
   ```

2. Entre na pasta `LibreHardwareMonitor.LibreHardwareMonitor_Microsoft.Winget.Source_8wekyb3d8bbwe`.
3. Clique com o botão direito em `LibreHardwareMonitor.exe` e escolha "Mostrar mais opções" > "Enviar para" > "Área de trabalho (criar atalho)".
4. Na área de trabalho, clique com o botão direito no atalho e abra "Propriedades".
5. Na aba Atalho, clique em "Avançados".
6. Marque "Executar como administrador" e confirme com OK.
7. Para o atalho aparecer na pesquisa do menu Iniciar, mova-o para `C:\Users\<usuário>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs`.

### Confirmar que está elevado

1. Abra o Gerenciador de Tarefas e vá na aba "Detalhes".
2. Clique com o botão direito no cabeçalho das colunas e escolha "Selecionar colunas".
3. Marque "Elevado" e confirme.
4. Localize `LibreHardwareMonitor.exe`. A coluna deve mostrar "Sim".

Uma checagem visual complementar é a árvore de sensores. Com elevação, a CPU mostra as linhas de temperatura, como "CPU Package".

## 2.3 Ativar o Remote Web Server e iniciar com o Windows

Esta etapa tem duas partes. A primeira publica o JSON que o script lê. A segunda faz o LHM subir sozinho após reinicialização ou logon. Faça as duas com o programa aberto como administrador, conforme o item 2.2.

### Remote Web Server

1. No menu, abra Options > Remote Web Server.
2. Marque Run.
3. Mantenha a porta 8085.

### Início automático

<img width="457" height="632" alt="image" src="https://github.com/user-attachments/assets/5bbf90e1-6fc6-4b44-93ba-5d493223d591" />

1. Em Options, marque Run On Windows Startup.
2. Em Options, marque Start Minimized, para o programa subir sem abrir a janela.
3. Em Options, marque Minimize To Tray, para ficar apenas na bandeja do sistema.

Ative Run On Windows Startup com o programa já elevado. Assim a inicialização automática herda o privilégio de administrador e o Web Server continua ativo após o boot.

Ao final, o menu Options deve ter estes itens marcados:

- Remote Web Server > Run
- Run On Windows Startup
- Start Minimized
- Minimize To Tray

## 2.4 Validar o Web Server

```powershell
Get-Process LibreHardwareMonitor
(Invoke-WebRequest -UseBasicParsing http://localhost:8085/data.json).StatusCode
```
<img width="975" height="223" alt="image" src="https://github.com/user-attachments/assets/8f73bcff-6636-4a80-8783-dd554ac1c474" />

O primeiro comando deve listar o processo e o segundo deve retornar `200`.

## 2.5 Validar o início automático

Esta etapa ainda não foi testada neste ambiente.

1. Confira se existe uma tarefa agendada criada pela opção Run On Windows Startup.

   ```powershell
   Get-ScheduledTask | Where-Object { $_.TaskName -match 'Libre' } | Select-Object TaskName, State, @{n='RunLevel';e={$_.Principal.RunLevel}}
   ```
<img width="1109" height="140" alt="image" src="https://github.com/user-attachments/assets/1ed518ff-d1ee-40f7-b390-bb2b88706816" />

2. O resultado esperado é uma tarefa com `RunLevel` igual a `Highest`.
3. Reinicie o desktop e faça logon.
4. Repita a validação do item 2.4 sem abrir o programa manualmente.
5. Repita a checagem da coluna "Elevado" do item 2.2.

Se o passo 1 não listar nenhuma tarefa, a opção do programa não criou a inicialização elevada. Crie a tarefa manualmente em PowerShell como administrador.

```powershell
$exe = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter LibreHardwareMonitor.exe | Select-Object -First 1).FullName
$action    = New-ScheduledTaskAction -Execute $exe -WorkingDirectory (Split-Path $exe)
$trigger   = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName "LibreHardwareMonitor" -Action $action -Trigger $trigger -Principal $principal
```

Use esse comando apenas se a opção do programa não tiver criado a tarefa. Com as duas ativas, o LHM abriria em duplicidade. A tarefa dispara no logon do usuário. Se o desktop reiniciar e ninguém fizer logon, o LHM não sobe e a coleta para.

Próximo passo: [Script coletor](03-script-coletor.md).
