<!-- CÓPIA de segurança — o PRINCIPAL é o doc claude/AUTO-POSTAGEM-AURUM.md do projeto AURUM EDITS (claude.ai). Editar lá, não aqui. -->
# AUTO-POSTAGEM AURUM — pipeline automático (definido em 14/11/2026)

Objetivo: o Rubão não precisa mais baixar nada. O Claude varre as distribuidoras, escolhe os melhores, baixa, aplica o selo AU (regras em `claude/SELO-AU-VIDEOS-PRODUTORA.md`), sobe no board com DIA + HORÁRIO SUGERIDOS, AVISA o Rubão, ele confere/troca o horário e APROVA no board, e o servidor publica sozinho no Instagram no horário. Tamanho/destino/capa: `claude/PADRAO-TAMANHOS-E-DESTINO.md`.

**ESTE DOC É A FONTE DAS REGRAS DA VARREDURA.** Regra nova do Rubão entra AQUI na hora (não só no chat). O que não estiver documentado: PERGUNTAR, nunca inventar.

**Como ler e escrever regra (Rubão, 22/11):** nem limitar demais, nem abrir demais. Exemplo citado aqui serve pra entender o princípio, não é lista fechada (não vira limite). Mas o princípio também não pode ser tão amplo que tudo caiba nele (ex.: "toda novidade é post quente" — errado, ver POST QUENTE). Sempre ANALISAR o caso pelo princípio.

## TAREFA AGENDADA (criada 14/11, ATIVA)
- Nome "AURUM · varredura das distribuidoras" (id trig_01TcQLbVPCUExKpeT8kkWntb). Roda na NUVEM às **11:22 · 15:22 · 18:22** (America/Sao_Paulo), todo dia, aprovação automática, notificação push no celular. (4 rodadas 12h/15h/18h/21h só quando o Rubão mandar.)
- **TEM QUE FICAR NA NUVEM (Rubão, 21/11):** NUNCA ligar "exigir este computador" nesta tarefa — com isso, PC desligado/sem energia = a rodada inteira não acontece. Não depende do PC nem do GitHub: o script de subir lote vem do PROJETO (`claude/fila-de-posts/fila_push.py`), texto da tarefa atualizado em 21/11.
- **A varredura da nuvem NÃO acessa o PC e NÃO fala da pasta do PC na notificação**. Pasta do PC = só a tarefa manual abaixo.
- O prompt manda ler ESTE doc + PADRAO-TAMANHOS-E-DESTINO + SELO-AU-VIDEOS-PRODUTORA + FILA-DE-POSTS-APP antes de agir. Mudou regra/peso? Atualizar ESTES docs (a tarefa lê na hora). Mudou horário das rodadas/passos técnicos? editar a tarefa (update_trigger) entre rodadas, nunca durante uma.
- Sem nada escolhido: encerra SEM notificar — EXCETO quando algum filme obrigatório ficou sem post no dia (Doutor Destino, ou filme da lista sem nada hoje): aí manda 1 notificação curta dizendo qual. Nunca aprova, nunca marca postado, nunca apaga.
- **Artes que ficam no PC (Farofeiros etc.)**: NÃO são desta tarefa. São da TAREFA MANUAL DO PC (trig_01EyY7DmZ8U9nmnUxv2igSC4, criada 21/11): SEM horário, só roda quando o Rubão executar; presa ao PC, pega as artes do `D:\AURUM - DSKP`, aplica selo e sobe em PENDENTES.

## ⭐ PEDIDOS DE AJUSTE DO BOARD — FAZER PRIMEIRO EM TODA RODADA (Rubão, 19/11, board v52)
- No card, a varinha violeta (PEDIR AJUSTE) grava em `fila_posts`: `ajuste_pedido` (texto do Rubão), `ajuste_em`. Ao pedir, o post SAI DOS APROVADOS (aprovado=false) pra não postar a versão velha.
- Ler: `select id, nome, filme, tipo, arquivos, ajuste_pedido, ajuste_em, dia, hora, destino from fila_posts where ajuste_pedido is not null and not arquivado and not postado order by ajuste_em`.
- Fazer o ajuste na peça (selo, ordem, texto, troca de vídeo etc.), seguindo os padrões dos docs (ex.: `claude/VINGADORES-DOUTOR-DESTINO-CAMPANHA.md`). Substituir NO MESMO POST (mesmo id/lote+num; sobrescrever os mesmos caminhos do bucket quando der — nada de arquivo sobrando). Manter dia/hora/destino/legenda que já estavam, salvo se o pedido mandar mudar. NUNCA aprovar de novo (quem aprova é ele).
- Ao terminar: `update fila_posts set ajuste_pedido=null, ajuste_em=null, ajuste_resposta='Ajuste feito: <1 frase do que mudou>' where id=…`. O board mostra a resposta no card.
- Pedido vago / impossível: NÃO chutar. Deixar `ajuste_pedido` como está, gravar `ajuste_resposta='Dúvida: <pergunta curta>'` e perguntar na notificação.
- Se o pedido virar REGRA (ex.: "selo sempre acima do logo da Marvel"), gravar a regra no doc certo na hora.
- Na notificação: 1 linha por ajuste ("06 Vingadores: selo descido pra cima do logo da Marvel · aprova de novo").
- Banco: só UPDATE em `fila_posts` (mesmo banco das CORTESIAS — nunca tocar nas tabelas delas). Nada de cron novo.

