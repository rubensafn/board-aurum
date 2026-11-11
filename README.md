# AURUM · Fila de Posts

Board de controle de postagem do AURUM Cinema (board.aurumcinema.com.br). Cada post do lote vira um card com prévia, legenda (CELULAR / PC) com botão de copiar, botão de baixar, dia e "marcar como postado". Filtro por dia no topo. Funciona no celular e no PC.

- **Front:** `index.html` (página única, sem build), publicada pela Vercel a partir deste repo.
- **Dados:** Supabase, projeto `aurum_db_dev` — tabela `fila_posts` (fechada: só funções RPC com a senha da fila), bucket público `fila-posts` (caminhos aleatórios), Edge Function `fila-admin` (upload assinado, gravação de posts e limpeza).
- **Limpeza:** 3 dias depois de marcado como postado, o vídeo sai do Supabase (o card e a legenda continuam). Limite do plano grátis: 50 MB por arquivo, 1 GB no total.
- Não mexe em nada do sistema de cortesias, que usa o mesmo projeto.

## Subir um lote
```
FILA_TOKEN=<token> python3 tools/fila_push.py lote.json
```
Formato do `lote.json` no topo de `tools/fila_push.py`. O dia e o "postado" ficam com o Rubão, direto no board.
