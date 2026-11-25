<!-- CÓPIA de segurança — o PRINCIPAL é o doc claude/FILA-DE-POSTS-APP.md do projeto AURUM EDITS (claude.ai). Editar lá, não aqui. -->
# BOARD AURUM (board.aurumcinema.com.br) — ESTADO + REGRAS (LUGAR ÚNICO)

**ESTE DOC (projeto AURUM EDITS) É O LUGAR PRINCIPAL DAS REGRAS E DO ESTADO DO BOARD.** Regras da varredura/postagem: `claude/AUTO-POSTAGEM-AURUM.md`. Toda conversa nova lê os dois antes de mexer. Toda mudança termina atualizando AQUI. O CÓDIGO (index.html, edge function, tools) tem o principal no GitHub `rubensafn/board-aurum` (a Vercel publica de lá). O GitHub guarda também uma CÓPIA de segurança dos docs em `docs/` (ver Sincronização).

Atualizado em: 25/11/2026 — board **v65** (commit d0f963e), edge `fila-admin` **v20**.

## 1. Regras do Rubão (não quebrar)

**Como trabalhar**
- Responder curto, em português, exatamente o que ele perguntou. Pergunta ≠ pedido pra mexer. Se ele mandou parar, para.
- Antes de mudar como algo funciona (agendamento, frequência, banco, varredura, estrutura): explicar o que muda, o risco e o custo, esperar o OK.
- Antes de afirmar algo sobre o código: conferir no código. Nunca responder de cabeça.
- **NUNCA inventar regra, número ou horário.** O que não está documentado AQUI ou no AUTO-POSTAGEM: PERGUNTAR. Regra nova entra no doc certo NA HORA.
- Antes de mexer: `git pull` e conferir a versão no ar da edge (`list_edge_functions` → version). Edge: sempre editar a partir de `supabase/functions/fila-admin/index.ts` do repo e commitar junto do deploy (`verify_jwt: false`, arquivo único `index.ts`).
- Ordem: board primeiro; texto da varredura por último; mexer na tarefa só entre rodadas (11:22 · 15:22 · 18:22).
- Pente fino = relatório antes de mexer. Confirmações sempre em pop-up no centro (`confirmar(titulo,texto,ok,fn,danger)`), nunca no aviso de baixo.
- Conferir no CELULAR (393 px, iPhone 14 Pro) e no PC. Classes como `.fname` ficam escondidas no celular.
- **Texto cortado com "…" sem jeito de ler = proibido.** Se não cabe, o elemento expande no lugar (o card pode crescer).
- **Texto/ícone nunca sai do botão.** Medir no Playwright `scrollWidth <= clientWidth` de todo botão em 360 e 393 antes de entregar.

**Tarefas agendadas (decidido 21/11, confirmado 25/11): SEMPRE SEPARADAS**
- Varredura das distribuidoras = NUVEM (3x/dia). Nunca "exigir este computador".
- Artes do PC (Farofeiros etc.) = tarefa MANUAL separada, sem horário (só roda quando o Rubão manda). Juntar as duas NÃO funciona (PC desligado = perde a rodada inteira).

**Branches**
- Toda mudança vai pra **dev E main juntas, no MESMO commit** (`git push origin HEAD:dev && git push origin HEAD:main`, com dev e main iguais antes). Só fica só na dev quando ele avisar.
- Push pela sessão: o repo precisa estar nas fontes da sessão (`add_repo` rubensafn/board-aurum, acesso push).

**Sincronização projeto ↔ GitHub (Rubão, 22/11 e 25/11)**
- PRINCIPAL: docs/regras = PROJETO (a varredura lê daqui); código = GitHub.
- O GitHub guarda cópia de segurança: `docs/` (docs do board/varredura/tamanhos/selo + textos das tarefas + scripts do selo), `supabase/banco/` (estrutura do banco do board, sem senha/token/cron_key e NADA das cortesias), `tools/fila_push.py` (= `claude/fila-de-posts/fila_push.py` do projeto, o mesmo arquivo).
- Sincronizar UMA VEZ no fim de cada sessão de trabalho, só o que mudou na sessão (economia de token), no mesmo commit em dev e main. Mudou o banco → atualizar `supabase/banco/` no mesmo commit. A varredura NUNCA lê o GitHub.