## ⭐ POSTS "A FAZER" — LINK DO INSTAGRAM (Rubão, 25/11, board v65) — FAZER JUNTO COM OS AJUSTES, ANTES DA VARREDURA
- No + NOVO POST o Rubão escolhe LINK DO INSTAGRAM: cola o link de um post, escreve/fala o que quer ("O QUE QUERO", `pedido_arte`) e marca ou não SEGUIR NOSSO PADRÃO (`seguir_padrao`). Vira um card em PENDENTES com `a_fazer=true`, `arquivos='[]'`, `link_origem`; não dá pra aprovar enquanto `a_fazer` (o banco trava).
- Ler: `select id, filme, link_origem, pedido_arte, seguir_padrao, destino, dia, hora, legenda_celular, legenda_refazer, legenda_pedido from fila_posts where a_fazer and not arquivado order by id`.
- Fazer: baixar o post do link (mesmo método do Download abaixo) → seguir o `pedido_arte`; se vazio OU `seguir_padrao`, aplicar o NOSSO PADRÃO (tamanho do PADRAO-TAMANHOS, selo AU na cor do filme, capa de cena). Pedido que contradiz o padrão: vale o pedido. Pedido vago/impossível: não chutar — `ajuste_resposta='Dúvida: <pergunta>'`, deixa `a_fazer=true` e pergunta na notificação.
- Subir os arquivos NO MESMO POST: `sign` da Edge Function em `manual/<id>/<arquivo>` + PUT, e `update fila_posts set arquivos='<json igual ao do fila_push: path,url,poster,w,h,nome,kind,dur>', tipo='POST|VIDEO|CARROSSEL', a_fazer=false, ajuste_resposta='Feito do link: <1 frase>' where id=… and a_fazer`. Legenda: se `legenda_refazer`, escrever (regras de LEGENDA) e zerar `legenda_refazer`/`legenda_pedido`; se o Rubão escreveu, não mexer. Dia/hora vazios: sugerir pelas regras; destino pelo formato (só em não aprovado). Registrar o shortcode do link em `fila_vistos` como `baixado` com o post_id.
- Nunca aprovar. Na notificação: 1 linha por post feito.

## ⭐ REPETIR = SÓ A MESMA PEÇA (Rubão, 22/11 — regra GERAL, vale pra qualquer filme e qualquer conteúdo)
- O ÚNICO motivo de "já postado" pra pular é ser a MESMA ARTE/VÍDEO (a mesma peça, mesmo que volte com legenda nova — ver regra "NUNCA SUGERIR O QUE JÁ FOI POSTADO").
- **Assunto parecido NUNCA é motivo pra pular.** Peça nova sobre um assunto que já apareceu é CONTEÚDO NOVO e segue a curadoria normal: notícia que atualiza (números, repercussão, críticas, conquistas), nova peça da mesma campanha/chamada, novo ângulo do mesmo tema. As distribuidoras voltam aos mesmos temas o tempo todo; o que conta é se a PEÇA é nova.
- Ser peça nova NÃO quer dizer que é quente: se for ACONTECIMENTO, vale o POST QUENTE abaixo; se não, curadoria normal (ver NA DÚVIDA, SOBE EM PENDENTES).

