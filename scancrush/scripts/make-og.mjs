// ─────────────────────────────────────────────────────────────────────────────
// SCANCRUSH — Gerador da imagem Open Graph (1200x630)
// Renderiza um SVG de marca (texto nítido via fontes do sistema) → PNG otimizado.
// Uso (deps não ficam no package.json):
//   npm i --no-save @resvg/resvg-js sharp
//   node scripts/make-og.mjs
// Saída: public/og-scancrush.png
// ─────────────────────────────────────────────────────────────────────────────
import { Resvg } from '@resvg/resvg-js'
import sharp from 'sharp'
import { readFileSync, writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = resolve(__dirname, '..')

// Avatar da Patty (PNG com rim neon) → base64 embutido
const avatar = readFileSync(resolve(root, '..', 'brand', 'Patty-avatar.png')).toString('base64')
const avatarUri = `data:image/png;base64,${avatar}`

const MAGENTA = '#FF2D6B'
const PURPLE = '#9B5DE5'
const WHITE = '#F4F4F8'
const GRAY = '#AEAEC0'

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
  <defs>
    <radialGradient id="glowM" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="${MAGENTA}" stop-opacity="0.20"/>
      <stop offset="100%" stop-color="${MAGENTA}" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="glowP" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="${PURPLE}" stop-opacity="0.14"/>
      <stop offset="100%" stop-color="${PURPLE}" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="glowR" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="${MAGENTA}" stop-opacity="0.22"/>
      <stop offset="60%" stop-color="${MAGENTA}" stop-opacity="0.05"/>
      <stop offset="100%" stop-color="${MAGENTA}" stop-opacity="0"/>
    </radialGradient>
    <clipPath id="pattyClip"><circle cx="1000" cy="312" r="150"/></clipPath>
  </defs>

  <!-- fundo -->
  <rect width="1200" height="630" fill="#07070D"/>
  <ellipse cx="320" cy="120" rx="640" ry="440" fill="url(#glowM)"/>
  <ellipse cx="180" cy="640" rx="520" ry="320" fill="url(#glowP)"/>
  <ellipse cx="1000" cy="312" rx="440" ry="440" fill="url(#glowR)"/>

  <!-- aneis de scan decorativos atras da Patty -->
  <g fill="none" stroke="${MAGENTA}" opacity="0.13">
    <circle cx="1000" cy="312" r="298" stroke-width="1.4" stroke-dasharray="6 7"/>
    <circle cx="1000" cy="312" r="225" stroke-width="1.2"/>
  </g>

  <!-- Patty -->
  <circle cx="1000" cy="312" r="161" fill="none" stroke="${MAGENTA}" stroke-width="2" opacity="0.45"/>
  <image href="${avatarUri}" x="850" y="162" width="300" height="300" clip-path="url(#pattyClip)" preserveAspectRatio="xMidYMid slice"/>
  <circle cx="1000" cy="312" r="150" fill="none" stroke="${MAGENTA}" stroke-width="4"/>

  <!-- logo lockup -->
  <g transform="translate(92,70) scale(1.7)">
    <circle cx="16" cy="16" r="13" stroke="${MAGENTA}" stroke-width="1.2" stroke-dasharray="3.5 2.5" fill="none" opacity="0.45"/>
    <circle cx="16" cy="16" r="8.5" stroke="${MAGENTA}" stroke-width="1.4" fill="none"/>
    <circle cx="16" cy="16" r="3" fill="${MAGENTA}"/>
    <line x1="16" y1="4" x2="16" y2="7" stroke="${MAGENTA}" stroke-width="1.5" stroke-linecap="round"/>
    <line x1="16" y1="25" x2="16" y2="28" stroke="${MAGENTA}" stroke-width="1.5" stroke-linecap="round"/>
    <line x1="4" y1="16" x2="7" y2="16" stroke="${MAGENTA}" stroke-width="1.5" stroke-linecap="round"/>
    <line x1="25" y1="16" x2="28" y2="16" stroke="${MAGENTA}" stroke-width="1.5" stroke-linecap="round"/>
  </g>
  <text x="162" y="112" font-family="Segoe UI, Arial, sans-serif" font-size="38" font-weight="700" letter-spacing="-0.5">
    <tspan fill="${WHITE}">Scan</tspan><tspan fill="${MAGENTA}">Crush</tspan>
  </text>

  <!-- headline -->
  <text x="92" y="300" font-family="Segoe UI, Arial, sans-serif" font-size="62" font-weight="700" letter-spacing="-1.5" fill="${WHITE}">Talvez os <tspan fill="${MAGENTA}">sinais</tspan></text>
  <text x="92" y="376" font-family="Segoe UI, Arial, sans-serif" font-size="62" font-weight="700" letter-spacing="-1.5" fill="${WHITE}">sempre estiveram ali.</text>

  <!-- subline -->
  <text x="94" y="438" font-family="Segoe UI, Arial, sans-serif" font-size="30" font-weight="400" fill="${GRAY}">A Patty ajuda você a enxergar.</text>

  <!-- url -->
  <text x="94" y="556" font-family="Segoe UI, Arial, sans-serif" font-size="22" font-weight="600" letter-spacing="0.5" fill="${MAGENTA}" opacity="0.85">scancrush.com</text>
</svg>`

const resvg = new Resvg(svg, {
  fitTo: { mode: 'width', value: 1200 },
  font: { loadSystemFonts: true, defaultFontFamily: 'Segoe UI' },
  background: '#07070D',
})
const rawPng = resvg.render().asPng()

// Otimiza mantendo PNG (paleta quantizada) para caber bem no WhatsApp/redes
const out = resolve(root, 'public', 'og-scancrush.png')
const buf = await sharp(rawPng).png({ quality: 82, compressionLevel: 9, palette: true }).toBuffer()
writeFileSync(out, buf)
console.log(`OK → ${out}  (${(buf.length / 1024).toFixed(0)} KB)`)
