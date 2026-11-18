# ESTADO DO BOARD — LER ANTES DE MEXER EM QUALQUER COISA

Este arquivo é a memória do projeto. **Toda conversa nova começa lendo este arquivo e o README.md.**
**Toda mudança termina atualizando este arquivo** (o que foi feito, o que ficou pendente), junto com o commit.

Atualizado em: 18/11/2026, 03h (versão no ar: v46, commit acfc879)

---

## 1. Regras do Rubão (não quebrar)

**Como trabalhar**
- Responder curto, em português, exatamente o que ele perguntou. Pergunta ≠ pedido pra mexer.
- Se ele está perguntando, **só responde, não mexe**. Se ele mandou parar, para.
- Antes de mudar como algo funciona (agendamento, frequência, banco, varredura, estrutura): explicar o que muda e o risco, esperar o OK.
- Antes de afirmar algo sobre o código (cor, tamanho, comportamento): **conferir no código**. Nunca responder de cabeça.
- Antes de mexer: `git pull` e conferir a versão no ar da edge function (outras conversas podem ter mexido).

**Branches**
- Toda mudança vai pra **dev E main juntas** (`git push origin dev && git push origin dev:main`).
- Só fica só na dev quando ele avisar que é mudança grande e quer ver antes.

**Banco (Supabase gdtfwmqbvsqtxtccrydv, plano grátis, MESMO banco do sistema de CORTESIAS)**
- Nunca tocar nas tabelas das cortesias.
- **Nunca** criar consulta periódica (cron de minuto em minuto etc.). Já derrubou board + cortesias em 16/11.
- pg_cron hoje: só `fila-limpar` (diário 07:17) + toques de um disparo por post aprovado (`fila_toque_*`).

**Visual**
- **Nada pode ficar cortado**: canto, contorno, brilho/neon de botão, caixa ou card nunca cortado pela borda (rolagem, altura fixa, pop-up). Conferir **celular (360 e 390 px) E PC** em print, com zoom, antes de entregar.
- Identidade do board = **neon**: roxo `#a78bfa`, ciano `#67e8f9`, rosa `#fb7185`, verde `#4ade80`, vermelho `#f87171`. AU branco. Contorno colorido em degradê (ouro→rosa→roxo→ciano) é da marca.
- **NÃO é a identidade do sistema de Cortesias** (outro sistema, outro visual — não copiar nada de lá).
- Rubão **odeia amarelo clarinho**. Âmbar apagado/dourado sem neon não serve. Ouro (marca AU) pode, mas com critério.
- Padrão de cor por significado: **verde = ok/certo**, **vermelho = erro**, **amarelo-laranja vivo = pendente/atenção**.
- Cor quente tem que ser **uma só, igual em tudo** (ver pendência P1). Degradê vivo, nunca escurecendo pra marrom/preto; texto legível por cima.
- Botões novos do mesmo tamanho dos que já existem.
- Pensar sempre em celular E desktop, usabilidade e praticidade (ele usa muito pelo celular).

---

## 2. O que existe hoje (no ar)

- `index.html` — board inteiro (HTML/CSS/JS num arquivo). Camadas de CSS por versão no fim do `<style>` (v42…v46).
- `supabase/functions/fila-admin/index.ts` — edge function (v16 no ar). Ações: sign/upsert/varrer/feed/set_meta (token), publicar (cron_key), delete/cleanup (pin), **upload_sign** (pin, NOVO POST), **filmes** (pin, puxa do site).
- Tabelas: `fila_posts` (+ colunas `subido`, `selo_pendente`), `fila_filmes` (nova), `fila_config`, `fila_vistos`.
- RPCs novas: `fila_novo_post`, `fila_filmes_list`, `fila_filme_set`, `fila_filme_add`, `fila_filme_del`.

**Feito em 18/11 (v43–v46)**
- + NOVO POST (sobe arquivo próprio, filme, onde posta, legenda ou GERAR LEGENDA, dia/hora, selo AU ✓/✗ obrigatório) → entra em PENDENTES. Rubão testou e funciona.
- Aba FILMES: puxa em cartaz + lançamentos de `aurumcinema.com.br/api/programacao` e `/api/upcoming` só ao abrir (máx. 1x/10 min); desmarcado continua desmarcado; filme novo chega marcado; dá pra adicionar filme na mão.
- Avisos de baixo maiores. Abas no celular: PEND · APROV · POST.
- Cards com altura fixa; botões dos cards e pop-ups sem corte.

---

## 3. PENDÊNCIAS (em ordem)

**P1 — CORES (Rubão está insatisfeito com o v46, corrigir primeiro, mostrar print ANTES de subir)**
- O v46 deixou COPIAR, número do card, VER LEGENDA e botão principal (ENTRAR/COPIAR do pop-up) num laranja escuro/barro, e mudou a aba PENDENTES pra pior. **Rubão não gostou.**
- Fazer: (1) voltar a aba PENDENTES como era antes do v46 (`.seg-ind[data-v="pend"]` original: `linear-gradient(160deg,rgba(251,191,36,.62),rgba(217,119,6,.34))`, contorno `rgba(253,230,138,.85)`); (2) definir UMA cor quente só e usar igual na aba PENDENTES, HOJE (filtro), COPIAR, número do card e VER LEGENDA — degradê vivo amarelo-laranja forte `#fbbf24` → laranja aceso `#f97316`, sem escurecer, texto branco legível; (3) mandar print celular + PC pro Rubão aprovar antes de subir.
- Aviso de OK (toast): a caixa inteira deve seguir a identidade (verde quando é ok), não só o ícone.
- Hoje existem 3 amarelos no código: `--gold #f3d977/#d9b855`, `--amber #fbbf24`, e o laranja do v46 `#fb923c/#ea580c`. Unificar.

**P2 — Story do Rocky**: post Reels feed+story (16-11_02 "Eu Sou o Rocky", arquivo comprimido) saiu só no feed; story deu erro 2207082. Investigar e explicar antes de mexer.

**P3 — Varredura (só o texto da tarefa agendada, depois que uma rodada terminar, com OK do Rubão)**
- Legenda: sempre linha em branco depois da 1ª frase de impacto (corrigir as pendentes também).
- Música: posta normal, sem música, legenda manda pro Spotify (conta empresa não usa música com direito autoral).
- Seguir a lista da aba FILMES (só filmes `ativo`).
- Aplicar selo AU nos posts com `selo_pendente = true` e escrever legenda dos `legenda_refazer = true`.
- RESV + QUERO ESSA; menu celular PEND · RESV · APROV · POST.
- Horários de 30 em 30 min (12h30–22h), 1 h entre posts, limites (≤5 feed+reels, ≤8 stories/dia, 1 por filme, 2 se bombando), filme forte em horário nobre.
- 4 rodadas (12h, 15h, 18h, 21h) **só quando o Rubão mandar**.

**Stand-by**: PC (pasta do dia D:\AURUM - DSKP\<MÊS>\DD.MM com BAIXADOS/FINAIS, artes do D:) e botão RODAR VARREDURA.

---

## 4. Como testar visual sem a senha
Scripts de print com dados falsos (playwright) ficavam em `/home/claude/shot*.py` (fora do repo). Recriar: abrir `index.html` com `localStorage fila_sess`, interceptar `*supabase.co/**` devolvendo posts/filmes de exemplo, tirar print 360/390 px e 1280 px com `device_scale_factor=2`.
