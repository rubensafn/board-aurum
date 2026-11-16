// FILA DE POSTS — uploads assinados e gravação de posts (token), limpeza de vídeos já postados e apagar post (senha da fila),
// e PUBLICAÇÃO AUTOMÁTICA no Instagram (@aurum.cinema) dos posts APROVADOS, no dia/horário marcado (chamada pelo pg_cron de 5 em 5 min).
// O container é criado até ANTECEDENCIA_MIN minutos antes e só é publicado no minuto marcado (sem atraso).
// Erro do Instagram: tenta de novo 1x sozinho; se falhar de novo, marca erro e avisa o Rubão no celular (ntfy, fila_config.notify_url).
// SÓ mexe na tabela fila_posts, na fila_config (chaves meta_*/cron_key/notify_url) e no bucket fila-posts. Nunca tocar no SISTEMA DE CORTESIAS (mesmo projeto).
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.45.4";

const BUCKET = "fila-posts";
const DIAS_LIMPEZA = 3;
const ANTECEDENCIA_MIN = 15;
const GRAPH = "https://graph.facebook.com/v21.0";
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (b: unknown, s = 200) => new Response(JSON.stringify(b), { status: s, headers: { ...cors, "Content-Type": "application/json" } });
const CAMPOS = ["id","num","nome","filme","tipo","lote","legenda_celular","legenda_pc","comprimido","arquivos"];
const PUB = `/storage/v1/object/public/${BUCKET}/`;
const toPath = (u: unknown): string | null => {
  if (typeof u !== "string" || !u) return null;
  const i = u.indexOf(PUB);
  const p = (i >= 0 ? u.slice(i + PUB.length) : u).split("?")[0];
  return p && !p.includes("..") && !p.startsWith("/") && !p.startsWith("http") ? decodeURIComponent(p) : null;
};

