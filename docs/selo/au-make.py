"""CÓPIA — o principal é claude/au-make.py do projeto AURUM EDITS.
Selo AU (padrão 25/10/2026) — posts de 26/10.
Uso: python3 make.py [--only nome] ; precisa de au.svg (AURUM_ENAGRAMA_AU.svg branco) nesta pasta.
Sem au.svg, gera um AU provisório só pra testar posição (PROVISORIO no nome de saída)."""
import os, sys, subprocess, base64, glob
from PIL import Image, ImageDraw
from playwright.sync_api import sync_playwright

HERE = os.path.dirname(os.path.abspath(__file__))
IN = sys.argv[1] if len(sys.argv) > 1 and not sys.argv[1].startswith('--') else os.environ['AU_IN']
OUT = os.environ.get('AU_OUT', os.path.join(HERE, 'out'))
AU = os.path.join(HERE, 'au.svg')
PROV = not os.path.exists(AU)

# cor: (tinta, borda, glow)
C = {
 'streetfighter': ('rgba(255,72,12,0.64)', 'rgb(255,150,70)', 'rgba(255,80,16,0.55)'),
 'caradebarro':   ('rgba(196,0,12,0.66)', 'rgb(255,36,48)', 'rgba(255,0,20,0.55)'),
 'gatola':        ('rgba(0,168,162,0.74)', 'rgb(70,240,226)', 'rgba(0,210,198,0.6)'),
 'rocky':         ('rgba(226,120,20,0.64)', 'rgb(255,184,92)', 'rgba(240,130,30,0.52)'),
 'jogosvorazes':  ('rgba(112,36,178,0.64)', 'rgb(190,130,255)', 'rgba(140,60,230,0.55)'),
 'outrolado':     ('rgba(52,132,228,0.60)', 'rgb(150,206,255)', 'rgba(56,146,245,0.55)'),
 'sefv_pink':     ('rgba(228,30,138,0.64)', 'rgb(255,120,192)', 'rgba(236,40,150,0.55)'),
 'sefv_blue':     ('rgba(18,150,228,0.66)', 'rgb(120,210,255)', 'rgba(20,160,240,0.55)'),
 'dourado':       ('rgba(255,194,0,0.62)', 'rgb(255,224,130)', 'rgba(255,194,0,0.50)'),  # SEM FILME (conteúdo do AURUM)
}
GLOSS = 0.08

def au_data():
    if PROV:
        svg = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 60"><text x="50" y="47" '
               'font-family="DejaVu Serif" font-weight="bold" font-size="46" text-anchor="middle" fill="#fff">AU</text></svg>')
        return 'data:image/svg+xml;base64,' + base64.b64encode(svg.encode()).decode()
    return 'data:image/svg+xml;base64,' + base64.b64encode(open(AU, 'rb').read()).decode()

def glass_css(col, S, R, B):
    t, b, g = col
    return (f"width:{S}px;height:{S}px;border-radius:{R}px;box-sizing:border-box;"
            f"background:linear-gradient(150deg,rgba(255,255,255,{GLOSS*1.6}) 0%,rgba(255,255,255,{GLOSS*0.3}) 48%,rgba(0,0,0,0.08) 100%),{t};"
            f"border:{B}px solid {b};box-shadow:0 0 22px {g},inset 0 1px 0 rgba(255,255,255,0.22);")

def page(html, w, h, out, transparent=False):
    pg = BROWSER.new_page(viewport={'width': w, 'height': h})
    pg.set_content(html); pg.wait_for_timeout(250)
    pg.screenshot(path=out, omit_background=transparent, full_page=False); pg.close()

