<!-- CÓPIA de segurança — o PRINCIPAL é o doc claude/PADRAO-TAMANHOS-E-DESTINO.md do projeto AURUM EDITS (claude.ai). Editar lá, não aqui. -->
# Padrão de tamanho, destino (FEED/STORY), capa e horário — regras do Rubão (atualizado 25/11/2026)

## Tamanho
- **REGRA GERAL (23/11): NUNCA pôr faixa preta dentro do arquivo.** Se não dá pra adaptar sem cortar/riscar, posta no tamanho ORIGINAL — o Instagram aceita todos os formatos e põe a borda sozinho na tela cheia.
- FEED: 1080x1440 é a PRIORIDADE. Story e Reels: 1080x1920.
- 4:5 (1088x1344, 1080x1350…): ver se DÁ pra adaptar pra 1080x1440 E se fica bom (sem cortar informação, sem deformar). Se não der, manter em 1080x1350. Nunca cortar texto/logo/classificação pra caber.
- Quadrado 1080x1080: mesma lógica — tenta 1440 pela borda; se não der, posta quadrado.
- **Deitado — 16:9 (1920x1080) e 4:3 (1440x1080): posta NATIVO, sem faixa.** SÓ FEED. Capa sempre separada (frame da cena + selo AU), porque o grid corta o meio (3:4). Selo AU dentro do vídeo, no canto, proporcional.
- Carrossel: todas as lâminas no MESMO formato (o Instagram corta todas pelo formato da 1ª).
- Método que funciona quando a borda é fundo escuro/liso: redimensionar pra 1080 de largura e completar em cima/embaixo esticando a própria borda (6 px) com desfoque + degradê de 14 px na emenda. Quando a borda tem detalhe (tijolo, prédio, rosto), a esticada risca → manter o original, ou expansão generativa (Magnific/Adobe) — testar antes e mostrar.
- Aplicar o selo DEPOIS de adaptar o tamanho.
- Board: o `destFixo` trata tudo que não é alto (altura/largura ≤ 1,6) como FEED fixo — deitado, quadrado, 1350, 1440. PENDENTE: confirmar que a API da Meta publica 16:9 na conta.

## Destino pelo FORMATO
- 1080x1440, 1080x1350, quadrado ou deitado (estático OU vídeo) = SÓ FEED. Nunca vira Story automático. O card mostra FEED fixo + "!": "quer no story? depois que postar, encaminha e adiciona ao story pelo app".
- Estático 1080x1920 = SÓ STORY (sem legenda, sem botões). Carrossel = FEED.
- Quando a distribuidora tem as duas versões (feed 1080x1440 + story 1080x1920), a versão story leva `STORY_` no nome do arquivo → card fica SÓ STORY.
- Só vídeo 1080x1920 (Reels) até 60 s mostra os botões FEED e STORY. Vídeo +60 s = só FEED (a API só aceita story até 60 s); card mostra "Só FEED · story à mão". Sem corte automático (Rubão, 25/11).
- Board: `destFixo(p)` decide; ao aprovar grava o destino fixo via `fila_set_destino`.

## Botões FEED e STORY (só Reels 1080x1920 até 60 s)
- Ele marca um, outro ou os dois. NADA vem pré-marcado. Sem destino o APROVAR não libera.
- Banco: `fila_posts.destino` = feed | story | feed_story | null. RPC `fila_set_destino`.
- Publicação: feed_story → posta no feed e, logo depois, o mesmo arquivo como Story (`ig_story_status`, `ig_story_id`). story → só Story.
- Story pela API = arquivo solto: sem legenda, sem sticker/link do post, sem enquete/caixinha/música.

## AVISO no card
- Peça que precisa de algo que só dá pra pôr no app (caixinha de pergunta, enquete, link, figurinha) → preencher `fila_posts.aviso` com o que pôr e "baixa e posta na mão". NÃO esconder isso na legenda.
- **MÚSICA NÃO GERA AVISO** (Rubão, 25/11): post vai sem música e, quando tem música marcante, a legenda manda pro Spotify (regra MÚSICA do AUTO-POSTAGEM).
- `fila_push.py` não manda `aviso`: gravar com SQL depois do push.

## Capa do Reels
- Sempre escolher a capa de todo vídeo de feed: frame do PRÓPRIO vídeo.
- APROVADO por ele: capa = frame da cena + selo AU mais pra cima (por script). Vai como imagem separada (`cover_url`) — falta implementar no `fila-admin`. Arte de capa desenhada: NÃO (gasta token), só se ele pedir.
- Script de capa: amostra a 2 fps, nota nitidez+luz, pula 1 s do início e 1,5 s do fim, folha com 6 candidatos espaçados ≥2 s; olhar a folha e escolher.
- REGRA DO RUBÃO: escolher uma CENA que mostre que é o filme (personagem/momento marcante), NÃO a cartela com nome/data. Evitar frame com gente correndo/borrado/cortado.
- Banco: `fila_posts.capa_ms` (ms). A Edge Function manda `thumb_offset` no REELS.

## Horário no board
- Botões 12:30 · 15:00 · 17:30 · 20:30 · 21:30 (TESTE) + OUTRO HORÁRIO, com o alcance × média da TABELA AO VIVO (`fila_config.horarios`, recalculada todo dia 04:17). Detalhes no AUTO-POSTAGEM (seção Horários) e no FILA-DE-POSTS-APP.

## Publicação e horário que já passou
- Ao aprovar, o banco agenda 3 toques só daquele post (15 min antes, na hora, +2 min) — não existe consulta periódica.
- Post NÃO aprovado nunca sai, mesmo com o horário vencido.
- Se ele aprova com horário já passado (ou a menos de 5 min), o board avisa e só aprova se ele tocar em POSTAR AGORA.