**Banco (Supabase gdtfwmqbvsqtxtccrydv, plano grátis, MESMO banco do sistema de CORTESIAS)**
- Nunca tocar nas tabelas das cortesias. Sempre olhar como está o banco antes de mexer.
- **Nunca** criar consulta periódica (cron de minuto em minuto etc.). Já derrubou board + cortesias em 16/11.
- pg_cron hoje: só `fila-limpar` (diário 07:17 UTC = 04:17 Brasília: limpa arquivos + recalcula a tabela de horários) + toques de um disparo por post aprovado (`fila_toque_*`, 15 min antes / na hora / +2 min).
- O board consulta `fila_list` a cada 30 s com a aba aberta.
- **Nada no board apaga linha do banco**: lixeira = arquiva + rejeita a peça (`fila_vistos`); POSTADOS → APAGAR TODOS = `fila_arquivar_postados` (só arquiva); RESV → EXCLUIR TODAS = rejeita; MANDAR PRA RESERVA = arquiva o post e a peça volta pra `reserva`. Reserva NÃO sai sozinha por idade — o Rubão limpa.
- Tirar post do board sem a senha: `update fila_posts set arquivado=true, arquivado_em=now()` (os arquivos saem na limpeza).

**Aba FILMES (`fila_filmes`)**
- Filme do site com SESSÃO (`/api/programacao`: em cartaz OU pré-venda) entra MARCADO. Só lançamento (`/api/upcoming`, sem sessão) entra DESMARCADO. Desmarcado que ganha sessão e nunca foi mexido (`mexido=false`) marca sozinho. O que ele marcou/desmarcou (`mexido=true`) NUNCA muda por causa do site.

**Visual**
- **Nada pode ficar cortado** (canto, contorno, brilho/neon, card, pop-up). Conferir 360/393 e PC em print. Página no celular só rola pra cima/baixo.
- **Pop-up no modo app do iPhone**: elemento fixo/pop-up usa `env(safe-area-inset-top/bottom)`. Simular no Playwright trocando por 59 px (topo) e 34 px (baixo).
- **Todo botão/aba colorido segue a MESMA receita de vidro (v41)**: cor forte translúcida em degradê + fundo escuro + contorno claro + neon, com **texto/ícone CLARO**. Nunca cor que obriga texto preto.
- **CORES POR SIGNIFICADO**:
  - **Roxo `#a78bfa` = ação SUA**: APROVAR, + NOVO POST, aba APROVADOS, microfone.
  - **Amarelo-laranja vivo** (`--hot` `#FFC21A`; vidro `rgba(255,204,20,.78) → rgba(255,140,0,.52)` sobre `#160e02`, contorno `#FFE082`, texto `#fff8e1`) = PENDENTE / HOJE / COPIAR.
  - **Laranja `#FF8A1F` = atenção forte / pede ação sua**: ATRASO, avisos do card (VOCÊ POSTA, "Só FEED · story à mão").
  - **Vermelho `#FF3B3B` = apagar / erro**.
  - **Verde `#4ade80` = postado / ok** (aviso de baixo de sucesso).
  - **Ciano `#67e8f9` = baixar, ATUALIZAR, RESERVAS, FEED, COMPRIMIDO, FILMES, HORÁRIOS, MANDAR PRA RESERVA, A FAZER (info)**.
  - **Magenta `#FF3FD2` = arte**: PEDIR AJUSTE, etiqueta STORY, box "PRODUTORA — data".
  - Contorno em degradê (ouro→rosa→roxo→ciano) é da marca. AU branco.
- **Ícones**: traço claro (lucide, stroke 2), sem preenchimento grande. Testar no tamanho real.
- **Ícone do app**: AU do mesmo tamanho/posição do ícone do Cortesias (~52% da largura), sem brilho interno.
- Abas: PENDENTES amarelo-laranja · RESERVAS ciano · APROVADOS violeta · POSTADOS verde.
- **Cards: altura FIXA e igual pra todos** (276 px celular / 330 px PC). Exceções que crescem: card com erro ABERTO (LER) e card A FAZER. Pílulas (`.meta`) quebram em 2 linhas. Não usar a classe genérica `.on` em botão novo.

