import type { Config } from 'tailwindcss'

export default {
  content: [
    './components/**/*.{js,vue,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
    './plugins/**/*.{js,ts}',
    './app.vue',
    './error.vue',
  ],
  theme: {
    extend: {
      colors: {
        // Brand palette — espelha as CSS variables
        pink: {
          DEFAULT: '#FF2D6B',
          glow: 'rgba(255,45,107,0.18)',
          border: 'rgba(255,45,107,0.28)',
        },
        purple: {
          DEFAULT: '#9B5DE5',
          dim: 'rgba(155,93,229,0.12)',
        },
        teal: '#00F5D4',
        amber: '#FFB800',
        danger: '#FF4D4D',
        safe: '#00D68F',
        bg: '#07070D',
        surface: '#0D0D1A',
        card: '#111120',
        'brand-text': '#EEEEF8',
        'brand-text-2': '#9090B8',
        'brand-text-3': '#4A4A6A',
        border: 'rgba(255,255,255,0.06)',
      },
      fontFamily: {
        sans: ['Sora', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      backgroundImage: {
        'glow-pink':
          'radial-gradient(ellipse 80% 60% at 50% -10%, rgba(155,93,229,0.07) 0%, transparent 70%)',
      },
    },
  },
  plugins: [],
} satisfies Config
