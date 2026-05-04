# Firefox Mocha - policy criada, mas tema não aplicou

Data: 20260504-154040

## Sintoma

O Firefox continuou sem aparência Mocha mesmo depois da geração/policy.

## Evidência do log anterior

A policy existe e está legível em:

- /etc/firefox/policies/policies.json

Ela aponta para:

- file:///etc/firefox/mocha-kde-firefox-theme.xpi

O arquivo existe e é legível pelo usuário normal.

## Hipótese atual

Não parece ser permissão simples. Próxima checagem: validar se o XPI é um tema WebExtension válido, se tem assinatura, se o ID do manifest bate com a policy, e se o Firefox instalou/rejeitou o add-on no perfil.

## Regra

Não registrar esse estado como visual final do Firefox.
Não mexer em perfil, sessão, user.js ou prefs.js sem confirmação/backup.