## ⭐ REGRAS DO RUBÃO (valem sobre qualquer coisa deste doc; atualizadas 26/11)
- **LISTA DE FILMES = aba FILMES do board** (`fila_filmes where ativo and (no_site or origem='manual')`). Só posta filme marcado. Desmarcado não entra (nem reserva). A lista de 14/11 lá embaixo é histórico.
- **TODO FILME EM CARTAZ TEM POST TODO DIA.** "A gente é um cinema": quem entra no Instagram tem que ver conteúdo de cada filme em cartaz. Filme menos conhecido também ganha o post dele (ainda vende) — pode ir num horário que não precisa de engajamento alto.
- **⭐ PENDENTE NUNCA TRAVA A VARREDURA (Rubão, 26/11):** o Rubão não é obrigado a aprovar nem descartar — post pendente fica lá o tempo que ele quiser e pode ser usado qualquer dia. Ter pendente de um filme (de hoje ou de dia anterior) NUNCA é motivo pra não puxar peça nova dele. Se a distribuidora tem peça nova e boa do filme hoje, a rodada PUXA e sobe em PENDENTES, seguindo a curadoria normal. Pendente antigo: não apagar, não trocar sozinho, não mudar o dia.
- **QUANTIDADE = ANÁLISE, NÃO NÚMERO FIXO** (Rubão, 18/11): não existe teto fixo de posts por dia (às vezes um filme que ninguém esperava engaja bem e merece mais), MAS também não é "posta tudo": nunca lotar o feed (ex.: puxou 30 conteúdos ≠ postar 30). Cada post A MAIS além do 1 por filme tem que se justificar — a pergunta é sempre "compensa? ajuda o engajamento/a venda ou vai atrapalhar o engajamento do perfil?". Não inventar número pra isso: decidir pela análise do engajamento de cada rodada e explicar na notificação quando subir mais que o normal.
- **⭐ NA DÚVIDA, SOBE EM PENDENTES (Rubão, 22/11 — substitui o antigo "na dúvida, vira reserva")**: o Rubão prefere desaprovar ou mandar pra reserva do que ficar sem post. Peça boa em dúvida vai pra PENDENTES, não pra reserva. Continua sem lotar: 1 h entre posts e 12:30–22:00; o que não couber hoje sobe em PENDENTES com dia de AMANHÃ — SÓ se o texto continuar certo amanhã (ver PRAZO DO TEXTO). Reserva fica pro que é claramente mais fraco que o escolhido / sobra que não cabe nem amanhã, e nunca pra peça com prazo.
- **⭐ PRAZO DO TEXTO (Rubão, 25/11; reforçado 26/11 — vale sobre reserva, amanhã e qualquer escolha de dia):** antes de decidir pendente/reserva/dia, ler a LEGENDA da distribuidora e o texto da ARTE (no quadro que já é aberto pro selo/capa) procurando referência de tempo. Regra: **nenhum post pode sair num dia em que o texto dele já esteja errado.** "Amanhã" num post de hoje só vale HOJE → entra hoje como POST QUENTE, no próximo horário livre, ou é pulado com aviso na notificação se não der mais — NUNCA reserva nem outro dia. "Só hoje", "últimos dias", "estreia nesta quinta", data próxima → só antes da data, e a legenda tem que bater com o dia do post. Data distante (ex. estreia daqui a meses) não aperta nada → curadoria normal.
  - **A legenda da distribuidora é a BASE DO TEMPO (Rubão, 26/11):** não precisa ver o vídeo (gasta token) — a legenda deles sempre fala o tempo certo ("amanhã", "estreia hoje", data). A NOSSA legenda é escrita do nosso jeito, mas tem que falar o tempo certo PRO DIA EM QUE O NOSSO POST VAI SAIR: estreia dia 26 postada no dia 25 = "ESTREIA AMANHÃ" (nunca "estreia dia 26", que soa como se fosse demorar); no dia = "ESTREIA HOJE" / "já em cartaz"; data distante = a data. Muita atenção ao que é ESTREIA, ao que ainda vai entrar e ao que fala de amanhã.
  - Post de estreia que pode sair hoje OU amanhã (ficou pendente): escrever de um jeito que continue certo nos dois dias (ex.: "Estreia da semana, já em cartaz no AURUM Cinema.").
- **⭐ POST QUENTE ENTRA NO MESMO DIA (Rubão, 21/11; esclarecido 22/11)**: é EXCEÇÃO, não todo conteúdo novo. Tudo que a distribuidora posta no dia é "novo" — isso NÃO faz ser quente.
  - QUENTE = **ACONTECIMENTO / notícia com peso**, que PERDE O VALOR (e o engajamento) se sair amanhã. Tem prioridade. Ex.: a distribuidora posta quando o filme bate "1 milhão de pessoas já assistiram" — se o AURUM posta um dia depois, perde o momento. Outros do mesmo tipo: marco de público/bilheteria ("maior estreia da semana"), recorde, repercussão forte (ex.: crítica aclamando o filme), trailer oficial novo, anúncio grande do filme. Os exemplos ilustram o princípio; o teste é sempre: **"é acontecimento com peso que perde força amanhã?"** — analisar caso a caso, pesando também o tamanho do filme/momento.
  - NÃO é quente = conteúdo comum do dia a dia, mesmo sendo novo: pôster, cena, bastidor, frase, chamada de ingresso, contagem regressiva, post de fim de semana. Segue a curadoria normal (melhor entra; na dúvida, PENDENTES — ver acima; RESERVA: ele marca QUERO ESSA e a próxima rodada sobe com horário sugerido — decidido em 21/11: não precisa de campo de dia/hora na reserva).
  - Quente entra HOJE, num horário mais tarde do dia (respeitando 1 h entre posts e até 22:00), MESMO que o filme já tenha posts no dia. Ex. do Rubão: Jogos Vorazes já com 2 posts hoje, a Paris posta "1 milhão de pessoas assistiram" → vai hoje de todo jeito. Na notificação: "POST QUENTE: <qual> pra hoje às HH:MM".