## 2. O que existe hoje (no ar)
- `index.html` — board inteiro (HTML/CSS/JS num arquivo). Camadas de CSS por versão no fim do `<style>` (… v62, v63, v64/v65 no final).
- `manifest.webmanifest` + `icons/` — modo app no celular ("Board AU", sem service worker).
- Abas: PENDENTES · RESERVAS · APROVADOS · POSTADOS (celular: PEND · RESV · APROV · POST). Topo: HORÁRIOS (some abaixo de 375 px; a mesma tabela aparece no pop-up de horário do card), FILMES, + NOVO POST, SAIR.
- **Card**: capa + número + filme + box PRODUTORA (data em que a distribuidora postou, quando o post veio da varredura) + DIA + HORÁRIO + destino + status do Instagram + avisos + prévia da legenda + APROVAR + copiar / baixar / PEDIR AJUSTE / postado / MANDAR PRA RESERVA (só pendente que veio da varredura) / lixeira.
- **Horários**: botões 12:30 · 15:00 · 17:30 · 20:30 · 21:30 (TESTE) + OUTRO HORÁRIO. Etiquetas e barras vêm da TABELA AO VIVO (`fila_config.horarios`, RPC `fila_horarios`; se não carregar, usa a fixa `HDADOS` de 14/11). Pop-up HORÁRIOS no topo: Reels, Estático e TESTE DA NOITE (7 dias). Faixa com menos de 5 posts aparece apagada.
- **+ NOVO POST**: dois modos.
  - ARTE PRONTA: arquivo próprio, filme, onde posta, legenda ou GERAR LEGENDA, dia/hora, selo AU ✓/✗ → PENDENTES.
  - LINK DO INSTAGRAM (v65): link do post + O QUE QUERO (texto ou microfone — reconhecimento de voz do navegador, pt-BR; sem suporte, usa o microfone do teclado) + SEGUIR NOSSO PADRÃO (vem marcado) + filme + onde posta (opcional) + legenda/GERAR + dia/hora → card A FAZER em PENDENTES. A próxima varredura baixa e faz (regra no AUTO-POSTAGEM). Não dá pra aprovar enquanto A FAZER (trava no banco).
- **Avisos de baixo (v65)**: pílula grande acima da barra do iPhone, contorno e brilho fortes na cor do significado (verde ok, vermelho erro, amarelo atenção), barrinha de tempo; 3,5 s (DESFAZER 6 s, erro 5 s).
- Vídeo +60 s: card mostra "Só FEED · story à mão" (a API só aceita story até 60 s). Sem corte automático (Rubão, 25/11).
- `supabase/functions/fila-admin/index.ts` — edge v20. Ações: sign/upsert/varrer/feed/set_meta (token), publicar (cron_key), delete/cleanup/upload_sign/filmes/reservas (senha). `cleanup` com cron_key também recalcula `fila_config.horarios` (90 dias, sem programação; nunca com a senha do board).
- Tabelas: `fila_posts` (+ `subido`, `selo_pendente`, `manual`, `ajuste_pedido`, `ajuste_em`, `ajuste_resposta`, `a_fazer`, `link_origem`, `pedido_arte`, `seguir_padrao`), `fila_filmes` (+ `mexido`), `fila_config`, `fila_vistos` (+ `quero`, `quero_em`, `postado_distribuidora`).
- RPCs (senha): `fila_list` (traz `postado_distribuidora` e `tem_peca` do `fila_vistos`), `fila_set_*`, `fila_novo_post`, `fila_novo_link`, `fila_mandar_reserva`, `fila_horarios`, `fila_filmes_list`, `fila_filme_set/add/del`, `fila_reservas_list`, `fila_reserva_quero`, `fila_reserva_rejeitar`, `fila_reservas_excluir_todas`, `fila_apagar`, `fila_set_legenda`, `fila_pedir_legenda`, `fila_pedir_ajuste`. Gatilhos: `fila_posts_agenda`, `fila_posts_nao_apaga`, `fila_posts_trava_afazer`.