# ---------- VIDEO: selo 132px r26 x=474 (y por vídeo), blur real frame a frame ----------
def video(src, dst, col, Y=1560):
    S, R, B, AUW, X = 132, 26, 5, 112, 474
    ov = os.path.join(HERE, 'tmp_ov.png'); mask = os.path.join(HERE, 'tmp_mask.png')
    html = f"""<html><body style="margin:0;background:transparent">
    <div style="position:absolute;left:{X}px;top:{Y}px;{glass_css(col,S,R,B)}">
      <img src="{au_data()}" style="position:absolute;left:{(S-2*B-AUW)/2}px;top:50%;transform:translateY(-50%);width:{AUW}px"></div></body></html>"""
    page(html, 1080, 1920, ov, transparent=True)
    m = Image.new('L', (S, S), 0); ImageDraw.Draw(m).rounded_rectangle((0, 0, S-1, S-1), R, fill=255); m.save(mask)
    fc = (f"[0:v]scale=1080:1920:flags=lanczos,setsar=1,split[a][b];"
          f"[b]crop={S}:{S}:{X}:{Y},gblur=sigma=14,eq=saturation=1.2,format=rgba[bl];"
          f"[2:v]format=gray[mk];[bl][mk]alphamerge[blr];[a][blr]overlay={X}:{Y}[c];[c][1:v]overlay=0:0,format=yuv420p[v]")
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', src, '-loop', '1', '-i', ov, '-loop', '1', '-i', mask,
                    '-filter_complex', fc, '-map', '[v]', '-map', '0:a?', '-c:v', 'libx264', '-preset', 'veryfast',
                    '-crf', '17', '-c:a', 'copy', '-shortest', '-movflags', '+faststart', dst], check=True)

# ---------- IMAGEM: selo 92px r20 x=66, setinha 84x44 ----------
def image(src, dst, col, au, arrow=None):
    im = Image.open(src); W, H = im.size
    S, R, B, AUW = 92, 20, 4, 72
    X, Y = au
    t, b, g = col
    bg = 'data:image/jpeg;base64,' + base64.b64encode(open(src, 'rb').read()).decode()
    bd = "backdrop-filter:blur(14px) saturate(1.2);-webkit-backdrop-filter:blur(14px) saturate(1.2);"
    pill = '' if not arrow else f"""
    <div style="position:absolute;left:{arrow[0]}px;top:{arrow[1]}px;width:84px;height:44px;border-radius:22px;{bd}
      background:linear-gradient(150deg,rgba(255,255,255,0.12) 0%,rgba(255,255,255,0.02) 50%,rgba(0,0,0,0.08) 100%),{t};
      border:2.5px solid {b};box-sizing:border-box;box-shadow:0 0 16px {g},inset 0 1px 0 rgba(255,255,255,0.22)">
      <svg viewBox="0 0 84 44" style="position:absolute;left:-2.5px;top:-2.5px;width:84px;height:44px">
        <g fill="none" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round">
        <path d="M24 14 l8 8 l-8 8" stroke="rgba(255,255,255,0.32)"/><path d="M39 14 l8 8 l-8 8" stroke="rgba(255,255,255,0.62)"/>
        <path d="M54 14 l8 8 l-8 8" stroke="#fff"/></g></svg></div>"""
    html = f"""<html><body style="margin:0;width:{W}px;height:{H}px;overflow:hidden;background:url({bg}) 0 0/{W}px {H}px no-repeat">
    <div style="position:absolute;left:{X}px;top:{Y}px;{bd}{glass_css(col,S,R,B)}">
      <img src="{au_data()}" style="position:absolute;left:{(S-2*B-AUW)/2}px;top:50%;transform:translateY(-50%);width:{AUW}px"></div>{pill}</body></html>"""
    tmp = dst + '.png'; page(html, W, H, tmp)
    Image.open(tmp).convert('RGB').save(dst, quality=95, subsampling=0); os.remove(tmp)

