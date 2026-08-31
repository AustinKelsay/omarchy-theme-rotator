.PHONY: check test validate syntax

check: syntax validate test

syntax:
	@bash -n bin/omarchy-theme-rotator install.sh scripts/docs-check scripts/validate tests/*.bash tests/run
	@if command -v shellcheck >/dev/null; then shellcheck bin/omarchy-theme-rotator install.sh scripts/docs-check scripts/validate tests/*.bash tests/run; else printf '%s\n' 'shellcheck not installed; CI runs it'; fi

validate:
	@./scripts/validate
	@./scripts/docs-check

test:
	@./tests/run
