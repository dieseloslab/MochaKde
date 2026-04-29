# Steam - Mocha Game Session

Estado aprovado do fluxo gamer do Diesel OS Lab - GNOME Mocha Edition.

Atalho principal:
Steam - Mocha Game Session

Esse atalho deve:
- ativar o perfil TuneD latency-performance;
- abrir a interface normal da Steam;
- exportar MangoHud para a sessão;
- não usar gamemoderun na Steam inteira;
- não desativar nem reiniciar o Dash to Dock.

Linha oficial por jogo:
/run/current-system/sw/bin/mocha-steam-run %command%

Campo na Steam:
Propriedades do jogo > Geral > Opções de inicialização

O que NAO usar:
- não usar: gamemoderun steam
- não usar como padrão final: gamemoderun %command%

Arquitetura aprovada:
- Steam abre normal pelo steam-mocha-session.
- Jogo roda via /run/current-system/sw/bin/mocha-steam-run %command%.
- mocha-steam-run aplica GameMode no jogo, não no cliente Steam.
- Dash to Dock deve ficar funcional usando a versão 104.
- Dash to Dock não deve ser desligado ou reativado pelo launcher da Steam.
