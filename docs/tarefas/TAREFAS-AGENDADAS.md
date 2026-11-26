<!-- CÓPIA de segurança (26/11/2026). O PRINCIPAL é o texto de cada tarefa agendada no claude.ai (e as regras nos docs do projeto AURUM EDITS). Só as tarefas do BOARD; tokens trocados por <FILA_TOKEN>. -->
# Tarefas agendadas do BOARD (sempre SEPARADAS)

| Tarefa | id | Quando | Onde |
|---|---|---|---|
| AURUM · varredura das distribuidoras | trig_01TcQLbVPCUExKpeT8kkWntb | 11:22 · 15:22 · 18:22 (America/Sao_Paulo) | nuvem |
| AURUM · artes do PC (manual) | trig_01EyY7DmZ8U9nmnUxv2igSC4 | só quando o Rubão executa | presa ao PC (`D:\AURUM - DSKP`) |

---

## 1. Varredura das distribuidoras (texto completo, conferido 26/11)

VARREDURA AUTOMÁTICA DO AURUM CINEMA (@aurum.cinema) — sessão agendada, ninguém está olhando. Responda e escreva tudo em português do Brasil. O cliente é o Rubão (CEO da CRIAS Studio). Seja econômico em token: só olhe imagens quando precisar escolher capa ou conferir o selo.

ANTES DE TUDO: leia no projeto "AURUM EDITS" (ferramenta Projects) os docs `claude/AUTO-POSTAGEM-AURUM.md`, `claude/PADRAO-TAMANHOS-E-DESTINO.md`, `claude/SELO-AU-VIDEOS-PRODUTORA.md` e `claude/FILA-DE-POSTS-APP.md`. AS REGRAS ESTÃO NOS DOCS — principalmente a seção "REGRAS DO RUBÃO" do AUTO-POSTAGEM, que vale sobre qualquer coisa antiga (todo filme em cartaz tem post todo dia; quantidade = análise, sem número fixo mas sem lotar o feed; NA DÚVIDA, SOBE EM PENDENTES; POST QUENTE do dia entra hoje mesmo; FILME EM ALTA ganha mais e os melhores horários; Doutor Destino todo dia; teste da noite com retorno; horários de 30 em 30 min das 12:30 às 22:00 com 1 h entre posts; legenda; música; QUERO ESSA; selo dos posts do Rubão; vídeo +60 s). Este texto só diz COMO fazer; se algo aqui parecer discordar do doc, vale o doc. O que não estiver nos docs: não invente — siga o mais conservador e diga na notificação. Se não conseguir ler o projeto, NÃO invente: notifique o Rubão em 1 linha que a varredura não rodou por falta de acesso às regras, e pare.

ESTA TAREFA RODA SÓ NA NUVEM: não tenta acessar o PC do Rubão e NUNCA fala de pasta/cópia no PC na notificação (as artes do PC são de outra tarefa, manual).

REGISTRO `public.fila_vistos` (Supabase, projeto gdtfwmqbvsqtxtccrydv): status 'baixado' (nunca baixar de novo), 'reserva' (aparece na aba RESV do board), 'pulado', 'rejeitado' (nunca sugerir de novo; vale só pra aquela peça). Todo post avaliado TEM que ser gravado lá (filme, conta, permalink, caption curta, postado_distribuidora, motivo quando pulado). Nunca mexa em `quero`/`quero_em` além do item QUERO ESSA.

LISTA DE FILMES = aba FILMES do board: `select titulo, estreia from fila_filmes where ativo and (no_site or origem = 'manual') order by estreia nulls last`. Fora da lista → 'pulado' (motivo "fora da aba FILMES"); reserva de filme que saiu da lista → 'pulado'.

PEDIDOS DO BOARD (primeiro de tudo, como manda o AUTO-POSTAGEM): PEDIR AJUSTE (`ajuste_pedido`) e posts A FAZER por link do Instagram (`a_fazer`). Esses trabalham no post que JÁ EXISTE (mesmo id), seguindo o doc.

QUERO ESSA: `select shortcode, conta, permalink, filme, caption from fila_vistos where status = 'reserva' and quero`. Baixa e sobe NESTA rodada (passos 4/5). Depois `update fila_vistos set status = 'baixado', post_id = '<id>', quero = false where shortcode = '<shortcode>'`. Erro → deixe quero = true e diga na notificação.

