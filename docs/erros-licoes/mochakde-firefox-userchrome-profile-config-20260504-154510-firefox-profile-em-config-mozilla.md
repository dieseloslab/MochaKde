# Firefox Mocha - perfil real em ~/.config/mozilla/firefox

Data: 20260504-154510

## Diagnóstico

O Firefox do Nix/KDE usa perfil em:

- ~/.config/mozilla/firefox/jh1lijvi.default

A tentativa anterior procurou somente em:

- ~/.mozilla/firefox

## Outro diagnóstico confirmado

A policy tentava instalar um XPI local unsigned e o Firefox mostrou:

- ERROR_SIGNEDSTATE_REQUIRED

Conclusão: parar de forçar XPI unsigned e usar userChrome para validar visualmente.
Para produto final, assinar/publicar o tema Firefox Mocha.
