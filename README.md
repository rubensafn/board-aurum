# AURUM · Fila de Posts

> **Antes de qualquer coisa, leia no projeto AURUM EDITS (claude.ai) os docs `claude/FILA-DE-POSTS-APP.md` (board) e `claude/AUTO-POSTAGEM-AURUM.md` (varredura)** — regras do Rubão, o que está no ar e as pendências ficam SÓ lá (lugar único, 18/11). Este repo guarda o código e uma cópia de segurança dos docs (`docs/`) e do banco (`supabase/banco/`) — ver ESTADO.md.


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
- **Sem consulta periódica** (banco grátis: a consulta a cada minuto travou o banco em 16/11). Ao aprovar/mudar horário/TENTAR DE NOVO, o gatilho `fila_posts_agenda` agenda no pg_cron só 3 toques do post: 15 min antes (prepara), na hora (publica) e +2 min (Story/conferência). Cada toque (`fila_toque_AAAAMMDDHHMI`) chama a fila-admin e se apaga. Se o Instagram ainda estiver processando, a função agenda mais 1 toque em 2 min (`fila_tocar_em`). NUNCA voltar pra cron de minuto em minuto sem falar com o Rubão.
- Erro do Instagram: tenta de novo sozinho 1x; se falhar, card mostra NÃO POSTOU + motivo + TENTAR DE NOVO / MUDAR HORÁRIO, e chega aviso no celular (app ntfy, tópico em `fila_config.notify_url`). Story com erro: TENTAR O STORY DE NOVO.
- Lixeira do board usa a RPC `fila_apagar` (mesma senha do `fila_list`); arquivos saem na limpeza (`cleanup`).

## Legenda pelo board
- Painel da legenda: **EDITAR** (salva na hora, RPC `fila_set_legenda`, sem Claude) e **NOVA LEGENDA** (RPC `fila_pedir_legenda`, com instrução opcional). O pedido fica em `legenda_refazer`/`legenda_pedido` e a varredura agendada (11h22, 15h22, 18h22) reescreve. Trava quando o post já está indo pro Instagram.

## v43 (18/11/2026)
- **Avisos de baixo** maiores, borda dourada (vermelha quando é erro), 4 s na tela (com botão DESFAZER 8 s).
- **+ NOVO POST** (botão dourado no topo no PC; botão redondo dourado no celular): sobe arquivo próprio (até 50 MB cada, vários = carrossel), filme, onde posta, legenda ou GERAR LEGENDA (a varredura escreve), dia/horário opcional e **selo AU ✓/✗ obrigatório**. Entra em PENDENTES (`subido=true`). Com ✓ fica `selo_pendente=true`: **a varredura precisa aplicar o selo** (fase 3, ainda não está no texto da varredura).
  Upload: edge `fila-admin` ação `upload_sign` (senha da fila) → pasta `manual/` do bucket → RPC `fila_novo_post`.
- **FILMES** (botão ciano no topo): tabela `fila_filmes`. Só puxa do site (`aurumcinema.com.br/api/programacao` e `/api/upcoming`) quando o Rubão abre a aba (máx. 1x a cada 10 min). Filme novo entra marcado; marcado/desmarcado pelo Rubão NUNCA muda por causa do site. A varredura vai seguir `ativo` (fase 3).
- Abas no celular abreviadas: PEND · APROV · POST.
- **Regra dev/main:** toda mudança vai pra dev E main juntas. Só fica só na dev quando o Rubão avisar que é mudança grande pra ver antes.