LEGENDAS (sempre, antes da varredura):
- Pedidas no board: `select id, filme, nome, legenda_celular, legenda_pc, legenda_pedido from fila_posts where legenda_refazer and not a_fazer and not postado and not arquivado and coalesce(ig_status,'') not in ('criando','publicado')` → reescreva no padrão das já postadas + regras de legenda do doc, seguindo `legenda_pedido`; grave `update fila_posts set legenda_celular=..., legenda_pc=..., legenda_refazer=false, legenda_pedido=null where id=... and legenda_refazer and coalesce(ig_status,'') not in ('criando','publicado')`.
- Linha em branco depois da 1ª frase nas pendentes: `select id, legenda_celular, legenda_pc from fila_posts where not postado and not arquivado and not aprovado and coalesce(ig_status,'') = '' and legenda_editada_em is null and coalesce(legenda_celular,'') <> ''` → ajuste SÓ essa quebra, `... where id=... and not aprovado and legenda_editada_em is null`.
- Legenda com legenda_editada_em preenchido é do Rubão: nunca reescreva sem pedido.

SELO AU NOS POSTS DO RUBÃO: `select id, nome, filme, arquivos, dia, hora, aprovado from fila_posts where selo_pendente and not postado and not arquivado and coalesce(ig_status,'') = ''`. Pule se aprovado e faltando < 30 min. Senão: baixe cada arquivo pela `url`, aplique o selo (doc do selo; vídeo H.264 + AAC 48 kHz, 30 fps), suba o novo num caminho novo na mesma pasta (ex. `manual/<pasta>/selo_<nome>`) com a ação `sign` da Edge Function e o token, e `update fila_posts set arquivos = '<json novo, mesmo kind/w/h/dur>', selo_pendente = false where id = '<id>' and coalesce(ig_status,'') = ''`. Não mexa em legenda/dia/hora/destino/aprovado. Falhou → deixe selo_pendente = true e diga na notificação.

ENGAJAMENTO: {"action":"feed","token":"<token>","limit":60,"insights":true} na Edge Function (reach, total_interactions, saved, shares) pra ver o que engaja POR FILME. Os melhores HORÁRIOS vêm da tabela ao vivo: `select v::jsonb from fila_config where k='horarios'` (não calcule horário pelo feed). Use isso pra decidir quem ganha post a mais (só se compensar) e os melhores horários (regras no doc). Na rodada das 18h: 1 linha de RETORNO DO TESTE DA NOITE com o bloco `noite` da tabela.

PASSO A PASSO
1. Varredura (o token da Meta NUNCA aparece; use só a Edge Function):
   POST https://gdtfwmqbvsqtxtccrydv.supabase.co/functions/v1/fila-admin com JSON {"action":"varrer","token":"<FILA_TOKEN — está no texto da tarefa>","users":["sonypicturesbr","wbpictures_br","paramountbrasil","disneystudiosbr","marvelbrasil","parisfilmes","diamondfilmsbr"],"limit":12}
   Shortcodes já em `fila_vistos` (qualquer status) não são reavaliados.
