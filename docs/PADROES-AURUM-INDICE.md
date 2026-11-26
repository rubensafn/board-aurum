<!-- CÓPIA de segurança — o PRINCIPAL é claude/PADROES-AURUM-INDICE.md do projeto AURUM EDITS. Editar lá. -->
# ÍNDICE DE PADRÕES — AURUM EDITS (LER PRIMEIRO)

Este projeto guarda os padrões fixos dos trabalhos do AURUM Cinema. Antes de começar qualquer pedido, identificar o tipo abaixo e LER o doc indicado (project_read). Os padrões não mudam de semana pra semana: só troca o conteúdo. Vale pra qualquer conversa do projeto, inclusive no Sonnet.

**UM DOC POR ASSUNTO (Rubão, 25/11):** cada assunto tem um doc só (board = FILA-DE-POSTS-APP, varredura = AUTO-POSTAGEM, selo = SELO-AU-VIDEOS-PRODUTORA, tamanhos = PADRAO-TAMANHOS-E-DESTINO…). Sempre atualizar o doc do assunto NO MESMO ARQUIVO, guardando só o que vale HOJE (estado + pendências ficam nele). NUNCA criar doc por dia, por lote ou por conversa (passagem, plano do dia, lote de data) — isso deixou docs velhos contradizendo os atuais. Doc novo só pra assunto novo, e entra nesta tabela.

**ASSUNTOS SEPARADOS (Rubão, 26/11) — nunca misturar:** (1) BOARD + posts das produtoras (varredura, selo AU) — o GitHub `board-aurum` é SÓ disso; (2) PROGRAMAÇÃO REGULAR (com horários); (3) PROGRAMAÇÃO TEMPORADA ÁUREA (até 15/12); (4) PROGRAMAÇÃO V2 (layout novo das redes, pós-Áurea). Programação nunca vai pro GitHub nem vira regra no doc do board; quando ele pede "sobe no board", é só subir aquele post. Filme/campanha (ex. Doutor Destino) não dá nome a padrão de programação.

## Qual doc ler pra cada pedido
| Pedido do Rubão | Doc |
|---|---|
| **"Programação normal"** = SEMPRE o layout padrão com os horários (vertical → horizontal, feed, foyer, com datas e horários). É o que sempre vai ser feito. | `claude/PADRAO-PROGRAMACAO-SEMANAL.md` (+ kit `claude/kit-prog-regular/`) |
| Programação da **campanha Temporada Áurea** (stories/feed com ESTREIA / ÚLTIMA SEMANA / sem selo, R$28). É CAMPANHA: acaba em 15/12/2026 e NÃO muda até acabar. | `claude/PADRAO-STORIES-TEMPORADA-AUREA.md` (+ kit `claude/kit-temporada-aurea/`) |
| **PROGRAMAÇÃO V2** — layout novo das redes (pós-Áurea, pra qualquer filme; base aprovada em 25/11 com uma peça de pré-venda) | `claude/PADRAO-PROGRAMACAO-V2.md` (+ template `claude/kit-redes-v2/`) |
| Campanha **Vingadores: Doutor Destino** (peças específicas do filme) | `claude/VINGADORES-DOUTOR-DESTINO-CAMPANHA.md` |
| **Varredura da programação** (tarefa agendada toda QUARTA 16h que gera a regular + a Temporada Áurea sozinha) e **selos/sinopse do site** | `claude/VARREDURA-PROGRAMACAO-QUARTA.md` |
| **Varredura das distribuidoras / auto-postagem** (tarefa na nuvem 11:22/15:22/18:22 + tarefa manual das artes do PC — SEMPRE separadas) | `claude/AUTO-POSTAGEM-AURUM.md` |
| Posts/vídeos/carrosséis diários que ele baixa da distribuidora e só leva o **selo AU** na cor do filme + legendas (doc ÚNICO do selo: regras, posições, cores por filme) | `claude/SELO-AU-VIDEOS-PRODUTORA.md` (script `claude/au-make.py`, animação `claude/au-anim.js` + `claude/au-vidanim.sh`) **+ depois de entregar, jogar o lote na FILA DE POSTS: `claude/FILA-DE-POSTS-APP.md`** |
| Mexer no app **FILA DE POSTS / BOARD** | `claude/FILA-DE-POSTS-APP.md` (código no GitHub `rubensafn/board-aurum`; o GitHub guarda também cópia de segurança dos docs DO BOARD — o principal é o projeto) |
| Tamanho, destino (feed/story), capa | `claude/PADRAO-TAMANHOS-E-DESTINO.md` |
| Vídeo "chegue 30 min antes" da Temporada Áurea | `claude/AURUM-TEMPORADA-AUREA-30MIN.md` |
| **VT de TV** (Temporada Áurea, 5s, sem áudio, 1920x1080) | feito 24/11: Jogos Vorazes, 2 pôsteres + letreiro Áurea + R$28 + logo do filme + rodapé AURUM; arquivo `VT_TEMPAUREA_JOGOS_VORAZES_5S_1920X1080.mp4` |
| Vídeo de como chegar / mapa 3D | `claude/AURUM-COMO-CHEGAR-MAPA-3D.md` |
| Aftermovie de sessão (ex. Sessão Unimed) — "Modelo 1" | `modelo1/MODELO-1-AFTERMOVIE.md` |
| **Confraternização de Natal 2026** (campanha interna: vídeo motivacional scope, convite, identidade, peças impressas) | `claude/CONFRATERNIZACAO-2026.md` |
| Ferramentas de vídeo / transcrição | `claude/KIT-EDICAO-VIDEO.md`, `claude/setup-video-kit.sh`, `claude/transcribe-local.py` |

