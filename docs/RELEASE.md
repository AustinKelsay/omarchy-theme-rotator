# Release process

1. Choose the next semantic version and update `manifest.json`.
2. Move user-visible changes into the dated section in `CHANGELOG.md`.
3. Run `make check` and `omarchy plugin validate .`.
4. Install from the release candidate and verify status, manual rotation,
   pause/resume, and one scheduled rotation in Omarchy Shell.
5. Merge to `main` and confirm the GitHub Actions check passes.
6. Create an annotated `vX.Y.Z` tag and push it.
7. Create a GitHub release from the changelog section.

Never tag a release from a dirty tree or before CI succeeds.
