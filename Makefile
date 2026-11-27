GOVULNCHECK_VERSION ?= v1.7.0
BINARY := vuln-scoped-seed-plain

.PHONY: precommit check build vulncheck clean

precommit: build check

check: vulncheck

# Builds the binary at the repo root. The repo has no .gitignore on purpose:
# the untracked binary is what the vuln lane must refuse to commit.
build:
	go build -o $(BINARY) .

# Real vulnerability scan: govulncheck reports every reachable advisory in the
# module graph. This fixture fires while golang.org/x/net is pinned at the
# vulnerable v0.61.0 (fixed in v0.62.0); green once that module is bumped. The
# clean-but-outdated github.com/google/uuid v1.0.0 must stay pinned.
vulncheck:
	@PKGS="$(shell go list -mod=mod ./... | grep -v /vendor/)"; \
	FINDINGS="$$(go run golang.org/x/vuln/cmd/govulncheck@$(GOVULNCHECK_VERSION) -format json $$PKGS 2>/dev/null | \
		jq -rs 'map(select(.finding != null) | .finding) | \
			map("\(.osv)\t\(.trace[-1].module)@\(.trace[-1].version)\tfixed \(.fixed_version // "n/a")") | \
			unique | .[]')"; \
	if [ -n "$$FINDINGS" ]; then \
		echo "Vulnerabilities found:"; \
		printf '%s\n' "$$FINDINGS"; \
		exit 1; \
	else \
		echo "No vulnerabilities found"; \
	fi

clean:
	rm -f $(BINARY)
