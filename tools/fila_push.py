#!/usr/bin/env python3
"""Sobe um lote pra FILA DE POSTS (board.aurumcinema.com.br).
CÓPIA: o principal é claude/fila-de-posts/fila_push.py do projeto AURUM EDITS (é o que a varredura usa). Os dois são iguais.

Uso:  FILA_TOKEN=... python3 fila_push.py lote.json

lote.json = {"lote": "11-11", "posts": [
  {"num": 1, "nome": "01_CARA_DE_BARRO_PERRENGUES_1080X1440", "filme": "Cara-de-Barro",
   "tipo": "VIDEO", "legenda_celular": "...", "legenda_pc": "...", "comprimido": false,
   "files": ["/caminho/01_CARA_DE_BARRO_PERRENGUES_1080X1440.mp4"]}, ...]}

- "capa": "/caminho/capa.jpg" (opcional, no post de vídeo) = capa do Reels pronta com selo AU; vai como cover_url.
- Cada arquivo até 50 MB (limite do plano grátis). Carrossel = vários arquivos no mesmo post, na ordem.
- Dia e "postado" não são enviados: quem define é o Rubão no app.
- ALTERAÇÃO (14/11): cada post tem pasta FIXA no bucket (<lote>/<lote>_<num>/). Subir de novo o mesmo
  lote+num SOBRESCREVE os arquivos da versão anterior (x-upsert) e substitui o post. Não cria post nem
  arquivo duplicado. Manter o MESMO nome de arquivo entre versões. A URL leva ?v=<hora> pra não mostrar
  a versão antiga em cache.
"""
import json, os, subprocess, sys, time, urllib.request

URL = "https://gdtfwmqbvsqtxtccrydv.supabase.co"
FN = URL + "/functions/v1/fila-admin"
BUCKET = "fila-posts"
MAX = 50 * 1024 * 1024
MIME = {".mp4": "video/mp4", ".mov": "video/quicktime", ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp"}


def call(payload):
    req = urllib.request.Request(FN, data=json.dumps(payload).encode(), headers={"Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.loads(r.read())


def put(token, path, local, mime):
    signed = call({"action": "sign", "token": token, "paths": [path]})["urls"][path]
    if "error" in signed:
        sys.exit(f"erro ao assinar {path}: {signed['error']}")
    up = signed["signedUrl"] if signed["signedUrl"].startswith("http") else URL + "/storage/v1" + signed["signedUrl"]
    r = subprocess.run(["curl", "-sS", "-f", "-X", "PUT", "-H", f"Content-Type: {mime}", "-H", "x-upsert: true", "--data-binary", "@" + local, up], capture_output=True, text=True)
    if r.returncode:
        sys.exit(f"falha no upload de {local}: {r.stderr or r.stdout}")
    return f"{URL}/storage/v1/object/public/{BUCKET}/{path}?v={int(time.time())}"


def dims(f):
    out = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height", "-of", "csv=p=0", f], capture_output=True, text=True).stdout.strip()
    try:
        w, h = out.split(",")[:2]; return int(w), int(h)
    except Exception:
        return None, None


def main():
    token = os.environ.get("FILA_TOKEN") or sys.exit("defina FILA_TOKEN")
    spec = json.load(open(sys.argv[1]))
    lote = spec["lote"]
    rows = []
    for p in spec["posts"]:
        pid = f"{lote}_{int(p['num']):02d}"
        folder = f"{lote}/{pid}"  # pasta fixa por post: versão nova sobrescreve a antiga
        arquivos = []
        for f in p["files"]:
            ext = os.path.splitext(f)[1].lower()
            size = os.path.getsize(f)
            if size > MAX:
                sys.exit(f"{os.path.basename(f)} tem {size/1048576:.1f} MB (máx. 50 MB): gere uma versão menor e marque comprimido")
            path = f"{folder}/{os.path.basename(f)}"
            url = put(token, path, f, MIME.get(ext, "application/octet-stream"))
            is_video = ext in (".mp4", ".mov")
            w, h = dims(f)
            poster = url
            if is_video:  # capa pequena pra lista (o board não carrega o vídeo na lista)
                base = os.path.splitext(os.path.basename(f))[0]
                thumb = f"/tmp/{base}_THUMB.jpg"
                subprocess.run(["ffmpeg", "-v", "error", "-y", "-ss", "1.2", "-i", f, "-frames:v", "1", "-vf", "scale=360:-2", "-q:v", "4", thumb], check=True)
                poster = put(token, f"{folder}/{base}_THUMB.jpg", thumb, "image/jpeg")
            item = {"path": path, "url": url, "poster": poster, "w": w, "h": h,
                    "nome": os.path.basename(f), "kind": "video" if is_video else "image"}
            if is_video and p.get("capa") and not any(a.get("capa") for a in arquivos):
                # capa do Reels pronta (frame da cena + selo AU mais pra cima) -> o fila-admin manda como cover_url
                base = os.path.splitext(os.path.basename(f))[0]
                item["capa"] = put(token, f"{folder}/{base}_CAPA.jpg", p["capa"], "image/jpeg")
            arquivos.append(item)
            print("ok", os.path.basename(f), f"{size/1048576:.1f} MB")
        row = {k: p[k] for k in ("num", "nome", "filme", "tipo", "legenda_celular", "legenda_pc") if k in p}
        row.update(id=pid, lote=lote.replace("-", "."), comprimido=bool(p.get("comprimido")), arquivos=arquivos)
        rows.append(row)
    res = call({"action": "upsert", "token": token, "posts": rows})
    print("fila:", res)


if __name__ == "__main__":
    main()