- **ENGAJAMENTO decide o resto, sempre mutável**: a cada rodada, olhar pela API o que está engajando (por filme e por horário). Filme engajando bem ganha post a mais e os melhores horários (ex.: Jogos Vorazes engajando muito bem → postamos mais e vendeu mais ingresso, 18/11). Não é regra fixa: muda conforme o retorno.
- **⭐ FILME EM ALTA GANHA MAIS E OS MELHORES HORÁRIOS (Rubão, 22/11)**: o filme do momento (engajamento do nosso perfil + buzz/procura do público) ganha mais posts por dia E os MELHORES horários da tabela ao vivo (`fila_config.horarios`, ver Horários). Não fica preso ao teste da noite (20:30/21:30) — o teste pode ir pra outro filme.
- **NÃO SEGUIR O VOLUME DA DISTRIBUIDORA** (Rubão, 18/11): distribuidora tende a exagerar — posta demais de um filme, ou começa a empurrar filme que ainda está lá na frente mesmo com engajamento ruim. Quantidade/peso de cada filme vem de: (1) engajamento do NOSSO perfil (API), (2) procura do público — pode pesquisar na web o que está sendo mais buscado/comentado (buzz, notícias, tendências do filme no Brasil), (3) o que o Rubão falar. O que a distribuidora está postando é material, não critério. Filme que ainda vai estrear muito longe não ganha espaço só porque a distribuidora está postando. Na dúvida, perguntar ao Rubão (ele quer ir conversando).
- **DOUTOR DESTINO = grande estreia**: post TODO DIA. Se a distribuidora não postou nada novo, usar reserva; se não houver, avisar o Rubão na notificação pra bolar um post próprio (não inventar arte sozinho).
- **TESTE DA NOITE (20:30/21:30)**: continua pelo menos 1 por dia à noite, alternando 20:30 e 21:30. O Rubão PRECISA DE RETORNO: na rodada das 18h, 1 linha na notificação com o bloco `noite` da tabela ao vivo (últimos 7 dias × média, Reels e estático separados). Fechar o teste ~28/11 com um resumo.
- **Horários**: de 30 em 30 min, das 12:30 às 22:00. Nada antes das 12:30 (a manhã é da programação). Pelo menos 1 h entre um post e outro de feed/reels no mesmo dia. Nunca horário que já passou. Os melhores horários vêm da TABELA AO VIVO (seção Horários).
- **LEGENDA**: sempre UMA LINHA EM BRANCO depois da 1ª frase de impacto. Corrigir as pendentes que não estão assim (só essa quebra; nunca as que o Rubão editou).
- **MÚSICA**: post vai sem música (conta empresa não usa música com direito autoral; a API da Meta também não coloca música). Quando tiver música marcante, a legenda manda pro Spotify. Nunca aviso de música; nunca vira VOCÊ POSTA por causa de música (Rubão, 25/11: esses posts não são prioridade, ele decide).
- **QUERO ESSA** (aba RESV do board, `fila_vistos.quero = true`): baixar primeiro, subir em PENDENTES com dia/horário sugerido, marcar `baixado` com post_id e `quero=false`.
- **SELO AU nos posts que o Rubão sobe** (`selo_pendente = true`): aplicar o selo, subir arquivo novo e trocar no post; pular se aprovado e faltando < 30 min.
- **VÍDEO +60 s**: Story pela API não aceita → `destino='feed'` (story o Rubão encaminha à mão). Gravar `dur` no json do arquivo.
- **CARROSSEL-PANORAMA** (pôsteres que emendam um no outro, 19/11): PRESERVAR A EMENDA — ordem original, sem repetir pôster. Mais de 10: usar do 1 ao 10. Selo AU igual em todas as lâminas, num lugar que não tampa rosto (pôster Marvel: centro, acima do logo MARVEL STUDIOS). Conferir se as lâminas emendam antes de reordenar.

