// CÓPIA — o principal é claude/au-anim.js do projeto AURUM EDITS.
// node anim.js theme fps outdir [S]  -> intro_%04d.png, cyc_%04d.png, mintro_%04d.png, mcyc_%04d.png
// S = tamanho do quadrado (132 vídeo 1080x1920; 92 em feed 1080x1350/1440). Raio, borda e AU escalam junto.
const { chromium } = require('playwright'); const fs=require('fs');
const [theme,fps,out]=[process.argv[2],+process.argv[3],process.argv[4]];
const S=+(process.argv[5]||132), k=S/132;
const T={red:['rgba(196,0,12,0.66)','rgb(255,36,48)','rgba(255,0,20,0.55)'],
 blue:['rgba(52,132,228,0.60)','rgb(150,206,255)','rgba(56,146,245,0.55)'],
 green:['rgba(14,150,44,0.64)','rgb(76,255,108)','rgba(40,255,80,0.55)'],
 purple:['rgba(112,36,178,0.64)','rgb(190,130,255)','rgba(140,60,230,0.55)'],
 orange:['rgba(255,72,12,0.64)','rgb(255,150,70)','rgba(255,80,16,0.55)'],
 rocky:['rgba(226,120,20,0.64)','rgb(255,184,92)','rgba(240,130,30,0.52)'],
 gatola:['rgba(0,168,162,0.74)','rgb(70,240,226)','rgba(0,210,198,0.6)'],
 gelo:['rgba(56,160,214,0.64)','rgb(176,234,255)','rgba(90,196,255,0.55)'],
 dourado:['rgba(255,194,0,0.62)','rgb(255,224,130)','rgba(255,194,0,0.50)']}[theme];
const svg=fs.readFileSync(__dirname+'/au.svg','utf8');
const paths=[...svg.matchAll(/ d="([^"]+)"/g)].map(m=>m[1]);
const P=Math.round(40*k),W=S+2*P,R=S===92?20:26*k,B=S===92?4:5*k,AUW=S===92?72:112*k;
const html=`<html><body style="margin:0;background:transparent;width:${W}px;height:${W}px;overflow:hidden">
<div id="box" style="position:absolute;left:${P}px;top:${P}px;width:${S}px;height:${S}px;border-radius:${R}px;box-sizing:border-box;
background:linear-gradient(150deg,rgba(255,255,255,0.13) 0%,rgba(255,255,255,0.02) 48%,rgba(0,0,0,0.08) 100%),${T[0]};border:${B}px solid ${T[1]};
box-shadow:0 0 ${22*k}px ${T[2]},inset 0 1px 0 rgba(255,255,255,0.22)">
<svg id="au" viewBox="0 0 365.33 306.67" style="position:absolute;left:${(S-2*B-AUW)/2}px;top:${(S-2*B-AUW*306.67/365.33)/2}px;width:${AUW}px;overflow:visible">
<defs><linearGradient id="sh" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="365" y2="0"><stop offset="0" stop-color="#fff" stop-opacity="0"/><stop id="s1" offset="0.5" stop-color="#fff" stop-opacity="1"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></linearGradient></defs>
${paths.map(d=>`<path class="p" d="${d}" pathLength="1" fill="#fff" stroke="#fff" stroke-width="7" stroke-linejoin="round" stroke-dasharray="1" stroke-dashoffset="0"/>`).join('')}
</svg></div><div id="mask" style="display:none;position:absolute;left:${P}px;top:${P}px;width:${S}px;height:${S}px;border-radius:${R}px;background:#fff"></div>
<script>
const box=document.getElementById('box'),mask=document.getElementById('mask'),ps=[...document.querySelectorAll('.p')];
const cl=x=>Math.max(0,Math.min(1,x)), eo=x=>1-Math.pow(1-x,3), eio=x=>x<.5?4*x*x*x:1-Math.pow(-2*x+2,3)/2;
const back=x=>{const c1=1.5,c3=c1+1;return 1+c3*Math.pow(x-1,3)+c1*Math.pow(x-1,2)};
function setAU(fill,draw,strokeOp){ps.forEach(p=>{p.style.fillOpacity=fill;p.style.strokeDashoffset=1-draw;p.style.strokeOpacity=strokeOp;});}
window.intro=(t,isMask)=>{ document.body.style.background=isMask?'#000':'transparent';
  const a=cl((t-0.15)/0.55), s=0.62+0.38*back(a), op=eo(cl((t-0.15)/0.3)), bl=(1-eo(a))*8*${k};
  const el=isMask?mask:box; box.style.display=isMask?'none':'block'; mask.style.display=isMask?'block':'none';
  el.style.transform='scale('+s+')'; el.style.opacity=op; if(!isMask) box.style.filter='blur('+bl+'px)';
  const d=eio(cl((t-0.45)/0.7)), f=eo(cl((t-1.1)/0.45)); setAU(f,d,1);
  ps.forEach(p=>p.style.strokeOpacity= t<1.1?1:1-cl((t-1.2)/0.35));
};
window.cyc=(t,isMask)=>{ document.body.style.background=isMask?'#000':'transparent';
  box.style.display=isMask?'none':'block'; mask.style.display=isMask?'block':'none';
  const el=isMask?mask:box; el.style.transform='none'; el.style.opacity=1; box.style.filter='none';
  const pulse=0.5-0.5*Math.cos(2*Math.PI*t/5); box.style.boxShadow='0 0 '+((18+12*pulse)*${k})+'px ${T[2]},inset 0 1px 0 rgba(255,255,255,0.22)';
  let fill=1, so=0, draw=1;
  if(t>3.4&&t<=3.75){const q=eio((t-3.4)/0.35); fill=1-q; so=q;}
  else if(t>3.75&&t<=4.4){fill=0; so=1;}
  else if(t>4.4){const q=eo((t-4.4)/0.5); fill=q; so=1-q;}
  setAU(fill,draw,so);
  const run=cl((t-3.7)/0.75);
  ps.forEach(p=>{ if(t>3.6&&t<4.6){p.style.stroke='url(#sh)';} else p.style.stroke='#fff'; });
  document.getElementById('s1').setAttribute('offset',run);
  if(t>3.6&&t<4.6){ps.forEach(p=>{p.style.strokeOpacity=Math.max(so,0.001);}); }
};
</script></body></html>`;
(async()=>{
  const b=await chromium.launch({executablePath:'/opt/pw-browsers/chromium-1243/chrome-linux64/chrome'}); const p=await b.newPage({viewport:{width:W,height:W}});
  await p.setContent(html); fs.mkdirSync(out,{recursive:true});
  const N1=Math.round(1.6*fps), N2=Math.round(5*fps);
  for(const [name,fn,N] of [['intro','intro',N1],['cyc','cyc',N2]]){
    for(let i=0;i<N;i++){ const t=i/fps;
      await p.evaluate(([f,t])=>window[f](t,false),[fn,t]);
      await p.screenshot({path:`${out}/${name}_${String(i).padStart(4,'0')}.png`,omitBackground:true});
      await p.evaluate(([f,t])=>window[f](t,true),[fn,t]);
      await p.screenshot({path:`${out}/m${name}_${String(i).padStart(4,'0')}.png`});
    }
  }
  await b.close();
})();
