# Receita Mocha NordVPN / NordLynx / GUI

Data: 20260506-150052  
Host: mocha-kde-hal  
Usuário: hal

## Estado validado

Integração atual da NordVPN no MochaKde/NixOS.

Modo funcional validado:

- Tecnologia: NordLynx / WireGuard
- Protocolo mostrado pela Nord: UDP
- Interface esperada: nordlynx
- Serviço: nordvpnd.service
- Comando principal: mocha-vpn wireguard
- Desligar: mocha-vpn off
- Validar: scripts/vpn/mocha-nordvpn-validate.sh
- Teste HTTPS/download: scripts/vpn/mocha-vpn-speedtest-https.sh

NordLynx aparece como UDP porque WireGuard usa UDP. Isso não é o mesmo que OpenVPN UDP.

## O que NÃO deve ser salvo

Nunca salvar em Git:

- token NordVPN
- arquivo com token
- PrivateKey
- credenciais
- sessão exportada
- cookies
- logs contendo Authorization Bearer

## Fonte ativa

A configuração ativa continua sendo /etc/nixos.

Este diretório é receita/backup/referência para reproduzir na próxima instalação.

## Arquivos copiados

- módulo ativo: nixos-modules/vpn/mocha-vpn-modes.current.nix
- wrapper GUI: scripts/vpn/mocha-nordvpn-gui
- validação: scripts/vpn/mocha-nordvpn-validate.sh
- speedtest HTTPS: scripts/vpn/mocha-vpn-speedtest-https.sh

## GUI

A GUI real da Nord existe como nordvpn-gui.

O wrapper Mocha faz antes:

1. garantir nordvpnd.service ativo;
2. garantir norduserd rodando;
3. registrar logs em ~/.local/state/mocha-nordvpn-gui/gui.log;
4. abrir nordvpn-gui.

Comando:

```bash
mocha-nordvpn-gui
```

## Validação esperada

```text
nordvpn status -> Status: Connected
Current technology: NORDLYNX
Current protocol: UDP
ip route get 1.1.1.1 -> dev nordlynx
cloudflare trace -> loc=BR / colo=GRU ou local esperado
```

## Cloudflare WARP

Não é o caminho principal neste estado. O caminho aprovado por enquanto é NordLynx.

## Como usar depois de reinstalar

1. Restaurar o módulo Nix para /etc/nixos/modules/mocha-vpn-modes.nix.
2. Garantir que o flake injete nordvpnPkg via input separado, se o pacote ainda não existir no nixpkgs principal.
3. Rodar dry-build.
4. Confirmar que não há rebuild de kernel/NVIDIA.
5. Rodar build.
6. Rodar boot, não switch.
7. Reiniciar.
8. Rodar mocha-nord-login e colar token.
9. Rodar mocha-vpn wireguard.
10. Validar com scripts/vpn/mocha-nordvpn-validate.sh.


## Validação manual da GUI

Data: 20260506-150300

O usuário confirmou visualmente que o cliente gráfico real da NordVPN está funcionando no MochaKde.

Estado esperado para uso diário:

- GUI: usar "Mocha NordVPN GUI" ou `mocha-nordvpn-gui`
- CLI confiável: `nordvpn status`
- Atalho funcional: `mocha-vpn wireguard`
- Desligar: `mocha-vpn off`

Observação:

Se a GUI alterar tecnologia para OpenVPN UDP/TCP e a conexão piorar, voltar para NordLynx/WireGuard com:

```bash
mocha-vpn wireguard
```


## Validação adicional: GUI alterando modo real

Data: 20260506-150435

A GUI real da NordVPN foi confirmada como funcional e capaz de alterar o estado real do daemon.

Estado observado via GUI:

```text
Status: Connected
Technology: OPENVPN
Protocol: UDP
Interface: nordtun
Processo: openvpn
Servidor: Brazil #104 / br104.nordvpn.com
```

Conclusão:

- A GUI não é apenas cosmética.
- A GUI controla o daemon real `nordvpnd`.
- Quando a GUI muda para UDP, pode significar OpenVPN UDP, não NordLynx.
- Para voltar ao modo preferido/validado de baixa sobrecarga, usar:

```bash
mocha-vpn wireguard
```

Observação de estabilidade:

Foi visto evento `pingresp not received`; portanto OpenVPN UDP pela GUI fica registrado como funcional, mas não como melhor padrão para jogos/estabilidade.