## ⚠️ APAGADO NO BOARD = REJEITADO (Rubão, 15/11)
- A lixeira do board NÃO apaga a linha: o trigger `fila_posts_nao_apaga` ARQUIVA (`arquivado=true`, `arquivos_apagados=true`) e o board some com ela (`fila_list` filtra `not arquivado`). Ao olhar PENDENTES/APROVADOS SEMPRE filtrar `where not arquivado`.
- Post apagado SEM ter sido postado → o mesmo trigger marca o `fila_vistos` dele como **rejeitado** (motivo "rejeitado no board"). No board a confirmação diz "REJEITAR ESSE POST? … essa peça não volta nas sugestões". Desde 18/11 também dá pra rejeitar direto na aba RESV.
- POSTADOS → APAGAR TODOS (`fila_arquivar_postados`) só ARQUIVA os postados (somem do board, a linha fica, `fila_vistos` continua `baixado`). Por isso, pra conferir "já foi postado", contar TAMBÉM os postados arquivados (ver regra abaixo).
- REJEITADO vale SÓ PRA AQUELA PEÇA (não encaixou naquele momento: texto de horário que não bate — ex. "sábado, 6 da manhã" postado de noite —, data vencida, repetição). NÃO é padrão de gosto dele: NÃO deduzir que ele não gosta daquele tipo de material, NÃO mexer no peso do filme/tipo. Material parecido do mesmo filme continua valendo normal.
- Nunca sugerir de novo um shortcode `rejeitado`. Não cobrar post rejeitado na notificação.

## ⚠️ TODO FILME TODO DIA, COM O MAIS RECENTE (bronca do Rubão, 15/11; reforçado 18/11 e 26/11)
- TODA rodada confere filme por filme da lista: cada filme em cartaz/pré-estreia precisa ter pelo menos 1 peça no dia (no board ou já postada hoje). O ENGAJAMENTO só soma peça a mais; nunca substitui o mínimo dos outros.
- Ter pendente do filme garante o mínimo, mas NÃO impede puxar a peça nova do dia (ver PENDENTE NUNCA TRAVA A VARREDURA).
- Usar o MATERIAL MAIS RECENTE da distribuidora de cada filme (o que ele já fazia na mão). Antes, conferir se a ARTE/VÍDEO já foi postado (a mesma peça às vezes volta com legenda nova: ex. "Botox preventivo" e "Eu sou um monstro" de Cara de Barro, já postados 13/11).
- Se o filme não tem nada novo nem reserva boa: dizer na notificação ("Cara de Barro: nada novo hoje").

## TROCA NAS RODADAS SEGUINTES (Rubão, 15/11)
- A rodada das 11h já sugere o melhor que existe naquela hora pra cada filme. Até 15h/18h as distribuidoras postam mais: se aparecer peça MAIS NOVA e MAIS INTERESSANTE de um filme que já tem post pendente no dia, TROCAR.
- Trocar = só em post NÃO aprovado. Subir a nova peça no MESMO lote+num (o fila_push substitui o arquivo; mesmo nome de arquivo = sobrescreve, nome novo = conferir que não sobrou linha duplicada), regravar legenda/capa/dia/hora, a peça antiga volta pra `reserva` no fila_vistos e a nova vira `baixado` com o post_id. Já aprovado: não mexer, só avisar na notificação.
- Na notificação dizer o que foi trocado ("troquei o Gatola das 13:00 pelo post novo das 14h").

## REGISTRO `fila_vistos` — nunca baixar o mesmo post duas vezes (14/11)
- Tabela `public.fila_vistos` (Supabase): `shortcode` (código do link instagram.com/p|reel/<shortcode>/, chave), conta, permalink, filme, caption, status, motivo, post_id, postado_distribuidora, visto_em, `quero`, `quero_em` (18/11, QUERO ESSA da aba RESV).
- status: **baixado** (virou post no board — NUNCA baixar de novo) · **reserva** (boa, filme da lista, ainda não usada — fica disponível pra outros dias; aparece na aba RESV do board) · **pulado** (não serve: filme fora da lista, MESMA PEÇA já postada, fraco, data/sessão vencida — NUNCA "assunto repetido") · **rejeitado** (o Rubão apagou no board sem postar, ou rejeitou na aba RESV).
- Reserva NÃO vence sozinha por idade (Rubão, 22/11): quem limpa a aba RESV é ele.

