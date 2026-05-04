# Firefox Mocha profile chrome

Estado confirmado visualmente em: 20260504-160000

Perfil usado no teste:

```
/home/hal/.config/mozilla/firefox/jh1lijvi.default
```

Arquivos:

- `userChrome.css`: aparência da interface Firefox
- `userContent.css`: páginas internas about:*

Observação:

O XPI local unsigned foi rejeitado pelo Firefox Release com:

```
ERROR_SIGNEDSTATE_REQUIRED
```

O caminho final da distro deve assinar/publicar o tema ou aplicar esta camada de forma sistêmica/controlada sem quebrar perfil.
