# AURUM · Fila de Posts

Board de controle de postagem do AURUM Cinema (board.aurumcinema.com.br). Cada post do lote vira um card com prévia, legenda (CELULAR / PC) com botão de copiar, botão de baixar, dia e "marcar como postado". Filtro por dia no topo. Funciona no celular e no PC.

- **Front:** `index.html` (página única, sem build), publicada pela Vercel a partir deste repo.
- **Dados:** Supabase, projeto `aurum_db_dev` — tabela `fila_posts` (fechada: só funções RPC com a senha da fila), bucket público `fila-posts` (caminhos aleatórios), Edge Function `fila-admin` (upload assinado, gravação de posts e limpeza).
- **Histórico:** nada sai do banco. A lixeira do card e o APAGAR TODOS (aba Postados) só arquivam (`arquivado = true`): somem do board, mas a linha fica (filme, legenda, quando postou, link do IG) pra varredura agendada saber o que já foi baixado/postado. A lixeira também tira os arquivos do storage na hora. Um gatilho no banco (`fila_posts_nao_apaga`) transforma qualquer DELETE em arquivar; apagar de verdade só com `set local fila.apagar_de_vez = 'on';`.
- **Limpeza:** 3 dias depois de marcado como postado, o vídeo sai do Supabase (o card e a legenda continuam). Limite do plano grátis: 50 MB por arquivo, 1 GB no total.
- Não mexe em nada do sistema de cortesias, que usa o mesmo projeto.

## Subir um lote
```
FILA_TOKEN=<token> python3 tools/fila_push.py lote.json
```
Formato do `lote.json` no topo de `tools/fila_push.py`. O dia e o "postado" ficam com o Rubão, direto no board.

## Edge Function `fila-admin` (código fica AQUI)
- Fonte: `supabase/functions/fila-admin/index.ts`. **Sempre** editar a partir deste arquivo e commitar antes/junto do deploy — nunca publicar uma versão que não está no repo (já se perdeu uma versão assim).
- Antes de mexer: `git pull` e conferir se o arquivo bate com a versão no ar (Supabase → get_edge_function).

## Postagem automática
- pg_cron `fila-publicar` roda **a cada minuto**. O container do Instagram é criado até 15 min antes; publica no minuto marcado (card mostra PRONTO · SAI HH:MM).
- Erro do Instagram: tenta de novo sozinho 1x; se falhar, card mostra NÃO POSTOU + motivo + TENTAR DE NOVO / MUDAR HORÁRIO, e chega aviso no celular (app ntfy, tópico em `fila_config.notify_url`). Story com erro: TENTAR O STORY DE NOVO.
- Lixeira do board usa a RPC `fila_apagar` (mesma senha do `fila_list`); arquivos saem na limpeza (`cleanup`).