## CURADORIA (regra do Rubão, 14/11)
- A varredura abastece as postagens DO DIA. As distribuidoras postam o mesmo filme 4–6 vezes por dia; o AURUM NÃO posta tudo: escolher os MELHORES (mais forte visualmente, trailer, cena marcante, novidade real) e não lotar o perfil com um filme só.
- O que é bom e não foi usado: na dúvida, PENDENTES (hoje ou amanhã — ver NA DÚVIDA, SOBE EM PENDENTES); o resto vira **reserva** (nunca peça com prazo — ver PRAZO DO TEXTO): em dia que a distribuidora não posta nada (ou posta pouco) de um filme, usar a melhor reserva dele. Reserva que ficou velha ("é só hoje", sessão/data passada, filme saiu de cartaz) → pulado.
- Antes de subir, olhar o que já está no board pendente/aprovado pra hoje e amanhã (sempre `not arquivado`) — pra não repetir a MESMA peça e encaixar horário, nunca pra deixar de puxar peça nova (ver PENDENTE NUNCA TRAVA A VARREDURA).

## PESO POR FILME (o Rubão ajusta — "vamos fazer mais post de tal filme")
- Base: **1 peça por filme por dia** (obrigatório pra TODOS — ver seções acima). Extras só quando a análise mostra que compensa (ver QUANTIDADE = ANÁLISE e FILME EM ALTA) ou quando é POST QUENTE.
- Filme em alta / estreia da semana / pré-estreia grande: **2–3 por dia**, sem sumir com os outros.
- Ajustes do Rubão (atualizar aqui quando ele pedir):
  - Doutor Destino: grande estreia → post todo dia; perto da estreia, mais posts que qualquer outro (2–3/dia). Sem material: avisar pra bolar post próprio (18/11). Pré-venda bombando, sessões já esgotando (19/11) → "ÚLTIMOS INGRESSOS" é chamada válida.
  - Jogos Vorazes: engajando muito bem e vendendo mais ingresso com mais posts (18/11) → manter mais peças enquanto o engajamento sustentar. É o filme do momento (Rubão, 22/11): não limitar.
- Feed com insights: a resposta vem em `media[]` e `insights` é texto no formato `{'data':[{name, values:[{value}]}]}` — usar `ast.literal_eval`.

## ⚠️ REGRA: NUNCA SUGERIR O QUE JÁ FOI POSTADO (bronca do Rubão, 14/11) — vale pra MESMA PEÇA, não pro assunto
1. Feed do @aurum.cinema: Edge Function `fila-admin` ação `feed` — procurar a peça nas legendas/imagens.
2. Board: `select id, nome, filme, postado, arquivado from fila_posts …` SEM filtrar `arquivado` — postado que o Rubão limpou com APAGAR TODOS continua sendo postado.
3. Peça da pasta de artes dele (ex. Farofeiros) cuja frase aparece numa legenda já postada → pular.
4. Olhar a PEÇA (frame/imagem), não só a legenda da distribuidora: a mesma arte volta com legenda diferente. E o contrário também: peça NOVA sobre o mesmo assunto NÃO é repetição.

## ⚠️ REGRA DO DIA (Rubão, 14/11)
- TODO DIA pelo menos UM conteúdo de CADA filme em cartaz/pré-estreia (pente fino diário: ele seleciona).
- A PROGRAMAÇÃO é o primeiro post do dia (9h–10h, feita por ele). NADA de post de filme antes dela.
- Pelo menos UM por dia À NOITE, ALTERNANDO 20:30 e 21:30, de preferência trailer/pré-estreia. Lógica dele: depois das ~21h quem ia ao cinema já foi; o post da noite fala com quem está em casa e fomenta a ida NO DIA SEGUINTE. Testar ~2 semanas e comparar (retorno pedido — ver REGRAS 18/11).

## Varredura e feed — Edge Function (token da Meta NUNCA sai do servidor)
- POST `https://gdtfwmqbvsqtxtccrydv.supabase.co/functions/v1/fila-admin` com o FILA_TOKEN (o mesmo do fila_push):
  - `{"action":"varrer","token":"…","users":["sonypicturesbr",…],"limit":12}` → `{contas:{arroba:[{permalink,media_type,media_product_type,timestamp,caption,children}]}}` (business_discovery; não traz o arquivo de vídeo). Timestamps em UTC.
  - `{"action":"feed","token":"…","limit":60,"insights":true}` → últimos posts do @aurum.cinema com reach/total_interactions/saved/shares.

