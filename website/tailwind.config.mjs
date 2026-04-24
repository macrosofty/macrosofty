/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,ts,tsx,md,mdx,svelte,vue}'],
  theme: {
    extend: {
      fontFamily: {
        display: ['"Fraunces Variable"', 'ui-serif', 'Georgia', 'serif'],
        sans: ['"IBM Plex Sans"', 'system-ui', 'sans-serif'],
        mono: ['"IBM Plex Mono"', 'ui-monospace', 'monospace'],
      },
      colors: {
        cream: {
          50: '#FBF8F2',
          100: '#F5EFE6',
          200: '#EBE3D3',
          300: '#DDD0B5',
        },
        ink: {
          900: '#1A1612',
          800: '#2A2420',
          700: '#3D3530',
          600: '#5C534C',
          500: '#837A72',
          400: '#A89F96',
          300: '#C7BFB5',
        },
        broth: {
          DEFAULT: '#8B5A3C',
          dark: '#6F4328',
          light: '#B5835E',
        },
        saffron: {
          DEFAULT: '#E89A2B',
          dark: '#C77E13',
          light: '#F5B658',
        },
        /* Soft-edition — for the fluffy/cute aesthetic */
        blush: {
          DEFAULT: '#F7D4C0',
          dark: '#E8A888',
          light: '#FDE8D8',
        },
        /* Edition colours */
        hearty: '#C66B3D',
        chunky: '#B04638',
        bubbles: '#7A8868',
        feast: '#6B2C39',
      },
      borderRadius: {
        'soft': '20px',
        'softer': '28px',
        'plump': '36px',
      },
      boxShadow: {
        'puff': '0 24px 48px -18px rgba(139, 90, 60, 0.18), 0 8px 16px -8px rgba(139, 90, 60, 0.08), inset 0 1px 0 rgba(255, 255, 255, 0.6)',
        'puff-lg': '0 40px 72px -24px rgba(139, 90, 60, 0.22), 0 16px 32px -12px rgba(139, 90, 60, 0.10), inset 0 1px 0 rgba(255, 255, 255, 0.6)',
        'marshmallow': '0 12px 32px -12px rgba(232, 154, 43, 0.20), 0 4px 12px -4px rgba(139, 90, 60, 0.12)',
        'inset-soft': 'inset 0 2px 8px rgba(139, 90, 60, 0.08)',
      },
      maxWidth: {
        prose: '68ch',
      },
      animation: {
        'fade-up': 'fadeUp 800ms cubic-bezier(0.2, 0.8, 0.2, 1) both',
        'fade-in': 'fadeIn 1200ms ease-out both',
        'float-slow': 'floatSlow 12s ease-in-out infinite',
        'float-slower': 'floatSlow 20s ease-in-out infinite',
        'wobble': 'wobble 600ms cubic-bezier(0.3, 0.8, 0.2, 1) both',
      },
      keyframes: {
        fadeUp: {
          '0%': { opacity: '0', transform: 'translateY(16px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        floatSlow: {
          '0%, 100%': { transform: 'translate(0, 0) scale(1)' },
          '33%':      { transform: 'translate(12px, -20px) scale(1.04)' },
          '66%':      { transform: 'translate(-8px, 12px) scale(0.98)' },
        },
        wobble: {
          '0%':   { transform: 'scale(0.96) rotate(-1deg)', opacity: '0' },
          '60%':  { transform: 'scale(1.02) rotate(0.4deg)', opacity: '1' },
          '100%': { transform: 'scale(1) rotate(0deg)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
};
