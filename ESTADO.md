# ESTADO DO BOARD — ONDE FICA CADA COISA (atualizado 25/11/2026)

**O PRINCIPAL das regras e do estado é o projeto AURUM EDITS (claude.ai, ferramenta Projects)** — a varredura lê de lá:
- `claude/FILA-DE-POSTS-APP.md` — regras do Rubão, o que está no ar, pendências do BOARD.
- `claude/AUTO-POSTAGEM-AURUM.md` — regras da VARREDURA e da postagem automática.
- `claude/PADRAO-TAMANHOS-E-DESTINO.md` e `claude/SELO-AU-VIDEOS-PRODUTORA.md`.

**Este repositório guarda:**
- O CÓDIGO (principal aqui): `index.html`, `supabase/functions/fila-admin/index.ts`, `tools/fila_push.py` (igual ao `claude/fila-de-posts/fila_push.py` do projeto).
- CÓPIA DE SEGURANÇA (pra puxar se algo quebrar no projeto): `docs/` (docs acima, textos das tarefas agendadas em `docs/tarefas/`, scripts do selo em `docs/selo/`) e `supabase/banco/fila_estrutura.sql` (estrutura do banco do board, sem senhas/tokens e sem nada das cortesias).

Sincronização: uma vez no fim de cada sessão de trabalho, só o que mudou, no mesmo commit em dev e main. Editar sempre no projeto, nunca nas cópias daqui. Tokens/senhas nunca entram no repositório.