## Onde roda (decisão 14/11; reforçado 21/11)
- PRINCIPAL = NUVEM (tarefa agendada). Não depende do PC.
- PLANO B = PC do Rubão (Windows, "ra-desktop"): se o Instagram bloquear download vindo de servidor, baixar pelo shell do PC numa conversa.
- CÓPIA NO PC (quando trabalhando em conversa com o PC ligado): `D:\AURUM - DSKP\<MÊS>\<DD.MM>\` com SÓ `BAIXADOS\` (originais juntos, nome legível; só carrossel ganha subpasta `CAR - <FILME>`) e `FINAIS\` (com selo + LEGENDAS + ZIP; só carrossel ganha subpasta). Pastas por filme dentro do mês são DELE.
- `D:\AURUM - DSKP\AUTO-POSTAGEM\` fica SÓ com `META_TOKEN.txt` e `META_IDS.txt`. Limpeza do PC: ele mesmo faz, por mês.
- device_bash: `$HOME/mnt/AURUM - DSKP`. Arquivos > ~10 MB voltam pro PC via SendUserFile + fileUuid no device_commit_files.

## Horários — TABELA AO VIVO (desde 25/11)
- Regra: ver REGRAS 18/11 (30 em 30 min, 12:30–22:00, 1 h entre posts, engajamento + FILME EM ALTA escolhem os melhores horários).
- **Fonte = `fila_config` chave `horarios`** (json), recalculada 1x/dia às 04:17 (Brasília) pelo job `fila-limpar` → `fila-admin` `cleanup` com a cron_key (edge v20). A varredura LÊ: `select v::jsonb from fila_config where k='horarios'`. Nunca chamar a Meta pra montar tabela de horário. Se a Meta falhar no recálculo, fica a do dia anterior (`atualizado` mostra a data).
- Conteúdo: últimos 90 dias do @aurum.cinema, SEM posts de programação (legenda com programa/sessões/horários), horário de Brasília. `reels` e `estatico` separados, cada um com `media_alcance`, `media_inter`, `faixas` (h = 12…22; `n` posts; `alcance` e `inter` = × média, 1.0 = na média; `pouco` = menos de 5 posts → não confiar) e `noite` (TESTE DA NOITE: 20:30 e 21:30 dos últimos 7 dias, n + alcance/inter × média).
- O board usa a mesma tabela nas etiquetas dos botões de horário e no texto do horário digitado (board v64, RPC `fila_horarios`).
- Botões do board: 12:30 ALMOÇO · 15:00 TARDE · 17:30 FIM TARDE · 20:30 NOITE · 21:30 P/ AMANHÃ (TESTE). + OUTRO HORÁRIO.
- Mercado 2026: pico de uso no Brasil 18h–22h; Metricool 19h–21h; Sociality (335 mil posts) noite 20h–0h; Buffer (9,6 mi) qua 12h/18h, sex e sáb fracos.

## Distribuidoras (Instagram)
@sonypicturesbr · @wbpictures_br · @paramountbrasil · @disneystudiosbr · @marvelbrasil · @parisfilmes · @diamondfilmsbr

## Download (testado 14/11 no PC e na nuvem; atualizado 15/11)
- VÍDEO / Reels: `yt-dlp -o "<pasta>/<shortcode>.%(ext)s" https://www.instagram.com/p/<shortcode>/` (sem login; `pip install yt-dlp --break-system-packages` se faltar). Dá 1080x1920.
- yt-dlp bloqueado por limite ("rate-limit… login page", 15/11 — às vezes já no 1º download): pegar o `video_url` dentro do HTML de `/p/<shortcode>/embed/captioned/` (desfazer `\/`) e baixar com curl. Vem 720x1280 → o vid.sh escala pra 1080x1920.
- IMAGEM e CARROSSEL: `curl -A "Mozilla/5.0" https://www.instagram.com/p/<shortcode>/embed/captioned/` → post único: `<img class="EmbeddedMediaImage" src=...>` (html-unescape); carrossel: cada `display_url\":\"...\"` no JSON (desfazer `\\\/`→`/`, `\\u0025`→`%`, `\\u0026`→`&`; o 1º se repete = capa). Atenção: a última URL da lista às vezes não tem quebra de linha no fim — conferir que baixou TODAS as lâminas. (Funcionou na nuvem em 22/11.)
- Arquivo > 50 MB (Reels longo): cópia ~45 MB (`-b:v 2500k`) com `"comprimido": true`.
- gallery-dl sem login NÃO funciona. baixador.com não responde a script; saveclip.app é a alternativa dele.
- Selo na nuvem: os scripts esperam `/home/claude/au2/anim.js`, `au.svg` ao lado e `vid.sh` (copiar de `claude/au-anim.js` e `claude/au-vidanim.sh`). Chromium em `/opt/pw-browsers/chromium-1243/chrome-linux64/chrome`.

## Filtro: só filmes que o AURUM vai postar
- A lista é a aba FILMES do board (ver REGRAS DO RUBÃO).
- Fora (não postar): VisionQuest (série Disney+), D-BOX/IMAX sem confirmar que o AURUM tem. Gatto (Disney/Pixar), Ramayana, Como Roubar um Banco: fora da lista. Carrossel Paris do filme de Allan Deberton (Gugu e Dilma): fora.

