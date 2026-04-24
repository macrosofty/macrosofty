# macrosofty website

The front door.

Astro + Tailwind, zero JS in production, deploys to Cloudflare Pages.

## Run it locally

```bash
cd /mnt/code/macrosofty/website
pnpm install           # or: npm install / yarn install / bun install
pnpm dev               # http://localhost:8006 — hot reload on save
```

## Build for production

```bash
pnpm build             # outputs to ./dist
pnpm preview           # serves ./dist locally to sanity-check
```

## Deploying to Cloudflare Pages

1. Push this repo to GitHub.
2. In the Cloudflare dashboard: *Workers & Pages → Create → Pages → Connect to Git*.
3. Build command: `pnpm build`. Output directory: `dist`.
4. Root directory: `website` (if the repo contains more than the site).
5. Every push to `main` auto-deploys. Branch previews are free.

## Things that are intentionally NOT here

- No analytics. No tag manager. No cookie banner. The site has no cookies to consent to.
- No JavaScript frameworks. Astro renders to plain HTML; the only JS shipped is whatever small `<details>` polyfill the browser gives you for free.
- No external font CDNs. Fonts are self-hosted via Fontsource — your visitors never hit Google Fonts.
- No newsletter plumbing yet. The "Get notified" form is a disabled placeholder until we wire it to Cloudflare Pages Functions + Buttondown / Listmonk / ConvertKit.

## Where the copy lives

- Edition definitions: `src/components/EditionsSection.astro`
- Can-do / can't-do lists: `src/components/CanDoSection.astro`
- FAQ: `src/components/FAQ.astro`
- Install steps: `src/components/InstallSteps.astro`

## Design tokens

- Colors, fonts, spacing: `tailwind.config.mjs`
- Base CSS, paper grain, focus styles: `src/styles/global.css`
- The recurring door arch SVG: `src/components/DoorArch.astro`

## TODO before launch

- [ ] Capture real screenshots for `InstallSteps.astro` (three shots — download page, Etcher mid-flash, firstboot wizard)
- [ ] Wire the "Get notified" form to a backend (Cloudflare Pages Function → Buttondown recommended)
- [ ] Swap placeholder GitHub links from `github.com/macrosofty` to the real org once registered
- [ ] Real OG image (`/og.png`) referenced in `BaseLayout.astro`
- [ ] Security / Signing / Attribution footer links → real pages
- [ ] Accessibility audit (axe + screen reader sweep)
- [ ] Lighthouse pass — goal: 100/100/100/100