## 3. Pendências
- 4 rodadas (12h, 15h, 18h, 21h): só quando o Rubão mandar.
- Conferir com o Rubão no iPhone: v64/v65 (horários ao vivo, pop-up HORÁRIOS, RESERVA, PRODUTORA nos cards, avisos novos, + NOVO POST por link e microfone no modo app).
- 1º post A FAZER de verdade: conferir que a varredura fez certo.
- Vídeo deitado 16:9: confirmar que a API da Meta publica.
- Capa com selo AU: implementar `cover_url` no `fila-admin`.
- Teste da noite fecha ~28/11 → resumo pro Rubão.
- Medir custo de 1 rodada da varredura (Configurações → Uso, antes/depois).
- Ideias guardadas (ele ainda não pediu): marcar vários de uma vez; link sem senha pro cliente só ver/aprovar.

## 4. Como testar visual sem a senha
Playwright com dados falsos: `add_init_script` com `localStorage fila_sess = {pin:'x', exp: agora+1h}` e `fila_view`; interceptar `*supabase.co/**` — RPCs devolvem listas, `fila_horarios` devolve o json da tabela, a edge devolve `{}` (ou `{reservas:[…]}`). Print 360/393 (`is_mobile`, `has_touch`) e 1280 com `device_scale_factor=2`. Script de auditoria: mede `scrollWidth>clientWidth` em todo `button/[data-act]` e rolagem lateral.

## 5. Referência
- Board: **https://board.aurumcinema.com.br** (Vercel, deploy automático do GitHub). Pede senha; sessão de 8 horas. A senha o Rubão tem; não guardar aqui. Trocar: `update public.fila_config set v = extensions.crypt('<nova>', extensions.gen_salt('bf')) where k='pin_hash'`.
- Ele quer oferecer o board pra outros clientes: logo e cores num bloco "TEMA DO CLIENTE" no CSS (+ constante AU); ícone/manifest também são do cliente.
- **REGRA GERAL**: TUDO que ele aprovar sobe no board (campanhas, artes próprias, vídeos). Exceção: stories que ele posta à mão e programação/foyer.
- **POSTAGEM MANUAL**: `fila_posts.manual` = o robô NUNCA posta; card mostra "VOCÊ POSTA" e "JÁ POSTEI".
- Estrutura: `arquivos` = lista de `{path, url, poster, w, h, nome, kind, dur?}`. Bucket público `fila-posts` (máx. 50 MB por arquivo). Caminho FIXO `<DD-MM>/<DD-MM>_<num>/<arquivo>` (o fila_push sobrescreve a versão anterior: mesmo post, sem arquivo sobrando); + NOVO POST em `manual/`. Limites do grátis: 1 GB, ~5 GB/mês de tráfego.

## 6. Como subir lote (selo AU e varredura)
1. `lote.json`: `{"lote": "DD-MM", "posts": [{"num","nome","filme","tipo": "POST"|"CARROSSEL"|"VIDEO","legenda_celular","legenda_pc","comprimido","files": ["/caminho"]}]}`.
2. `FILA_TOKEN=<FILA_TOKEN — está no doc do projeto> python3 fila_push.py lote.json` (script `claude/fila-de-posts/fila_push.py` do projeto = `tools/fila_push.py` do GitHub). Precisa de ffmpeg/ffprobe.
3. Depois, por SQL (o push não manda): `dia`, `hora`, `aviso`, `capa_ms`, `destino` quando for fixo; `dur` no json do vídeo.
4. Arquivo > 50 MB: cópia de ~46 MB marcada `"comprimido": true`.
Alteração de arte: mesmo lote+num+nome → substitui. Não apagar nem mexer em dia/postado sem ele pedir.
Entrega de lote feito em conversa: (1) subir no board, (2) mandar no chat cada arquivo, (3) mandar o ZIP. Cópia no PC em `D:\AURUM - DSKP\<MÊS>\<DD.MM>\BAIXADOS|FINAIS`.

## 7. Direção visual — não mexer sem ele pedir
- ESCURO e minimalista, neon como identidade. Fundo com luz colorida difusa + grão + vinheta.
- Vidro só em navegação e botões; nunca brilho que corta/vaza; nada de glow branco.
- Cinzel em títulos/rótulos, Inter no texto.
- Topo: AU volta pro topo; aba ativa com marcador que desliza; troca de aba desliza; recarregar mantém a aba. Todos os painéis abrem como pop-up no meio da tela, fundo travado. Celular: bolinha do calendário (filtro por dia) e + NOVO POST; puxar pra atualizar (bolinha ciano).
