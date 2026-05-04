
---

## Registro de erro/lição - 20260504-025048

### Estado
Auditoria criada em `/media/mochafast/MochaKde/audits/auditoria-reprodutibilidade-20260504-025048`.

### Cagadas registradas
- Foram feitas tentativas demais de kernel/Cachy/Caninana/KDE sem manifesto canônico suficiente.
- Backups e caches foram criados de forma solta, dificultando recuperar o estado bom sem procurar o MOCHAFAST inteiro.
- O KDE foi tratado como se tema fosse uma camada única; isso é falso. Plasma/KDE exige inventário separado de Global Theme, Plasma Style, Color Scheme, Icon Theme, Cursor, Kvantum/Breeze, GTK, Konsole, Dolphin, wallpaper, painel e SDDM.
- Discover foi assumido como pronto sem validar backends. No NixOS ele deve ser tratado principalmente como frontend para Flatpak/temas/firmware, não como gerenciador declarativo do sistema.
- Quando apareceu a necessidade de recuperar usando duas pastas/fontes, o correto teria sido parar, recuperar, comparar e mesclar em uma árvore canônica com manifesto, em vez de seguir criando estados paralelos.
- Antes de qualquer novo comando destrutivo, rebuild, tema ou portabilidade, este arquivo e os manifestos existentes devem ser lidos.

### Regra daqui para frente
- Toda tentativa ruim deve ser marcada como ruim.
- Todo estado bom precisa de manifesto.
- Todo cache/kernel/driver usado precisa ter origem, outPath, drvPath, versão, data, host e validação.
- Não usar pasta do MOCHAFAST como import operacional direto sem copiar/normalizar para a árvore canônica do repo ou para `/etc/nixos`, conforme o caso.

---

## Erro crítico registrado - base errada tentou linux-6.18 - 20260504-030845

### Sintoma
Durante tentativa de corrigir Firefox/Discover, o dry-build apontou para `linux-6.18.26-modules` e `initrd-linux-6.18.26`.

### Causa
O rebuild estava sendo feito contra a base errada/legada de `/etc/nixos`, não contra a base MochaKde/Caninana/NVIDIA pinada.

### Regra obrigatória
Antes de qualquer fix de Firefox, Discover, tema, KDE, Steam ou Flatpak:
1. Validar kernel real.
2. Validar NVIDIA real.
3. Localizar configuração que declare esses mesmos artefatos.
4. Só então aplicar alteração.
5. Se aparecer `linux-6.18`, abortar.

---

## Base realinhada corretamente - 20260504-030845

### Resultado
`/etc/nixos` foi realinhado a partir da candidata que bateu com a geração bootada.

### Kernel/NVIDIA
- Kernel real: `7.0.1-cachyos`
- NVIDIA real: `595.71.05`
- Config escolhida: `/media/mochafast/MochaKde#mocha-kde-hal`
- Config aplicada em: `/etc/nixos#mocha-kde-hal`

### Proteção
O dry-build foi bloqueado contra `linux-6.18` e contra build de kernel/NVIDIA antes do switch.

### Relatório
`/media/mochafast/MochaKde/audits/realinhar-base-caninana-nvidia-20260504-030845`

---

## Firefox policy limpa via flake sem switch - 20260504-033359

### Correção
- Módulo `zz-firefox-unlocked-policy.nix` limpo.
- Import feito no `flake.nix`, sem assumir `configuration.nix` no repo raiz.
- `nix eval` confirmou policy vazia.
- Fluxo usado: dry-build, build, boot.
- Não foi usado switch.

### Relatório
`/media/mochafast/MochaKde/audits/firefox-policy-clean-boot-20260504-033359`

## 20260504-073606 - Tema Konsole/Firefox ainda não pronto

- Audit mostrou Konsole configurado por usuário em ~/.config/konsolerc e ~/.local/share/konsole.
- Audit mostrou ausência de perfil/esquema Konsole sistêmico.
- Audit mostrou Firefox com /etc/firefox/policies/policies.json vazio.
- O módulo modules/zz-firefox-unlocked-policy.nix zera policies/preferences/autoconfig e impede tema Firefox sistêmico.
- Decisão: criar tema Mocha KDE como padrão sistêmico da distro, não como correção por perfil de usuário.
- Não registrar estado visual final enquanto Konsole e Firefox não forem confirmados visualmente.

## 20260504-073932 - Correção: duplicidade programs.firefox.package

- Dry-build anterior falhou porque programs.firefox.package foi definido no módulo de apps e também no módulo de tema.
- Decisão: módulo kde/modules/mocha-kde-theme-system.nix não define enable/package do Firefox.
- O pacote Firefox continua pertencendo ao módulo de apps; o módulo de tema só define policies/preferences/extensão Mocha.
- Ainda não registrar estado visual final.

## 20260504-074624 - Firefox ainda não assumiu Mocha

- Konsole foi confirmado visualmente como muito bom.
- Firefox continuou igual.
- Correção aplicada agora: policy sistêmica com ExtensionSettings force_installed e Preferences locked para extensions.activeThemeID.
- Também será removido Firefox instalado no nix profile do usuário atual se ele estiver na frente do Firefox do sistema.
- Ainda não registrar estado final enquanto Firefox não for confirmado visualmente.

## 20260504-075415 - Firefox ainda não assumiu Mocha

- Konsole foi confirmado visualmente como muito bom.
- Firefox continuou igual mesmo com tentativa via policy/tema force_installed.
- Nova decisão: Firefox Mocha precisa ser pacote sistêmico da distro, com tema/policies/defaults dentro do pacote entregue pelo NixOS/MochaKde.
- Isto não é correção por usuário/perfil.
- Observação separada: MX Vertical demorou para responder na tela de login; investigar depois como Bluetooth/USB/HID/SDDM, sem misturar com tema.
- Ainda não registrar estado visual final enquanto Firefox não for confirmado.

## 20260504-075828 - Correção: Firefox com dono único

- Falha anterior: kde/modules/mocha-kde-theme-system.nix e kde/modules/mocha-firefox-force-theme-policy.nix definiam ExtensionSettings para o mesmo tema Firefox.
- Correção: mocha-kde-theme-system.nix agora contém somente KDE/Plasma/Konsole.
- Firefox passa a ser responsabilidade exclusiva de mocha-firefox-force-theme-policy.nix.
- Konsole continua aprovado visualmente, mas estado final ainda não deve ser registrado até Firefox ficar Mocha.

## 20260504-080029 - Correção: não substituir programs.firefox.package

- Dry-build anterior falhou com attribute 'override' missing.
- Causa: programs.firefox.package foi definido como um pacote artesanal via runCommand, mas o módulo oficial do Firefox espera um pacote com método override.
- Correção: não substituir programs.firefox.package no módulo de tema.
- O Firefox continua sendo o pacote oficial definido pelo módulo de apps/NixOS.
- O tema Mocha passa a ser aplicado por policies/preferences/extension force_installed.
- Konsole já foi aprovado visualmente; Firefox ainda precisa confirmação visual.

## 20260504-080235 - Firefox policy com XPI em /etc/firefox

- Build anterior produziu policies corretas em result/etc/firefox/policies/policies.json.
- O script abortou antes de boot porque procurou o XPI em result/sw/share, mas o XPI estava referenciado por store path na policy.
- Correção: publicar o XPI também como /etc/firefox/mocha-kde-firefox-theme.xpi e usar install_url=file:///etc/firefox/mocha-kde-firefox-theme.xpi.
- Ainda não registrar estado final; Firefox precisa confirmação visual.
