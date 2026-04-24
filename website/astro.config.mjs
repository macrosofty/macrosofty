import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  site: 'https://macrosofty.org',
  integrations: [tailwind({ applyBaseStyles: false })],
  server: {
    port: 8006,
    host: true,
  },
  build: {
    inlineStylesheets: 'auto',
  },
  compressHTML: true,
});
