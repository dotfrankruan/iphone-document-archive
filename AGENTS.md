# Repository Guidelines

- Keep all application UI, user-facing errors, filenames, and documentation in English.
- Use Apple's native Continuity Camera integration. Do not replace document scanning with a custom camera or image-processing stack.
- Preserve local-only behavior: captured documents must not be uploaded or sent over the network.
- Run `swift test --disable-sandbox` before committing functional changes.
- Build the application with `./scripts/build-app.sh`; generated `.build/`, `work/`, and `dist/` content must remain untracked.
- Never commit captured documents, receipt metadata, credentials, signing identities, or local diagnostic artifacts.
- Create commits with `git commit --no-gpg-sign`.
