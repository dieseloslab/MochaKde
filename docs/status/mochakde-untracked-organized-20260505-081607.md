# MochaKde — organização de untracked

- Data: 2026-05-05T08:16:08-03:00
- Repo: /media/mochafast/MochaKde
- Log: /media/mochafast/cachycomp-logs/organizar-mochakde-untracked-20260505-081607/run.log

## Regra aplicada

- Documentação, temas e estados visuais foram preservados no repo.
- Caches, logs, backups, audits e upstream-study foram movidos para fora do repo.
- Referências/caches Caninana-KDE foram movidos para `shared-kernel-video`.
- Módulos experimentais foram movidos para `modules.experimental/NAO-ATIVAR-20260505-081607`.
- Nada foi apagado.
- Nada foi alterado em `/etc/nixos`.
- Nenhum rebuild foi feito.

## Movidos para fora do repo

```text
classe                                 origem                                                                                     destino                                                                                                                                                               tipo     tamanho  acao
audits-fora-repo                       audits                                                                                     /media/mochafast/mochakde-external-artifacts/20260505-081607/audits/audits                                                                                            dir      488M     movido-fora-repo
backups-fora-repo                      backups                                                                                    /media/mochafast/mochakde-external-artifacts/20260505-081607/backups/backups                                                                                          dir      8,0K     movido-fora-repo
logs-fora-repo                         logs                                                                                       /media/mochafast/mochakde-external-artifacts/20260505-081607/logs/logs                                                                                                dir      824K     movido-fora-repo
upstream-study-fora-repo               upstream-study                                                                             /media/mochafast/mochakde-external-artifacts/20260505-081607/upstream-study/upstream-study                                                                            dir      508K     movido-fora-repo
caninana-reference-review              kde/caninana-reference/cache-built-missing-outputs-caninana-701-nvidia595-20260504-104604  /media/mochafast/shared-kernel-video/review/mochakde-untracked-20260505-081607/caninana-reference/cache-built-missing-outputs-caninana-701-nvidia595-20260504-104604  dir      29M      movido-fora-repo
caninana-703-aggressive-reference      kde/caninana-reference/caninana703-nvidia595-cachy-aggressive-20260505-062553              /media/mochafast/shared-kernel-video/candidates/caninana-7.0.3/mochakde-reference-20260505-081607/caninana703-nvidia595-cachy-aggressive-20260505-062553              dir      236K     movido-fora-repo
caninana-703-playability-reference     kde/caninana-reference/caninana703-nvidia595-playability-approved-20260505-061604          /media/mochafast/shared-kernel-video/candidates/caninana-7.0.3/mochakde-reference-20260505-081607/caninana703-nvidia595-playability-approved-20260505-061604          dir      224K     movido-fora-repo
caninana-703-playability-current-link  kde/caninana-reference/caninana703-nvidia595-playability-approved-current                  /media/mochafast/shared-kernel-video/candidates/caninana-7.0.3/mochakde-reference-20260505-081607/caninana703-nvidia595-playability-approved-current                  symlink  0        symlink-recriado-fora-repo
modulo-experimental-nao-ativar         kde/modules/caninana-cachy-performance-tweaks.nix                                          /media/mochafast/MochaKde/modules.experimental/NAO-ATIVAR-20260505-081607/kde-modules/caninana-cachy-performance-tweaks.nix                                           file     4,0K     movido-dentro-repo
modulo-experimental-nao-ativar         modules/zz-firefox-unlocked-policy.nix                                                     /media/mochafast/MochaKde/modules.experimental/NAO-ATIVAR-20260505-081607/modules-root/zz-firefox-unlocked-policy.nix                                                 file     4,0K     movido-dentro-repo
```

## Destinos externos

```text
/media/mochafast/mochakde-external-artifacts/20260505-081607
/media/mochafast/shared-kernel-video/review/mochakde-untracked-20260505-081607
/media/mochafast/shared-kernel-video/candidates/caninana-7.0.3/mochakde-reference-20260505-081607
```

## Próxima regra

Antes de criar módulo consumidor KDE, o repo deve estar sem untracked relevantes.

Módulos em `modules.experimental/NAO-ATIVAR-20260505-081607` são preservados apenas para auditoria.
