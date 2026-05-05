# Lição: comportamento de fechamento do Konsole

O tema MochaKde não deve alterar comportamento funcional do Konsole.

Regra correta:
- Em instalação limpa, o Konsole pode perguntar ao fechar múltiplas abas/sessões.
- Se o usuário escolher "fechar todas" e marcar "não perguntar novamente", a decisão deve ser respeitada.
- O sistema não deve apagar nem sobrescrever `~/.config/konsolerc` em `[Notification Messages]` depois que o usuário tomar uma decisão.
- Scripts de tema não devem mexer em `konsoleui.rc`, atalhos, menus, ações de janela ou decisões salvas de confirmação.
- Tema visual do Konsole deve ser aplicado por esquema de cores/perfil, não por override de interface.

Erro observado:
- Durante tentativa de tema, o Konsole passou a ter comportamento confuso de fechamento e janela.
- Também apareceu KWin com `BorderlessMaximizedWindows=true`, causando janela maximizada sem botões.

Regra para MochaKde final:
- Não shippar override local de `~/.local/share/kxmlgui*/konsole/konsoleui.rc`.
- Não forçar `[Notification Messages]` no `konsolerc`.
- Não resetar decisão do usuário em rebuild, login ou aplicação de tema.
