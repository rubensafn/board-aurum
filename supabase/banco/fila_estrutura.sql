-- CÓPIA DE SEGURANÇA da estrutura do BOARD no banco (Supabase gdtfwmqbvsqtxtccrydv) — gerada em 25/11/2026.
-- Só tabelas/funções/gatilhos fila_*. SEM senha, token, cron_key ou meta_token (ficam em fila_config, não aqui).
-- NADA do sistema de CORTESIAS (mesmo banco). Mudou o banco do board → regerar este arquivo no mesmo commit.
-- Jobs pg_cron: 'fila-limpar' (17 7 * * *) → fila-admin {action:'cleanup', key: cron_key} (limpa arquivos + recalcula fila_config.horarios);
--               'fila_toque_*' = um disparo por post aprovado (criado por fila_agendar_toque).

create table if not exists public.fila_config (
  k text not null primary key,
  v text not null
);

create table if not exists public.fila_filmes (
  chave text not null primary key,
  titulo text not null,
  poster text,
  estreia date,
  origem text not null default 'site'::text,
  no_site boolean not null default true,
  ativo boolean not null default true,
  mexido boolean not null default false,
  visto_em timestamp with time zone default now(),
  created_at timestamp with time zone default now()
);

create table if not exists public.fila_posts (
  id text not null primary key,
  num integer,
  nome text,
  filme text,
  tipo text,
  lote text,
  legenda_celular text,
  legenda_pc text,
  comprimido boolean not null default false,
  arquivos jsonb not null default '[]'::jsonb,
  dia date,
  postado boolean not null default false,
  postado_em timestamp with time zone,
  arquivos_apagados boolean not null default false,
  created_at timestamp with time zone not null default now(),
  hora text,
  aprovado boolean not null default false,
  aprovado_em timestamp with time zone,
  ig_status text,
  ig_container text,
  ig_media_id text,
  ig_permalink text,
  ig_erro text,
  ig_tentativas integer not null default 0,
  destino text,
  ig_story_status text,
  ig_story_container text,
  ig_story_id text,
  ig_story_erro text,
  aviso text,
  capa_ms integer,
  arquivado boolean not null default false,
  arquivado_em timestamp with time zone,
  manual boolean not null default false,
  ig_refeito boolean not null default false,
  legenda_refazer boolean not null default false,
  legenda_pedido text,
  legenda_editada_em timestamp with time zone,
  subido boolean not null default false,
  selo_pendente boolean not null default false,
  ajuste_pedido text,
  ajuste_em timestamp with time zone,
  ajuste_resposta text,
  a_fazer boolean not null default false,
  link_origem text,
  pedido_arte text,
  seguir_padrao boolean
);

create table if not exists public.fila_vistos (
  shortcode text not null primary key,
  conta text,
  permalink text,
  filme text,
  status text not null,
  motivo text,
  post_id text,
  postado_distribuidora timestamp with time zone,
  visto_em timestamp with time zone not null default now(),
  caption text,
  quero boolean not null default false,
  quero_em timestamp with time zone
);

CREATE OR REPLACE FUNCTION public.fila_ok(p_pin text) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$ select exists(select 1 from public.fila_config where k='pin_hash' and v = extensions.crypt(coalesce(p_pin,''), v)); $function$;

CREATE OR REPLACE FUNCTION public.fila_token_ok(p_token text) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$ select exists(select 1 from public.fila_config where k='token_hash' and v = extensions.crypt(coalesce(p_token,''), v)); $function$;

CREATE OR REPLACE FUNCTION public.fila_agendar_toque(p_quando timestamp with time zone) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
declare t timestamptz; nome text; cmd text;
begin
  t := date_trunc('minute', greatest(p_quando, now() + interval '1 minute'));
  nome := 'fila_toque_' || to_char(t at time zone 'UTC', 'YYYYMMDDHH24MI');
  cmd := format($c$select cron.unschedule(%L); select net.http_post(url := 'https://gdtfwmqbvsqtxtccrydv.supabase.co/functions/v1/fila-admin', headers := '{"Content-Type":"application/json"}'::jsonb, body := jsonb_build_object('action','publicar','key',(select v from public.fila_config where k='cron_key')), timeout_milliseconds := 120000);$c$, nome);
  perform cron.schedule(nome, format('%s %s %s %s *',
    extract(minute from t at time zone 'UTC')::int, extract(hour from t at time zone 'UTC')::int,
    extract(day from t at time zone 'UTC')::int, extract(month from t at time zone 'UTC')::int), cmd);
