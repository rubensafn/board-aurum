<!-- CÓPIA de segurança — o PRINCIPAL é claude/SELO-AU-VIDEOS-PRODUTORA.md do projeto AURUM EDITS. Editar lá. -->
# Selo AU em posts/vídeos da produtora — PADRÃO (atualizado 25/11/2026; doc único do selo, só o que vale hoje)

Fluxo: Rubão manda o vídeo pronto da produtora → só aplicar o selo AU → devolver em 1080x1920 pra postar no Insta. Não mexer em corte, cor nem áudio.
Lote misto (vídeos + posts + carrosséis num zip, separado por pasta) → mesma regra pra tudo, saída organizada em VIDEOS/, POSTS/ e uma pasta por carrossel, numerados, + LEGENDAS_<data>.txt com uma legenda por arquivo (mesmo número e nome).
Nomes em CAIXA ALTA com underscore e o tamanho no fim (ex.: 04_VINGADORES_DOUTOR_DESTINO_1080X1920.mp4).
Arquivos repetidos no lote (mesmo hash): ignorar, entra só um.
Depois de entregar: jogar o lote na FILA DE POSTS (`claude/FILA-DE-POSTS-APP.md`). Atalho do Rubão: "subir no board" = subir com o fila_push.py, sem perguntar.

## Regras de entrega (Rubão, 14/11)
- Post feito do zero pro AURUM TAMBÉM leva o selo AU.
- Entrega no chat: arte como arquivo + legendas CELULAR e PC escritas no texto da resposta, cada uma num bloco de código (botão de copiar). Não mandar só .txt nem texto solto.
- Board: pode subir a arte assim que fizer, mas cada peça é UM post só: a cada alteração, subir por cima do MESMO id (mesmo lote + num). Nunca criar post novo por versão.

## Legendas: SEMPRE AS DUAS VERSÕES (regra do Rubão, 11/11)
- NÃO perguntar: fazer SEMPRE duas versões de cada legenda, CELULAR e PC (mesmo texto, muda só o bloco de hashtags). No app vão em `legenda_celular` e `legenda_pc`.
- Celular: no máximo 5 hashtags.
- PC: ~10–11 por post: filme (PT + EN), elenco/estúdio, nicho/gênero e #AURUMCinema #CinemaGoiania #Goiania.
- Evitar "amanhã"/"hoje" no texto, usar a data (ex.: "estreia nesta quinta, 12/11").
- Checar datas na web. Na dúvida, não cravar o dia. Não citar IMAX/Infinity Vision sem confirmar que o AURUM tem.

## VÍDEO: selo ANIMADO (regra do Rubão, 28/10)
- Em vídeo o box do AU sempre tem animação de entrada, e o AU tem uma animação contínua bem leve. Em post estático NÃO anima.
- Scripts (`au-anim.js` gera os frames, `au-vidanim.sh` compõe no ffmpeg): entrada 1,6 s (vidro surge com pop, AU se desenha pelo contorno e preenche); loop de 5 s (cheio ~3,4 s → esvazia pro contorno → luz corre pelo traço → preenche); borda/glow pulsa de leve; vidro de verdade segue a máscara animada.
- Rodar o anim.js no fps do vídeo. Temas: red, blue, green, purple, orange, rocky, gatola (turquesa — nunca vermelho), gelo (Ebenezer).
- `node au-anim.js <tema> <fps> <pasta> [S]` (S = 132 padrão; 92 em vídeo de feed) e `au-vidanim.sh <in> <tema> <fps> <out> [X Y S largura altura]`. au.svg ao lado do anim.js.
- VÍDEO DE FEED (720x960 → 1080x1440): selo animado no tamanho de imagem (92px, AU 72px).
- Quando NENHUMA posição fica livre o vídeo todo, o selo pode sair (intro ao contrário ~0,55 s) e voltar — só por LEGENDA; texto de efeito rápido pode passar por cima.

## Selo
- Monograma: `AURUM_ENAGRAMA_AU.svg` (branco) na raiz do projeto, salvo como `au.svg` ao lado do script.
- VÍDEO: quadrado de 132px com raio de 26px em x=474, y=1560 (1080x1920), acima da barra de responder dos Stories. Vai onde tiver mais espaço, fugindo das interfaces do Reels e dos Stories.
- Vidro de verdade: o trecho atrás do selo desfocado frame a frame (gblur sigma 14, saturação 1.2) + tinta da cor, brilho diagonal, borda de 5px e glow na cor.
- SEM sombra preta atrás do selo (nem da setinha).
- AU com 112px de largura no quadrado de vídeo, sempre CENTRADO e nunca cortado.
- Vídeo 720x1280 → escala lanczos pra 1080x1920 antes do selo (crf 17).
- CONFERIR O VÍDEO INTEIRO antes de fixar o Y: o selo nunca pode ficar em cima de LEGENDA (falas). Varrer a faixa (y 1480–1780) a 1–2 fps e escolher um Y livre.
- Texto de EFEITO/cartela que entra e sai rápido pode ficar por baixo do selo. Se a cartela ocupa a área, desce o selo pra uma faixa livre.