V = {  # arquivo (prefixo) -> (saída, cor, Y)
 # lote 27/10 (zona do selo conferida a 2 fps no vídeo todo: sem legenda/texto)
 '2b4dc9': ('01_EU-SOU-O-ROCKY_voce-sabia', 'rocky', 1560),
 '66ec33': ('02_STREET-FIGHTER_escolha-seu-lutador', 'streetfighter', 1560),
 '7f2c39': ('03_CARA-DE-BARRO_premiere', 'caradebarro', 1560),
 '99dcea': ('04_CARA-DE-BARRO_bastidores', 'caradebarro', 1560),
 'AQNgk8': ('01_STREET-FIGHTER', 'streetfighter', 1560),
 'AQNm2D': ('02_CARA-DE-BARRO_trailer', 'caradebarro', 1560),
 'AQOcu_': ('03_O-GATOLA-DA-CARTOLA_pre-estreia', 'gatola', 1560),
 'AQPGTF': ('04_EU-SOU-O-ROCKY', 'rocky', 1560),
 'AQPyBP': ('05_CARA-DE-BARRO_chocolate', 'caradebarro', 1712),  # endcard ocupa 1560-1610 -> desce pra faixa preta
}
# posição analisada peça a peça: AU (x,y) e setinha (x,y). Centro x=494 (AU 92) ; canto x=66 / setinha direita x=930
P = {  # imagem única
 'd8eee6c0-image.jpg': ('05_CARA-DE-BARRO_filme-1-do-fim-de-semana', 'caradebarro', (494, 1018)),  # centro, acima do selo DC STUDIOS
 '863849607': ('06_JOGOS-VORAZES_chama-ardente', 'jogosvorazes', (494, 1063)),  # centro, entre "CHAMA ARDENTE" e o bloco do título
 '864950962': ('07_CARA-DE-BARRO_tradutor', 'caradebarro', (494, 1022)),          # centro, em cima do selo DC STUDIOS / logo
 '866764040': ('08_JOGOS-VORAZES_livro-filme', 'jogosvorazes', (494, 1063)),      # centro, entre o livro e o bloco do título
}
CAR = {  # lista por lâmina: (cor, AU, setinha ou None)
 'CARROSSEL1_OOUTROLADODASREDES': ('09_CARROSSEL_O-OUTRO-LADO-DAS-REDES', [
     ('outrolado', (66, 66), (930, 1252)), ('outrolado', (66, 66), (930, 1252)), ('outrolado', (66, 66), None)]),
 'CARROSSEL1_SEEUFOSSEVOC': ('10_CARROSSEL_SE-EU-FOSSE-VOCE-3', [
     ('sefv_blue', (494, 342), (930, 1209)),  # centro, entre o logo e a pergunta (no y=66 colava no logo); setinha na altura do botão
     ('sefv_pink', (494, 66), (930, 940)),    # topo centro na faixa azul; setinha no branco acima do logo
     ('sefv_blue', (494, 66), (930, 940)),    # topo centro na faixa rosa; setinha no branco acima da faixa azul
     ('sefv_pink', (66, 1005), None)]),       # pôster: topo e rodapé lotados (elenco, logos) -> esquerda, no branco ao lado do logo do filme
}

if __name__ == '__main__':
    only = sys.argv[sys.argv.index('--only') + 1] if '--only' in sys.argv else None
    suf = '_PROVISORIO' if PROV else ''
    os.makedirs(OUT, exist_ok=True)
    with sync_playwright() as p:
        BROWSER = p.chromium.launch()
        for f in sorted(glob.glob(os.path.join(IN, '*.mp4'))):
            name, col, Y = V[os.path.basename(f)[:6]]
            if only and only not in name: continue
            d = os.path.join(OUT, 'VIDEOS'); os.makedirs(d, exist_ok=True)
            video(f, os.path.join(d, name + suf + '.mp4'), C[col], Y); print('ok', name)
        for f in sorted(glob.glob(os.path.join(IN, '*.jpg'))):
            name, col, au = P[os.path.basename(f).split('_')[0]]
            if only and only not in name: continue
            d = os.path.join(OUT, 'POSTS'); os.makedirs(d, exist_ok=True)
            image(f, os.path.join(d, name + suf + '.jpg'), C[col], au); print('ok', name)
        for folder in sorted(glob.glob(os.path.join(IN, 'CARROSSEL*'))):
            key = next(k for k in CAR if os.path.basename(folder).startswith(k))
            name, spec = CAR[key]
            if only and only not in name: continue
            d = os.path.join(OUT, name); os.makedirs(d, exist_ok=True)
            fs = sorted(glob.glob(os.path.join(folder, '*.jpg')))
            for i, (f, (col, au, ar)) in enumerate(zip(fs, spec)):
                image(f, os.path.join(d, f'{name[3:]}_{i+1:02d}{suf}.jpg'), C[col], au, ar)
            print('ok', name)
        BROWSER.close()