// ---------- Instagram ----------
async function g(path: string, params: Record<string, string>, method = "GET") {
  const qs = new URLSearchParams(params);
  const r = await fetch(method === "GET" ? `${GRAPH}/${path}?${qs}` : `${GRAPH}/${path}`, method === "GET" ? {} : { method, body: qs });
  const j = await r.json().catch(() => ({}));
  if (!r.ok || j.error) throw new Error(j?.error?.error_user_msg || j?.error?.message || `HTTP ${r.status}`);
  return j;
}
async function conf(sb: any, k: string) {
  const { data } = await sb.from("fila_config").select("v").eq("k", k).maybeSingle();
  return data?.v as string | undefined;
}
// aviso no celular do Rubão (app ntfy inscrito no tópico de fila_config.notify_url)
async function avisar(sb: any, titulo: string, msg: string) {
  try {
    const url = await conf(sb, "notify_url"); if (!url) return;
    await fetch(url, { method: "POST", body: msg, headers: { Title: titulo, Priority: "high", Tags: "warning", Click: "https://board.aurumcinema.com.br" } });
  } catch { /* aviso é best-effort */ }
}
const quem = (p: any) => `${String(p.num ?? "").padStart(2, "0")} ${p.filme || ""}`.trim() + (p.hora ? ` (${p.hora})` : "");
const horaDe = (p: any) => new Date(new Date(`${p.dia}T${p.hora}:00-03:00`).getTime());
const chegouHora = (p: any) => !p.dia || !p.hora || horaDe(p).getTime() <= Date.now() + 20e3; // 20 s de folga pro minuto do cron
// motivo do Instagram quando o container dá ERROR (status traz o código/mensagem)
async function motivo(id: string, tok: string, code: string) {
  try { const s = await g(id, { fields: "status", access_token: tok }); return `Instagram recusou o arquivo (${code}${s.status ? ": " + s.status : ""})`; }
  catch { return `Instagram recusou o arquivo (${code})`; }
}
// cria o container (Reels, foto, carrossel ou Story) e devolve o id
// destino é escolhido pelo Rubão no board (feed | story | feed_story); sem escolha o post nem é aprovado
const destinoDe = (p: any) => String(p.destino || "");
async function criarStory(ig: string, tok: string, p: any) {
  const f = ((p.arquivos ?? []) as any[])[0];
  if (!f) throw new Error("post sem arquivo");
  return (await g(`${ig}/media`, f.kind === "video" ? { media_type: "STORIES", video_url: f.url, access_token: tok } : { media_type: "STORIES", image_url: f.url, access_token: tok }, "POST")).id;
}
async function criarContainer(ig: string, tok: string, p: any) {
  const fs = (p.arquivos ?? []) as any[];
  const caption = (p.legenda_pc || p.legenda_celular || "").slice(0, 2200);
  if (!fs.length) throw new Error("post sem arquivo");
  if (destinoDe(p) === "story") {
    // Story: mesmo arquivo, sem legenda (o Instagram não usa legenda em Story). Não dá pra "compartilhar o post do feed" pela API.
    const f = fs[0];
    return (await g(`${ig}/media`, f.kind === "video" ? { media_type: "STORIES", video_url: f.url, access_token: tok } : { media_type: "STORIES", image_url: f.url, access_token: tok }, "POST")).id;
  }
  if (fs.length === 1) {
    const f = fs[0];
    if (f.kind === "video") {
      const prm: Record<string, string> = { media_type: "REELS", video_url: f.url, caption, share_to_feed: "true", access_token: tok };
      if (p.capa_ms != null) prm.thumb_offset = String(p.capa_ms); // capa escolhida (frame do vídeo, em ms)
      return (await g(`${ig}/media`, prm, "POST")).id;
    }
    return (await g(`${ig}/media`, { image_url: f.url, caption, access_token: tok }, "POST")).id;
  }
  const kids: string[] = [];
  for (const f of fs.slice(0, 10)) {
    const prm: Record<string, string> = { is_carousel_item: "true", access_token: tok };
    if (f.kind === "video") { prm.media_type = "VIDEO"; prm.video_url = f.url; } else prm.image_url = f.url;
    kids.push((await g(`${ig}/media`, prm, "POST")).id);
  }
  // espera os filhos de vídeo ficarem prontos (até ~50 s nesta chamada; senão o próximo ciclo tenta de novo)
  for (let t = 0; t < 10; t++) {
    const st = await Promise.all(kids.map((id) => g(id, { fields: "status_code", access_token: tok })));
    if (st.some((s) => s.status_code === "ERROR")) throw new Error("um item do carrossel deu erro no Instagram");
    if (st.every((s) => !s.status_code || s.status_code === "FINISHED")) break;
    await new Promise((r) => setTimeout(r, 5000));
  }
  return (await g(`${ig}/media`, { media_type: "CAROUSEL", children: kids.join(","), caption, access_token: tok }, "POST")).id;
}

async function marcarErro(sb: any, p: any, msg: string) {
  await sb.from("fila_posts").update({ ig_status: "erro", ig_erro: msg.slice(0, 300) }).eq("id", p.id);
  await avisar(sb, "AURUM · não postou", `${quem(p)}: ${msg}. Abre o board e toca em TENTAR DE NOVO.`);
}