## IMAGENS
- AU em imagem: quadrado de 92px (raio 20, borda 4, AU 72px). Margem de canto: 66px.
- CARROSSEL SEMPRE tem a setinha de arrastar em TODAS as lâminas, menos na última. Post único: só o AU.
- Setinha: cápsula 84x44, raio total, mesmo vidro, borda 2.5px, chevrons ››› com opacidade 0.32 / 0.62 / 1.0; padrão canto inferior direito (x=930).

## POSIÇÃO NAS IMAGENS: ANALISAR CADA ARTE (regra do Rubão, 26/10)
- NÃO existe canto fixo. Olhar cada arte e pôr o AU onde fica mais bonito e faz sentido.
- Artes centralizadas → AU ALINHADO AO CENTRO (x=494; x=498 em arte de 1088 de largura), encaixado num respiro entre os elementos. Exemplos que ele aprovou: Cara de Barro → logo acima do selo DC STUDIOS; Jogos Vorazes → centro, EMBAIXO, logo acima do bloco do título; carrossel Vingadores → no respiro entre o logo e a classificação, setinha na mesma linha (930).
- Centro todo ocupado → canto livre (66,66 / 930,66), sempre no respiro, nunca em cima de texto.
- Carrossel segue um padrão entre as lâminas.
- Nunca encostar em texto, aspas, botões, logos ou nomes. Vidro sempre contrastando com o fundo logo atrás.

## Regra de cor
- A cor sai da marca do filme e tem que ser VIVA, saturada. Borda num tom mais claro da mesma cor. Brilho branco bem leve.
- Filme novo sem cor definida: NÃO perguntar. Escolher a cor mais marcante do filme (P&B/neutra → vidro escuro). Registrar em "Cores por filme" e avisar na entrega.

## Cores por filme (tinta / borda / glow)
- Cara de Barro: rgba(196,0,12,0.66) / rgb(255,36,48) / rgba(255,0,20,0.55).
- O Outro Lado das Redes: rgba(52,132,228,0.60) / rgb(150,206,255) / rgba(56,146,245,0.55).
- Vingadores: Doutor Destino (verde neon): rgba(14,150,44,0.64) / rgb(76,255,108) / rgba(40,255,80,0.55).
- Carros (vermelho McQueen): rgba(214,14,22,0.68) / rgb(255,70,70) / rgba(255,20,30,0.55).
- Verity: rgba(200,16,40,0.62) / rgb(255,64,82) / rgba(230,18,44,0.50).
- Sessão Unimed: verde Unimed #00995D.
- Ebenezer (gelo): rgba(56,160,214,0.64) / rgb(176,234,255) / rgba(90,196,255,0.55).
- Street Fighter: rgba(255,72,12,0.64) / rgb(255,150,70) / rgba(255,80,16,0.55).
- O Gatola da Cartola (turquesa SEMPRE): rgba(0,168,162,0.74) / rgb(70,240,226) / rgba(0,210,198,0.6).
- Eu Sou o Rocky (âmbar): rgba(226,120,20,0.64) / rgb(255,184,92) / rgba(240,130,30,0.52).
- Jogos Vorazes: Amanhecer na Colheita (roxo): rgba(112,36,178,0.64) / rgb(190,130,255) / rgba(140,60,230,0.55).
- Se Eu Fosse Você 3: vidro na cor OPOSTA ao fundo — rosa rgba(228,30,138,0.64)/rgb(255,120,192); azul rgba(18,150,228,0.66)/rgb(120,210,255).
- Os Farofeiros 3 (laranja da campanha): rgba(255,96,10,0.68) / rgb(255,176,80) / rgba(255,110,20,0.55).

## Como é feito
- Imagens: Playwright (HTML com a imagem de fundo e os elementos com backdrop-filter, screenshot no tamanho original) — `claude/au-make.py`. Vídeo: `claude/au-anim.js` + `claude/au-vidanim.sh`.