## Regras gerais (valem pra tudo)
- **ARQUIVOS DO PC (Rubão, 24/11):** quando o pedido precisar de arquivo do PC dele (kit da Áurea, Downloads etc.) e a pasta não estiver conectada na conversa, pedir a autorização dele logo no começo do trabalho, já citando quais pastas e pra quê — ele autoriza pela notificação. Se não der, avisar ele na hora pra autorizar; não ficar sem fazer.
- **CONVERSA NOVA (Rubão, 21/11; atualizado 25/11):** quando a conversa for RESUMIDA AUTOMATICAMENTE (ou já estiver pesada: erro, esquecimento do combinado), na mesma hora: (1) atualizar o ESTADO e as PENDÊNCIAS no doc do próprio assunto (nada de doc de passagem novo); (2) AVISAR: "a conversa foi resumida, melhor começar uma nova — atualizei o doc X"; (3) mandar a frase pronta pra ele colar na conversa nova. Se ELE falar que vai começar conversa nova: fazer (1) e (3). Um chat por assunto.
- **INSTRUÇÕES DO PROJETO (Rubão, 25/11):** quando mudar alguma regra que vai nas instruções do projeto, mandar SEMPRE o texto COMPLETO e atualizado num bloco pra ele só copiar e colar (nunca só o item que mudou).
- **DOC SEMPRE EM DIA, SEM PEDIR (Rubão, 25/11):** mudou como algo funciona (site, board, varredura, cortesias, padrão de arte) → procurar o assunto nos docs DO ASSUNTO (e, se for do board, na cópia do repo: `grep -rn` em `docs/` e `AGENTS.md`) e corrigir no MESMO trabalho toda frase que ficou errada. Não perguntar se pode: é obrigação.
- **GITHUB NA HORA (Rubão, 26/11):** atualizou um doc do PROJETO que tem cópia no GitHub (`rubensafn/board-aurum`, pasta `docs/` — só docs do board/varredura/selo/tamanhos e este índice) → atualizar a cópia NO MESMO MOMENTO, com commit e push (manter a 1ª linha de aviso "CÓPIA de segurança"; sem tokens/senhas). Nunca deixar "pro fim da sessão" — foi assim que as cópias ficaram desatualizadas.
- **SEM HISTÓRICO NOS DOCS DE REGRA (Rubão, 25/11):** doc de regra guarda só o que vale HOJE. Histórico/erros antigos confundem quem lê (a varredura) — não acumular.
- **MESMA LINHA = MESMO TAMANHO (Rubão, 25/11 — regra fixa, ele já tinha explicado antes):** numa mesma linha de texto NUNCA uma palavra MAIOR que a outra. O destaque é por COR/BRILHO ou por PESO, sempre no mesmo tamanho. Ex. aprovado: "GARANTA JÁ O SEU" tudo maiúsculo, Playfair Display, mesmo tamanho, neon dourado; GARANTA peso 900 e JÁ O SEU peso 400. Fonte "Tilt Neon" reprovada (feia) — não usar.
- **ORDEM DOS FILMES (Rubão, 25/11) — vale pra toda programação e carrossel (Áurea, regular, V2, campanhas):** do filme MAIS IMPORTANTE pro menos — o grande lançamento primeiro, filme pequeno/pouco conhecido no fim (ex. 26/11: Enfeitiçadas → Jogos Vorazes → Rocky → Batalha). Na dúvida, PERGUNTAR a ordem antes de gerar. A ordem vai no NOME do arquivo (número `_01_`, `_02_`… em todos os formatos), pra quem baixa já postar na sequência certa.
- **TEXTURA DE VIDRO PREFERIDA (Rubão, 25/11):** o cartão de vidro do FEED/FOYER da programação regular (`glass_page` em `kit-prog-regular/build.py`: vidro claro translúcido, degradê branco 0.22→0.12, `backdrop-filter: blur(14px)`, borda branca 20%, sombra suave, fundo = imagem do filme desfocada atrás) é a referência de textura que ele gosta: dá pra ver o fundo através, trabalhar com imagem atrás em blur. Usar esse tipo de vidro como padrão em peças novas, até ele dizer que mudou.
- **RESPIRO (Rubão, 25/11):** espaço entre os elementos das artes (logo, pílulas, chamadas, rodapé). Nada apertado — "dá agonia".
- **Gênero (13/11):** é "O AURUM" — sempre masculino em textos sobre o cinema (ex.: "RARO COMO OURO. ÚNICO COMO EXPERIÊNCIA.").
- **Cantos dos shapes (13/11):** preferência do AURUM é SEMPRE cantos totalmente arredondados (pílula, border-radius máximo) em cards, caixas de vidro/glassmorphism, faixas etc. Só usar outro arredondamento quando não der mesmo.
- **Peças grandes de sinalização / parede (13/11):** texto em CAIXA ALTA e com peso que leia de longe — palavras-chave em peso mais forte, o resto em peso médio (nunca fino), sempre no MESMO tamanho na linha. Logo é o principal: frase sempre menor que o logo. Ex.: parede 2,80×2,80 (autoatendimento) — logo AURUM CINEMA off-white grande no centro, linha neon dourada que some nas pontas, pílula de vidro escuro com neon dourado "RARO COMO **OURO.**" (branco + OURO #FFC200) e, saindo de baixo dela, aba de vidro com "ÚNICO COMO **EXPERIÊNCIA.**" em preto; Cinzel 500/800, as duas linhas com a mesma largura; fundo foto de luz dourada com degradê escuro atrás do bloco.
- **Selo AU padrão do cinema (11/11):** o "shapezinho" da Temporada Áurea — quadrado arredondado em vidro, borda clara, brilho suave, AU off-white (função `au()` em `kit-prog-regular/build.py`). Tamanho proporcional e discreto. O AU fica sempre centrado no quadrado e nunca cortado. A COR muda:
  - **Programação normal:** o amarelo/alaranjado do layout (#FFC200) em TODOS os formatos.
  - **Posts/vídeos da produtora:** cor do vidro conforme a identidade de cada filme.
  - **Campanha Temporada Áurea:** o dourado/bronze da campanha.
- **Modo manual:** quando ele manda um pedido ou alteração, responder primeiro com o plano e ESPERAR o OK antes de gerar. Quando ele está só explicando, só responder, sem regenerar. (Exceção: a varredura agendada da programação gera direto — ver doc dela.)
- **Entrega:** mandar CADA arte separada no chat + um ZIP organizado em pastas numeradas. Salvar o ZIP no Downloads dele pelo bridge quando o PC estiver conectado.
- **Fila de posts (11/11):** todo lote de posts/vídeos pro Insta entra no app FILA DE POSTS. Como alimentar: `claude/FILA-DE-POSTS-APP.md`. Programação só sobe quando ele pedir (aí é só subir o post).
- **Nomes:** CAIXA ALTA, palavras com underscore, tamanho no fim com X maiúsculo (`STORY_02_CARROS_ESTREIA_TEMPAUREA_1080X1920.png`), sem acento, sem prefixo de código de projeto, com o número de ordem (regra ORDEM DOS FILMES).
- **Legendas (11/11):** NÃO perguntar mais celular/PC. Fazer SEMPRE as duas versões: CELULAR (máx. 5 hashtags) e PC (~10–11 hashtags).
- **Stories:** o topo é tampado pela barra de progresso, foto, nome e horário (lado esquerdo); o rodapé pela barra de responder. Classificação indicativa sempre no canto superior direito.
- **Selo AU em posts/vídeos da distribuidora:** nunca com sombra preta; vidro de verdade (só desfoque), cor viva da marca do filme. Nunca AU e logo AURUM CINEMA juntos na mesma peça.
- **Site do AURUM:** abrir pelo navegador do app no PC do Rubão (ferramentas `Claude_Browser`), não por WebFetch. `fetch('/api/programacao')` no console da página traz tudo. (`curl -sL https://aurumcinema.com.br/api/programacao` pelo shell também funcionou.)
- **Pôsteres e logos:** TMDB pelo shell (themoviedb.org e image.tmdb.org funcionam); pôster sem texto = `image_language=xx`. Filme nacional pequeno sem TMDB: procurar o flyer/cartaz oficial nas matérias de imprensa (ex. Batalha: rapdab.com.br). **Nunca entregar pôster pixelado:** se só existir em baixa resolução, ampliar com IA local Real-ESRGAN x4 (`pip install torch --index-url https://download.pytorch.org/whl/cpu` + `torchvision` do mesmo índice + `spandrel`; modelo `RealESRGAN_x4plus.pth` do GitHub xinntao; processar em blocos). O Magnific desta conta é plano grátis e não tem upscale.
- Preferências completas do Rubão também estão na memória do projeto (areas/aurum-cinema.md e preferences.md).

## Onde ficam os arquivos no PC dele (bridge)
- Kit da Temporada Áurea (assets: letreiro, fontes, pôsteres): `~/OneDrive/Documentos/AURUM_KIT_TEMPAUREA/`
- Kit geral de vídeo (light leaks, película, partículas, SFX, LUTs, trilhas): `E:\KIT_EDICAO_VIDEO` (pastas 01_ a 14_).
- Downloads: programações da semana (`PROG_<DD-MM>_A_<DD-MM>/` e zips), pôsteres e logos dos filmes, lotes do selo AU (`AURUM_SELO_AU_<DD-MM>.zip`).
- Repositório do site: `rubensafn/aurum-site` (branch atual `dev-v2`; a `dev` é o site antigo). A pasta `~/aurum-site` do PC NÃO se mexe. Mudança no site pedida na conversa sobe SÓ na `dev-v2`; o merge na `main` só com o OK do Rubão (exceção: selos na tarefa de quarta — ver `claude/VARREDURA-PROGRAMACAO-QUARTA.md`).