async function publicar(sb: any) {
  const tok = await conf(sb, "meta_token"); const ig = await conf(sb, "meta_ig_user");
  if (!tok || !ig) return { erro: "sem token da Meta" };
  const log: unknown[] = [];
  // 1) containers já criados: publica quando o Instagram terminou E chegou o minuto marcado
  const { data: emAndamento } = await sb.from("fila_posts").select("*").eq("ig_status", "criando");
  for (const p of emAndamento ?? []) {
    if (!p.ig_container) continue; // outro ciclo ainda está criando
    try {
      const st = await g(p.ig_container, { fields: "status_code", access_token: tok });
      if (st.status_code === "ERROR" || st.status_code === "EXPIRED") {
        const m = await motivo(p.ig_container, tok, st.status_code);
        if (!p.ig_refeito) {
          // 1ª falha: o Instagram às vezes recusa à toa — cria o container de novo uma vez
          const c = await criarContainer(ig, tok, p);
          await sb.from("fila_posts").update({ ig_container: c, ig_refeito: true, ig_tentativas: 0, ig_erro: m.slice(0, 300) }).eq("id", p.id);
          log.push([p.id, "refazendo", m]); continue;
        }
        throw new Error(m);
      }
      if (st.status_code && st.status_code !== "FINISHED") {
        const n = (p.ig_tentativas ?? 0) + 1;
        if (n > 40) throw new Error("Instagram demorou demais pra processar");
        await sb.from("fila_posts").update({ ig_tentativas: n }).eq("id", p.id); log.push([p.id, "processando"]); continue;
      }
      if (!chegouHora(p)) { log.push([p.id, "pronto, esperando o horário"]); continue; }
      const pub = await g(`${ig}/media_publish`, { creation_id: p.ig_container, access_token: tok }, "POST");
      let link = null; try { link = (await g(pub.id, { fields: "permalink", access_token: tok })).permalink; } catch { /* sem link */ }
      await sb.from("fila_posts").update({ ig_status: "publicado", ig_media_id: pub.id, ig_permalink: link, ig_erro: null, postado: true, postado_em: new Date().toISOString() }).eq("id", p.id);
      log.push([p.id, "publicado"]);
      if (destinoDe(p) === "feed_story" && !p.ig_story_status) {
        try { const sc = await criarStory(ig, tok, p); await sb.from("fila_posts").update({ ig_story_status: "criando", ig_story_container: sc }).eq("id", p.id); log.push([p.id, "story container"]); }
        catch (e) { const m = String((e as Error).message); await sb.from("fila_posts").update({ ig_story_status: "erro", ig_story_erro: m.slice(0, 300) }).eq("id", p.id); await avisar(sb, "AURUM · Story não saiu", `${quem(p)}: o post saiu no feed, mas o Story deu erro (${m}).`); }
      }
    } catch (e) {
      const m = String((e as Error).message);
      await marcarErro(sb, p, m);
      log.push([p.id, "erro", m]);
    }
  }
  // Story que o Rubão mandou TENTAR DE NOVO no board (ig_story_status = 'refazer'): cria o container de novo
  const { data: refazer } = await sb.from("fila_posts").select("*").eq("ig_story_status", "refazer");
  for (const p of refazer ?? []) {
    try { const sc = await criarStory(ig, tok, p); await sb.from("fila_posts").update({ ig_story_status: "criando", ig_story_container: sc, ig_story_erro: null }).eq("id", p.id); log.push([p.id, "story refeito"]); }
    catch (e) { const m = String((e as Error).message); await sb.from("fila_posts").update({ ig_story_status: "erro", ig_story_erro: m.slice(0, 300) }).eq("id", p.id); await avisar(sb, "AURUM · Story não saiu", `${quem(p)}: o Story deu erro de novo (${m}).`); }
  }
  // Story do "feed + story": publica quando o Instagram terminar de processar
  const { data: stories } = await sb.from("fila_posts").select("id, num, filme, hora, ig_story_container").eq("ig_story_status", "criando");
  for (const p of stories ?? []) {
    try {
      const st = await g(p.ig_story_container, { fields: "status_code", access_token: tok });
      if (st.status_code === "ERROR" || st.status_code === "EXPIRED") throw new Error(await motivo(p.ig_story_container, tok, st.status_code));
      if (st.status_code && st.status_code !== "FINISHED") continue;
      const pub = await g(`${ig}/media_publish`, { creation_id: p.ig_story_container, access_token: tok }, "POST");
      await sb.from("fila_posts").update({ ig_story_status: "publicado", ig_story_id: pub.id, ig_story_erro: null }).eq("id", p.id);
      log.push([p.id, "story publicado"]);
    } catch (e) {
      const m = String((e as Error).message);
      await sb.from("fila_posts").update({ ig_story_status: "erro", ig_story_erro: m.slice(0, 300) }).eq("id", p.id);
      await avisar(sb, "AURUM · Story não saiu", `${quem(p)}: o post saiu no feed, mas o Story deu erro (${m}).`);
    }
  }
  // 2) aprovados que saem nos próximos ANTECEDENCIA_MIN minutos (ou atrasados): cria o container já, publica no minuto certo
  const { data: proximos } = await sb.rpc("fila_proximos", { p_min: ANTECEDENCIA_MIN });
  for (const p of (proximos ?? []).slice(0, 3)) {
    // trava: só segue se ninguém pegou esse post ainda
    const { data: pego } = await sb.from("fila_posts").update({ ig_status: "criando", ig_tentativas: 0 }).eq("id", p.id).is("ig_status", null).eq("aprovado", true).eq("postado", false).select("id");
    if (!pego?.length) continue;
    try {
      const c = await criarContainer(ig, tok, p);
      await sb.from("fila_posts").update({ ig_container: c }).eq("id", p.id);
      log.push([p.id, "container", c]);
    } catch (e) {
      const m = String((e as Error).message);
      await marcarErro(sb, p, m);
      log.push([p.id, "erro", m]);
    }
  }
  return { log };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method" }, 405);
  const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, { auth: { persistSession: false } });
  let body: any = {};
  try { body = await req.json(); } catch { return json({ error: "json" }, 400); }

  if (["sign", "upsert", "set_meta", "varrer", "feed"].includes(body.action)) {
    const { data: ok } = await sb.rpc("fila_token_ok", { p_token: body.token });
    if (!ok) return json({ error: "token" }, 401);
  }

  if (body.action === "sign") {
    const paths: string[] = Array.isArray(body.paths) ? body.paths.slice(0, 20) : [];
    const out: Record<string, unknown> = {};
    for (const p of paths) {
      if (typeof p !== "string" || p.includes("..") || p.startsWith("/")) { out[p] = { error: "path" }; continue; }
      const { data, error } = await sb.storage.from(BUCKET).createSignedUploadUrl(p, { upsert: true });
      out[p] = error ? { error: error.message } : data;
    }
    return json({ urls: out });
  }

  if (body.action === "upsert") {
    // conteúdo sempre; dia/hora são SÓ sugestão: entram se o post ainda não tem e não foi aprovado (o Rubão manda)
    const raw = (Array.isArray(body.posts) ? body.posts : []).slice(0, 50);
    const posts = raw.map((p: any) => {
      const o: Record<string, unknown> = {};
      for (const k of CAMPOS) if (k in p) o[k] = p[k];
      return o;
    }).filter((o: any) => typeof o.id === "string" && o.id);
    const { error } = await sb.from("fila_posts").upsert(posts, { onConflict: "id" });
    if (error) return json({ error: error.message }, 500);
    for (const p of raw) {
      if (!p?.id) continue;
      if (typeof p.dia === "string" && /^\d{4}-\d{2}-\d{2}$/.test(p.dia)) await sb.from("fila_posts").update({ dia: p.dia }).eq("id", p.id).is("dia", null).eq("aprovado", false);
      if (typeof p.hora === "string" && /^([01]\d|2[0-3]):[0-5]\d$/.test(p.hora)) await sb.from("fila_posts").update({ hora: p.hora }).eq("id", p.id).is("hora", null).eq("aprovado", false);
    }
    return json({ ok: posts.length });
  }

  if (body.action === "varrer" || body.action === "feed") {
    // varredura das distribuidoras (business_discovery) e feed do próprio AURUM (com alcance/interações se insights=true) — o token da Meta nunca sai do servidor
    const tok = await conf(sb, "meta_token"); const ig = await conf(sb, "meta_ig_user");
    if (!tok || !ig) return json({ error: "sem token da Meta" }, 500);
    if (body.action === "feed") {
      const n = Math.min(Number(body.limit) || 60, 100);
      try { const f = "timestamp,media_type,media_product_type,caption,permalink,like_count,comments_count" + (body.insights ? ",insights.metric(reach,total_interactions,saved,shares)" : "");
        const d = await g(`${ig}/media`, { fields: f, limit: String(n), access_token: tok });
        return json({ media: d.data || [] }); } catch (e) { return json({ error: String((e as Error).message) }, 400); }
    }
    const users: string[] = (Array.isArray(body.users) ? body.users : []).filter((u: any) => typeof u === "string" && /^[A-Za-z0-9._]{1,30}$/.test(u)).slice(0, 15);
    const n = Math.min(Number(body.limit) || 12, 30), out: Record<string, unknown> = {};
    for (const u of users) {
      try { const d = await g(ig, { fields: `business_discovery.username(${u}){media.limit(${n}){permalink,media_type,media_product_type,timestamp,caption,children{media_type}}}`, access_token: tok });
        out[u] = d.business_discovery?.media?.data || []; } catch (e) { out[u] = { error: String((e as Error).message) }; }
    }
    return json({ contas: out });
  }

  if (body.action === "set_meta") {
    // guarda o token da Meta (vem do PC do Rubão) e confere se enxerga o Instagram
    const t = String(body.meta_token || "").trim(), ig = String(body.ig_user || "").trim();
    if (!t || !/^\d+$/.test(ig)) return json({ error: "dados" }, 400);
    try { const me = await g(ig, { fields: "username", access_token: t });
      await sb.from("fila_config").upsert([{ k: "meta_token", v: t }, { k: "meta_ig_user", v: ig }], { onConflict: "k" });
      return json({ ok: true, username: me.username });
    } catch (e) { return json({ error: String((e as Error).message) }, 400); }
  }

  if (body.action === "publicar") {
    // roda de 5 em 5 min (todos os horários do board são múltiplos de 5 e o container é criado até 15 min antes,
    // então sai no minuto certo). Protege o banco grátis (pouco disco/CPU): o pg_cron pode chamar a cada minuto, mas só os múltiplos de 5 trabalham.
    if (new Date().getUTCMinutes() % 5 !== 0) return json({ skip: true });
    const key = await conf(sb, "cron_key");
    if (!key || body.key !== key) return json({ error: "key" }, 401);
    return json(await publicar(sb));
  }

  if (body.action === "delete") {
    // os arquivos saem do storage; a linha NÃO sai do banco (gatilho fila_posts_nao_apaga transforma o DELETE em arquivar = histórico)
    const { data: ok } = await sb.rpc("fila_ok", { p_pin: body.pin });
    if (!ok) return json({ error: "pin" }, 401);
    if (typeof body.id !== "string" || !body.id) return json({ error: "id" }, 400);
    const { data: row, error } = await sb.from("fila_posts").select("id, arquivos").eq("id", body.id).maybeSingle();
    if (error) return json({ error: error.message }, 500);
    if (!row) return json({ ok: true, apagados: 0 });
    const paths = new Set<string>();
    for (const a of (row.arquivos ?? []) as any[]) for (const v of [a?.path, a?.url, a?.poster]) { const p = toPath(v); if (p) paths.add(p); }
    if (paths.size) {
      const { error: e2 } = await sb.storage.from(BUCKET).remove([...paths]);
      if (e2) return json({ error: e2.message }, 500);
    }
    const { error: e3 } = await sb.from("fila_posts").delete().eq("id", body.id);
    return e3 ? json({ error: e3.message }, 500) : json({ ok: true, apagados: paths.size });
  }

  if (body.action === "cleanup") {
    // vale a senha da fila (board) ou a cron_key (pg_cron diário)
    const key = await conf(sb, "cron_key");
    const { data: ok } = await sb.rpc("fila_ok", { p_pin: body.pin });
    if (!ok && !(key && body.key === key)) return json({ error: "pin" }, 401);
    const limite = new Date(Date.now() - DIAS_LIMPEZA * 864e5).toISOString();
    // postados há mais de DIAS_LIMPEZA dias + arquivados/rejeitados (lixeira do board) que ainda têm arquivo
    const { data: rows, error } = await sb.from("fila_posts").select("id, arquivos")
      .eq("arquivos_apagados", false).or(`and(postado.eq.true,postado_em.lt."${limite}"),arquivado.eq.true`);
    if (error) return json({ error: error.message }, 500);
    let apagados = 0;
    for (const r of rows ?? []) {
      const paths = new Set<string>();
      for (const a of (r.arquivos ?? []) as any[]) for (const v of [a?.path, a?.poster]) { const p = toPath(v); if (p) paths.add(p); }
      if (paths.size) {
        const { error: e2 } = await sb.storage.from(BUCKET).remove([...paths]);
        if (e2) continue;
      }
      await sb.from("fila_posts").update({ arquivos_apagados: true }).eq("id", r.id);
      apagados++;
    }
    return json({ apagados });
  }

  return json({ error: "action" }, 400);
});