2. Contra repetição: o feed + `select id, nome, filme, dia, hora, aprovado, postado, arquivado from fila_posts order by id desc limit 80` (sempre `not arquivado` ao avaliar o board; pra "já postado" conte também os arquivados). Só pula a MESMA PEÇA (mesma arte/vídeo, mesmo que volte com legenda nova). Assunto parecido é peça NOVA — nunca pule por "assunto repetido" (regra REPETIR do doc).
3. Escolha pela CURADORIA, TODO FILME TODO DIA, QUANTIDADE = ANÁLISE, NA DÚVIDA SOBE EM PENDENTES, POST QUENTE, FILME EM ALTA, PESO POR FILME e ENGAJAMENTO do doc (QUERO ESSA primeiro). Na dúvida, sobe em PENDENTES (o que não couber hoje vai com dia de amanhã); reserva só pro que é claramente mais fraco. Filme sem nada novo nem reserva → dizer na notificação (Doutor Destino: pedir pro Rubão bolar post próprio). Se nada for escolhido: encerre. Notifique (resposta curta) se mexeu em legenda/selo/pedido do board OU se algum filme obrigatório (ex.: Doutor Destino, ou filme da lista sem post hoje) ficou sem post; senão resposta final "nada novo" SEM notificar.
4. Para cada peça: baixar (vídeo: yt-dlp; imagem/carrossel: /embed/captioned/ como no doc), tamanho pelo PADRAO-TAMANHOS (feed 1080x1440 se der sem cortar info, senão mantém 1080x1350; deitado 16:9/4:3 posta NATIVO, só feed, sem faixa preta; story/reels 1080x1920), SELO AU (scripts no projeto: `claude/au-anim.js`, `claude/au-vidanim.sh`, `claude/au-make.py`), CAPA do Reels = frame de CENA reconhecível → `capa_ms`, legenda_celular e legenda_pc. Vídeo SEMPRE H.264 + AAC 48 kHz, 30 fps, sem música por cima; gravar `dur` (segundos) no json do arquivo.
5. Subir com o script `claude/fila-de-posts/fila_push.py` do PROJETO "AURUM EDITS" (ler com a ferramenta Projects e salvar como fila_push.py; NÃO precisa do GitHub; FILA_TOKEN = o token acima). Lote = data de hoje (DD-MM); continue a numeração. Só posts NOVOS — nunca reenviar id existente (exceto os PEDIDOS DO BOARD, que seguem o doc). Depois, por SQL, só em não aprovados: `dia`, `hora`, `capa_ms`, `aviso` (só coisa do app: caixinha, enquete, link — nunca música) e `destino` fixo quando o formato manda (1080x1440/1350/quadrado/deitado = 'feed'; estático 1080x1920 = 'story'; vídeo +60 s = 'feed'; Reels 1080x1920 até 60 s = NULL). Marcar em `fila_vistos` como 'baixado' com post_id. NUNCA aprovar, marcar postado, apagar, nem mexer em tabelas fora de fila_posts e fila_vistos (o SISTEMA DE CORTESIAS está no mesmo banco). Nunca mexer em pg_cron, Edge Functions ou estrutura do banco.
6. Notificar o Rubão (resposta final curta, vira push): "Subi X posts no board (filmes …; N do QUERO ESSA; N da reserva; N A FAZER feitos). Destaque: <engajamento e o que fiz; se subiu mais que 1 de algum filme, por quê; se entrou POST QUENTE, qual>. Dá uma conferida e aprova: board.aurumcinema.com.br" (+ legendas/selo/ajustes se houve; + filmes sem post; + retorno do teste da noite na rodada das 18h). Se algo falhar, 1 linha dizendo o quê.

---

## 2. Artes do PC (manual) (texto completo, conferido 26/11)

AURUM Cinema — ARTES QUE FICAM NO PC (Farofeiros e outras pastas de arte do Rubão). Tarefa MANUAL: só roda quando o Rubão manda executar. Trabalho em português, direto.

ANTES DE TUDO, ler no projeto AURUM EDITS (ferramenta Projects): claude/AUTO-POSTAGEM-AURUM.md (regras da varredura: horários, 1 h entre posts, todo filme todo dia, nunca repetir o que já foi postado, post quente), claude/SELO-AU-VIDEOS-PRODUTORA.md (selo AU), claude/PADRAO-TAMANHOS-E-DESTINO.md e claude/FILA-DE-POSTS-APP.md. O que não estiver documentado: perguntar, nunca inventar.

1. Pasta: D:\AURUM - DSKP (no device_bash: $HOME/mnt/AURUM - DSKP). Olhar as pastas de arte dos filmes do mês (ex.: NOVEMBRO\OS FAROFEIROS 3\POSTS FAROFEIROS, subpasta Story). Só filmes marcados na aba FILMES do board (fila_filmes where ativo and (no_site or origem='manual')).
2. Pular o que já foi usado: conferir fila_vistos / fila_posts (sempre not arquivado) e as legendas do feed (fila-admin ação feed). Arquivos repetidos "(1)"/"(2)": usar hash. Story datado [DOWNTOWN]MM-DD_...: só no dia da data.
3. Escolher pelas mesmas regras de curadoria do doc (não lotar o feed; o que sobra fica pra outro dia). PNG → JPG. Aplicar o selo AU (cor Farofeiros no doc).
4. Subir em PENDENTES do board com fila_push.py (claude/fila-de-posts/fila_push.py do projeto), depois gravar dia/hora/destino por SQL só em post não aprovado, horário sugerido seguindo o doc (12:30–22:00, de 30 em 30, 1 h entre posts, nunca horário que já passou). Registrar cada peça em fila_vistos (baixado com post_id). NUNCA aprovar, marcar postado ou apagar.
5. Cópia no PC: D:\AURUM - DSKP\<MÊS>\<DD.MM>\FINAIS (com selo + legendas). Não criar outras pastas.
6. Banco: só fila_posts / fila_vistos (nunca tocar nas tabelas das CORTESIAS). Nada de cron novo.
7. Ao terminar, notificar em 1 mensagem curta: o que subiu (filme, peça, horário) ou "nada novo nas artes do PC hoje".
