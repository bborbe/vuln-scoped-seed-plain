# vuln-scoped-seed-plain

Throwaway fixture for the vuln-fix lane. Not a real project — do not build on it.

- Pins `golang.org/x/net v0.61.0` and calls `html.Parse`, so govulncheck reports
  a reachable advisory (fixed in v0.62.0).
- Pins `github.com/google/uuid v1.0.0` as a **clean-but-outdated** module. A targeted
  vuln fix must leave it untouched; a full `go get -u` would bump it.
- `make precommit` runs `build` then `vulncheck`: it leaves the binary
  `vuln-scoped-seed-plain` at the repo root and exits non-zero while the advisory
  is reachable.
- There is deliberately **no `.gitignore` and no `CHANGELOG.md`**, so a lane PR
  exercises both the untracked-binary filter and the absent-base-CHANGELOG path.

Expected targeted fix: `go get golang.org/x/net@v0.62.0 && go mod tidy`, leaving
`github.com/google/uuid` at v1.0.0 and committing no root binary.