## Os Farofeiros 3
- Artes no PC: `D:\AURUM - DSKP\NOVEMBRO\OS FAROFEIROS 3\POSTS FAROFEIROS` (PNG 1080x1440, MP4, subpasta `Story` com stories DATADOS `[DOWNTOWN]MM-DD_...` — usar no dia da data). Repetidos ("(1)"/"(2)") — usar hash. PNG → JPG. (A varredura na nuvem não alcança o PC: essas peças entram pela tarefa MANUAL do PC.)
- Cor do selo Farofeiros: tinta rgba(255,96,10,0.68), borda rgb(255,176,80), glow rgba(255,110,20,0.55).
- Só entra se estiver marcado na aba FILMES.

## Stories
- A API PUBLICA Story (foto ou vídeo), sem legenda, sem sticker/link/música/enquete.
- NÃO dá pra "encaminhar o post do feed pro Story" pela API. Feed (1080x1440/1350) é SÓ FEED; Story na mão se ele quiser.
- Vídeo de Story pela API: no máximo 60 s (erro 2207082 no Rocky de 2:28 em 16/11). Vídeo maior = só FEED.

## Postagem no Instagram — API da Meta (FUNCIONANDO 14/11)
- App **AURUM POSTAGEM** (ID 3431092340432303), portfólio AURUM Cinema (business_id 1602586997592492), modo desenvolvimento. (Cuidado: existem portfólios "CineX" e "Cinex - Geral".)
- Usuário do sistema **AURUM POSTAGEM BOT** (ID 61596417217078) com Conteúdo + Insights na Página e no IG.
- Token NUNCA EXPIRA. Limite 100 publicações/24h. Cópia no PC em `AUTO-POSTAGEM\META_TOKEN.txt`; no servidor em `fila_config` (meta_token, meta_ig_user), gravado pelo PC via `set_meta`. Nunca passa pelo chat.
- IDs: Página 1089344114255522 · IG user 17841457591465631.
- Se perder o token: Business Settings → Usuários do sistema → AURUM POSTAGEM BOT → Gerar token → app AURUM POSTAGEM → Nunca → mesmas permissões; depois `set_meta`.

## Como a publicação automática funciona (Supabase)
- Colunas em `fila_posts`: `hora`, `aprovado`, `aprovado_em`, `ig_status` (null | criando | publicado | erro), `ig_container`, `ig_media_id`, `ig_permalink`, `ig_erro`, `ig_tentativas`, `destino`, `aviso`, `capa_ms`, `ig_story_*`, `arquivado`, `arquivos_apagados`, `ajuste_pedido`, `ajuste_em`, `ajuste_resposta` (19/11).
- RPCs: `fila_set_hora`, `fila_set_dia` (não deixam aprovado sem dia/hora), `fila_set_destino`, `fila_set_aprovado` (exige dia, hora e destino), `fila_pedir_ajuste` (19/11). `fila_vencidos()` só service_role.
- Publicação: toques de um disparo por post aprovado (`fila_toque_*`) → `fila-admin` ação `publicar` (cron_key): cria o container (REELS com share_to_feed + thumb_offset; imagem; carrossel até 10; STORIES) e publica quando FINISHED. Erro → "ERRO AO POSTAR" / "TENTAR DE NOVO" no board. (O antigo `fila-publicar` a cada 5 min NÃO existe mais.)
- Legenda usada: `legenda_pc`. `fila_push.py` NÃO manda dia/hora/aviso/capa/destino: gravar com SQL depois (só em não aprovados).

## Limpeza do armazenamento (Rubão, 15/11)
- Arquivos de post POSTADO saem do storage depois de **3 dias** (`DIAS_LIMPEZA = 3` no código do `fila-admin`). A linha fica como histórico (`arquivos_apagados=true`).
- Roda sozinha: `pg_cron` job **fila-limpar** todo dia 07:17 UTC (04:17 de Brasília) → `fila-admin` ação `cleanup` com a `cron_key` (desde 25/11 também recalcula a tabela de horários). Também roda quando o board abre (com a senha — aí só limpa, nunca chama a Meta).
- Post apagado/rejeitado no board: arquivos saem NA HORA (ação `delete`), a linha é arquivada pelo trigger.
- Armazenamento em 15/11: 259 MB de 1 GB (grátis).

## Pendente
- Capa com selo AU: implementar `cover_url` no `fila-admin`.
- Carrossel Marvel "Tudo nos leva ao mesmo destino" (DfiI69xlPLA) em reserva: confirmar se é Doutor Destino.
