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
        hearty: '#C66B3D',
        chunky: '#B04638',
        bubbles: '#7A8868',
        feast: '#6B2C39',
      },
      maxWidth: {
        prose: '68ch',
      },
      animation: {
        'fade-up': 'fadeUp 800ms cubic-bezier(0.2, 0.8, 0.2, 1) both',
        'fade-in': 'fadeIn 1200ms ease-out both',
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
      },
    },
  },
  plugins: [],
};
