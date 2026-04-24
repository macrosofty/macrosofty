# Signing & Verification

Macrosofty images are signed at build time using **Sigstore cosign keyless signing**. There is no long-lived signing key; each signature is tied to a specific GitHub Actions run via OIDC.

## Why keyless

- **No key to lose, leak, or rotate.** Nobody — including the maintainer — can sign Macrosofty images from a laptop.
- **Every signature is publicly auditable** via Sigstore's transparency log (Rekor).
- **Supply-chain transparency:** you can verify that any given image came from a specific build in our public repo, on a specific commit, at a specific time.

This is the same signing approach used by Fedora, Universal Blue, and others.

## How to verify an image

### Using `cosign` (command line)

```bash
# Install cosign if you don't have it
# Fedora: rpm-ostree install cosign
# Ubuntu: snap install cosign or build from source

# Verify a Macrosofty image
cosign verify \
  --certificate-identity-regexp="https://github.com/macrosofty/.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/macrosofty/hearty:latest
```

A successful verification prints the certificate details (the GitHub workflow, the commit SHA, the build timestamp). A failed verification fails loudly — don't pull an image that fails verification.

### ISO verification

Every ISO on SourceForge is shipped with:
- `macrosofty-<edition>-<version>.iso`
- `macrosofty-<edition>-<version>.iso.sha256` — the checksum
- `macrosofty-<edition>-<version>.iso.sig` — the cosign signature

To verify:

```bash
# Check the SHA256 sum
sha256sum -c macrosofty-hearty-42.iso.sha256

# Verify the signature
cosign verify-blob \
  --certificate-identity-regexp="https://github.com/macrosofty/.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  --signature macrosofty-hearty-42.iso.sig \
  macrosofty-hearty-42.iso
```

Both should pass. If either fails, **do not use that ISO**. Report the mismatch to us — it might be a SourceForge mirror corruption or, at worst, tampering.

## What verification tells you

- ✓ The image was built by our GitHub Actions pipeline
- ✓ The build ran against a specific commit in a specific repo
- ✓ The signature was logged publicly in Rekor at a specific time

What it **does not** tell you:
- Whether the code in the repo is bug-free (verification proves origin, not correctness)
- Whether the upstream packages we pulled from Fedora are safe (that's Fedora's supply chain)

## If the signing key model ever changes

If Macrosofty ever moves to a different signing scheme (e.g., if Sigstore is deprecated or we need stable long-lived keys), this document is updated and the change is announced **at least 30 days in advance** in GitHub Discussions → Announcements. Users will be instructed on how to trust the new keys before old images stop being verifiable.

## Maintainer workflow

Maintainers **never** sign images from their personal machines. All signing happens inside `.github/workflows/build.yml` via:

```yaml
- name: Sign container image
  run: |
    cosign sign --yes ghcr.io/macrosofty/${{ matrix.edition }}@${DIGEST}
  env:
    COSIGN_EXPERIMENTAL: "1"
```

If this pattern breaks (e.g., GitHub removes OIDC support in Actions), no builds are published until we've fixed signing.
