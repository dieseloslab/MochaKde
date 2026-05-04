# Firefox Mocha - XPI local unsigned rejeitado

Data: 20260504-154340

## Diagnóstico

O tema XPI local estava correto como zip e o ID batia com a policy, mas não tinha META-INF/assinatura.
O tema não apareceu em extensions.json.

## Conclusão

Firefox Release rejeita/ignora tema local unsigned.
Não era erro de permissão.

## Caminho adotado agora

1. Parar de forçar o XPI unsigned por policy.
2. Usar userChrome.css com backup para validar visualmente a paleta Mocha no usuário atual.
3. Para a distro final, assinar/publicar o tema Mocha Firefox via AMO/self-distribution.
