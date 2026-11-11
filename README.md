# AURUM · Fila de Posts

App de controle de postagem do AURUM Cinema. Cada post do lote vira um card com prévia, legenda (versão celular e versão PC) com botão de copiar, botão de baixar o arquivo, campo de dia e "marcar como postado". Funciona no celular e no PC e sincroniza entre os dois.

- **App publicado:** https://claude.ai/artifact/KeQcj2ohn58kJ1egU1uhJq
- **Código:** `index.html` (página única, sem build).
- **Dados:** banco do próprio artifact (coleção `posts`) + arquivos como assets do artifact.

## Como um lote entra na fila
Feito pelo Claude depois de entregar o lote com o selo AU (ver `claude/FILA-DE-POSTS-APP.md` no projeto AURUM EDITS):

1. Sobe cada arquivo final como asset do artifact.
2. Grava um documento por peça em `posts/<DD-MM>_<NN>`:

```json
{"num": 4, "nome": "04_EBENEZER_TRAILER_1080X1920", "filme": "Ebenezer e os Fantasmas do Natal",
 "tipo": "VIDEO", "lote": "11.11",
 "legenda_celular": "...", "legenda_pc": "...",
 "arquivos": [{"id": "<asset>", "url": "/_blob/<asset>", "nome": "04_EBENEZER_TRAILER_1080X1920.mp4", "kind": "video"}],
 "dia": "", "postado": false, "postadoEm": null}
```

O dia fica em branco: quem define e marca como postado é o Rubão, direto no app.