end $function$;

CREATE OR REPLACE FUNCTION public.fila_tocar_em(p_min integer) RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path TO 'public'
AS $function$ select public.fila_agendar_toque(now() + make_interval(mins => greatest(p_min,1))); $function$;

CREATE OR REPLACE FUNCTION public.fila_apagar(p_pin text, p_id text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if exists(select 1 from public.fila_posts where id = p_id and ig_status = 'criando') then
    raise exception 'post sendo publicado agora' using errcode = 'P0001';
  end if;
  perform set_config('fila.manter_arquivos', 'on', true);
  delete from public.fila_posts where id = p_id;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_arquivar_postados(p_pin text) RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
declare n integer;
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  update public.fila_posts set arquivado = true, arquivado_em = now() where postado and not arquivado;
  get diagnostics n = row_count;
  return n;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_filme_add(p_pin text, p_chave text, p_titulo text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if coalesce(trim(p_titulo),'') = '' or coalesce(p_chave,'') = '' then raise exception 'titulo' using errcode = 'P0001'; end if;
  insert into public.fila_filmes(chave, titulo, origem, no_site, ativo, mexido)
  values (p_chave, left(trim(p_titulo),120), 'manual', false, true, true)
  on conflict (chave) do update set ativo = true, mexido = true;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_filme_del(p_pin text, p_chave text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  delete from public.fila_filmes where chave = p_chave and origem = 'manual';
end $function$;

CREATE OR REPLACE FUNCTION public.fila_filme_set(p_pin text, p_chave text, p_ativo boolean) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  update public.fila_filmes set ativo = p_ativo, mexido = true where chave = p_chave;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_filmes_list(p_pin text) RETURNS SETOF fila_filmes LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  return query select * from public.fila_filmes where no_site or origem = 'manual' order by estreia nulls last, titulo;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_horarios(p_pin text) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  return (select v::jsonb from public.fila_config where k = 'horarios');
end $function$;

CREATE OR REPLACE FUNCTION public.fila_list(p_pin text) RETURNS SETOF jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  return query select to_jsonb(p) || coalesce((select jsonb_build_object('postado_distribuidora', v.postado_distribuidora, 'tem_peca', true)
      from public.fila_vistos v where v.post_id = p.id order by v.visto_em desc limit 1), '{"tem_peca":false}'::jsonb)
    from public.fila_posts p where not p.arquivado order by p.lote desc, p.num asc;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_mandar_reserva(p_pin text, p_id text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if not exists (select 1 from public.fila_vistos where post_id = p_id) then raise exception 'sem peca' using errcode = 'P0001'; end if;
  update public.fila_posts set arquivado = true, arquivado_em = now()
   where id = p_id and not aprovado and not postado and coalesce(ig_status,'') = '';
  if not found then raise exception 'nao pendente' using errcode = 'P0001'; end if;
  update public.fila_vistos set status = 'reserva', post_id = null, motivo = 'voltou pra reserva pelo board', quero = false, quero_em = null where post_id = p_id;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_novo_link(p_pin text, p_link text, p_filme text, p_pedido text, p_padrao boolean, p_destino text, p_dia date, p_hora text, p_legenda text, p_pedir_legenda boolean, p_pedido_legenda text) RETURNS text LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
declare v_lote text := to_char(now() at time zone 'America/Sao_Paulo','DD.MM'); v_id text; v_num int;
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if p_link is null or p_link !~* '^https?://(www\.)?instagram\.com/(p|reel|reels|tv)/[A-Za-z0-9_-]+' then raise exception 'link' using errcode = 'P0001'; end if;
  if p_destino is not null and p_destino not in ('feed','story','feed_story') then raise exception 'destino' using errcode = 'P0001'; end if;
  if p_hora is not null and p_hora !~ '^([01]\d|2[0-3]):[0-5]\d$' then raise exception 'hora' using errcode = 'P0001'; end if;
  select coalesce(max(num),0)+1 into v_num from public.fila_posts where lote = v_lote;
  v_id := replace(v_lote,'.','-') || '_L' || to_char(clock_timestamp(),'HH24MISSMS');
  insert into public.fila_posts(id, num, nome, filme, tipo, lote, legenda_celular, legenda_pc, arquivos, destino, dia, hora, subido, selo_pendente, legenda_refazer, legenda_pedido, a_fazer, link_origem, pedido_arte, seguir_padrao)
  values (v_id, v_num, 'LINK', nullif(trim(p_filme),''), 'POST', v_lote, nullif(p_legenda,''), nullif(p_legenda,''), '[]'::jsonb, p_destino, p_dia, p_hora, true, false,
          coalesce(p_pedir_legenda,false) or nullif(p_legenda,'') is null, case when coalesce(p_pedir_legenda,false) then nullif(trim(coalesce(p_pedido_legenda,'')),'') end,
          true, trim(p_link), nullif(trim(coalesce(p_pedido,'')),''), coalesce(p_padrao, true));
  return v_id;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_novo_post(p_pin text, p_filme text, p_arquivos jsonb, p_legenda text, p_pedir_legenda boolean, p_pedido text, p_destino text, p_dia date, p_hora text, p_selo boolean) RETURNS text LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
declare v_lote text := to_char(now() at time zone 'America/Sao_Paulo','DD.MM'); v_id text; v_num int; v_nome text; v_tipo text; v_f jsonb;
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if p_arquivos is null or jsonb_typeof(p_arquivos) <> 'array' or jsonb_array_length(p_arquivos) = 0 then raise exception 'arquivo' using errcode = 'P0001'; end if;
  if p_selo is null then raise exception 'selo' using errcode = 'P0001'; end if;
  if p_destino not in ('feed','story','feed_story') then raise exception 'destino' using errcode = 'P0001'; end if;
  if p_hora is not null and p_hora !~ '^([01]\d|2[0-3]):[0-5]\d$' then raise exception 'hora' using errcode = 'P0001'; end if;
  v_f := p_arquivos->0;
  v_tipo := case when jsonb_array_length(p_arquivos) > 1 then 'CARROSSEL' when v_f->>'kind' = 'video' then 'VIDEO' else 'POST' end;
  select coalesce(max(num),0)+1 into v_num from public.fila_posts where lote = v_lote;
  v_id := replace(v_lote,'.','-') || '_U' || to_char(clock_timestamp(),'HH24MISSMS');
  v_nome := regexp_replace(coalesce(v_f->>'nome','POST'), '\.[A-Za-z0-9]+$', '');
  insert into public.fila_posts(id, num, nome, filme, tipo, lote, legenda_celular, legenda_pc, arquivos, destino, dia, hora, subido, selo_pendente, legenda_refazer, legenda_pedido)
  values (v_id, v_num, v_nome, nullif(trim(p_filme),''), v_tipo, v_lote, nullif(p_legenda,''), nullif(p_legenda,''), p_arquivos, p_destino, p_dia, p_hora, true, p_selo,
          coalesce(p_pedir_legenda,false), case when coalesce(p_pedir_legenda,false) then nullif(trim(coalesce(p_pedido,'')),'') end);
  return v_id;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_pedir_ajuste(p_pin text, p_id text, p_pedido text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
declare v text := nullif(trim(coalesce(p_pedido,'')),'');
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if exists(select 1 from public.fila_posts where id = p_id and (postado or coalesce(ig_status,'') in ('criando','publicado'))) then
    raise exception 'post ja esta indo pro instagram' using errcode = 'P0001';
  end if;
  if v is null then
    update public.fila_posts set ajuste_pedido = null, ajuste_em = null where id = p_id;
  else
    update public.fila_posts set ajuste_pedido = v, ajuste_em = now(), ajuste_resposta = null, aprovado = false, aprovado_em = null where id = p_id;
  end if;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_pedir_legenda(p_pin text, p_id text, p_pedido text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if exists(select 1 from public.fila_posts where id = p_id and (postado or coalesce(ig_status,'') in ('criando','publicado'))) then
    raise exception 'post ja esta indo pro instagram' using errcode = 'P0001';
  end if;
  update public.fila_posts set legenda_refazer = p_pedido is not null, legenda_pedido = case when p_pedido is null then null else nullif(trim(p_pedido),'') end where id = p_id;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_posts_agenda() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
declare h timestamptz;
begin
  if new.aprovado and not new.postado and not new.manual and not new.arquivado and new.ig_status is null
     and new.dia is not null and new.hora is not null and new.destino is not null
     and (tg_op = 'INSERT' or old.aprovado is distinct from new.aprovado or old.dia is distinct from new.dia
          or old.hora is distinct from new.hora or old.ig_status is distinct from new.ig_status or old.destino is distinct from new.destino) then
    h := (new.dia + new.hora::time) at time zone 'America/Sao_Paulo';
    perform public.fila_agendar_toque(h - interval '15 minutes');
    perform public.fila_agendar_toque(h);
    perform public.fila_agendar_toque(h + interval '2 minutes');
  end if;
  return null;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_posts_arquiva_em_vez_de_apagar() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
begin
  if coalesce(current_setting('fila.apagar_de_vez', true), '') = 'on' then return old; end if;
  update public.fila_posts set arquivado = true, arquivado_em = coalesce(arquivado_em, now()),
    arquivos_apagados = case when coalesce(current_setting('fila.manter_arquivos', true), '') = 'on' then arquivos_apagados else true end
  where id = old.id;
  if not coalesce(old.postado, false) then
    update public.fila_vistos set status = 'rejeitado', motivo = 'rejeitado no board (apagado sem postar)' where post_id = old.id;
  end if;
  return null;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_posts_trava_afazer() RETURNS trigger LANGUAGE plpgsql
AS $function$
begin
  if new.aprovado and new.a_fazer then raise exception 'post ainda A FAZER' using errcode = 'P0001'; end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_proximos(p_min integer) RETURNS SETOF fila_posts LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public'
AS $function$
  select * from public.fila_posts
  where aprovado and not postado and not manual and not arquivado and ig_status is null and dia is not null and hora is not null and destino is not null
    and ((dia + hora::time) at time zone 'America/Sao_Paulo') <= now() + make_interval(mins => p_min)
  order by dia, hora, num;
$function$;

CREATE OR REPLACE FUNCTION public.fila_vencidos() RETURNS SETOF fila_posts LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public'
AS $function$
  select * from public.fila_posts
  where aprovado and not postado and not manual and ig_status is null and dia is not null and hora is not null and destino is not null
    and ((dia + hora::time) at time zone 'America/Sao_Paulo') <= now()
  order by dia, hora, num;
$function$;

CREATE OR REPLACE FUNCTION public.fila_refazer_story(p_pin text, p_id text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  update public.fila_posts set ig_story_status = 'refazer', ig_story_erro = null where id = p_id and ig_status = 'publicado' and ig_story_status = 'erro';
  if found then perform public.fila_agendar_toque(now()); end if;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_reserva_quero(p_pin text, p_shortcode text, p_quero boolean) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  update public.fila_vistos set quero = p_quero, quero_em = case when p_quero then now() else null end where shortcode = p_shortcode and status = 'reserva';
end $function$;

CREATE OR REPLACE FUNCTION public.fila_reserva_rejeitar(p_pin text, p_shortcode text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  update public.fila_vistos set status = 'rejeitado', quero = false, quero_em = null, motivo = 'rejeitado pelo Rubão na aba RESV' where shortcode = p_shortcode and status = 'reserva';
end $function$;

CREATE OR REPLACE FUNCTION public.fila_reservas_excluir_todas(p_pin text) RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
declare n integer;
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  update public.fila_vistos set status = 'rejeitado', quero = false, quero_em = null, motivo = 'excluído pelo Rubão (EXCLUIR TODAS na aba RESV)' where status = 'reserva';
  get diagnostics n = row_count;
  return n;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_reservas_list(p_pin text) RETURNS TABLE(shortcode text, conta text, permalink text, filme text, motivo text, caption text, postado_distribuidora timestamp with time zone, visto_em timestamp with time zone, quero boolean, quero_em timestamp with time zone) LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  return query select v.shortcode, v.conta, v.permalink, v.filme, v.motivo, v.caption, v.postado_distribuidora, v.visto_em, v.quero, v.quero_em
    from public.fila_vistos v where v.status = 'reserva' order by v.quero desc, v.postado_distribuidora desc nulls last limit 80;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_set_aprovado(p_pin text, p_id text, p_aprovado boolean) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if p_aprovado and exists(select 1 from public.fila_posts where id=p_id and (dia is null or hora is null or destino is null)) then
    raise exception 'falta dia, horario ou destino' using errcode = 'P0001';
  end if;
  update public.fila_posts set aprovado = p_aprovado, aprovado_em = case when p_aprovado then now() else null end,
    ig_erro = case when p_aprovado then null else ig_erro end,
    ig_status = case when p_aprovado and ig_status = 'erro' then null else ig_status end,
    ig_refeito = case when p_aprovado then false else ig_refeito end
  where id = p_id and coalesce(ig_status,'') not in ('criando','publicado');
end $function$;

CREATE OR REPLACE FUNCTION public.fila_set_destino(p_pin text, p_id text, p_destino text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if p_destino is not null and p_destino not in ('feed','story','feed_story') then raise exception 'destino invalido'; end if;
  update public.fila_posts set destino = p_destino where id = p_id and not aprovado and coalesce(ig_status,'') not in ('criando','publicado');
end $function$;

CREATE OR REPLACE FUNCTION public.fila_set_dia(p_pin text, p_id text, p_dia date) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if p_dia is null and exists(select 1 from public.fila_posts where id=p_id and aprovado) then raise exception 'aprovado precisa de dia' using errcode='P0001'; end if;
  update public.fila_posts set dia = p_dia where id = p_id and coalesce(ig_status,'') not in ('criando','publicado');
end $function$;

CREATE OR REPLACE FUNCTION public.fila_set_hora(p_pin text, p_id text, p_hora text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if p_hora is not null and p_hora !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$' then raise exception 'hora invalida'; end if;
  if p_hora is null and exists(select 1 from public.fila_posts where id=p_id and aprovado) then raise exception 'aprovado precisa de horario' using errcode='P0001'; end if;
  update public.fila_posts set hora = p_hora where id = p_id and coalesce(ig_status,'') not in ('criando','publicado');
end $function$;

CREATE OR REPLACE FUNCTION public.fila_set_legenda(p_pin text, p_id text, p_celular text, p_pc text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  if exists(select 1 from public.fila_posts where id = p_id and (postado or coalesce(ig_status,'') in ('criando','publicado'))) then
    raise exception 'post ja esta indo pro instagram' using errcode = 'P0001';
  end if;
  update public.fila_posts set legenda_celular = nullif(p_celular,''), legenda_pc = nullif(p_pc,''),
    legenda_editada_em = now(), legenda_refazer = false, legenda_pedido = null where id = p_id;
end $function$;

CREATE OR REPLACE FUNCTION public.fila_set_postado(p_pin text, p_id text, p_postado boolean) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public', 'extensions'
AS $function$
begin
  if not public.fila_ok(p_pin) then raise exception 'senha invalida' using errcode = '28000'; end if;
  update public.fila_posts set postado = p_postado, postado_em = case when p_postado then now() else null end where id = p_id;
end $function$;

CREATE TRIGGER fila_posts_agenda AFTER INSERT OR UPDATE OF aprovado, dia, hora, ig_status, destino ON public.fila_posts FOR EACH ROW EXECUTE FUNCTION fila_posts_agenda();
CREATE TRIGGER fila_posts_nao_apaga BEFORE DELETE ON public.fila_posts FOR EACH ROW EXECUTE FUNCTION fila_posts_arquiva_em_vez_de_apagar();
CREATE TRIGGER fila_posts_trava_afazer BEFORE INSERT OR UPDATE OF aprovado, a_fazer ON public.fila_posts FOR EACH ROW EXECUTE FUNCTION fila_posts_trava_afazer();
-- Permissões: as RPCs com senha têm execute para anon/authenticated; tabelas fechadas (só via RPC/service_role).
