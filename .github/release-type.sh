#!/usr/bin/env bash
# Decide the CurseForge file version from the TOC version and the git ref.
# stdout: version=... and release_type=alpha|beta|release
# A branch has no tag, so a button press on a branch publishes an alpha.
# A tag ref uses the tag, including "Run workflow" with a tag selected.

set -euo pipefail

release_type_of() {
	local toc_version="$1" ref_name="$2" ref_type="$3"
	local version version_core toc_core label release_type

	if [ -z "$toc_version" ]; then
		echo "::error::No TOC version" >&2
		return 1
	fi

	if [ "$ref_type" != "tag" ]; then
		printf 'version=%s\nrelease_type=%s\n' "$toc_version" alpha
		return 0
	fi

	version="${ref_name#v}"
	# 1.1.0-alpha.1 stays alpha. The TOC only has to match 1.1.0.
	version_core="${version%%-*}"
	toc_core="${toc_version%%-*}"
	if [ "$version_core" != "$toc_core" ]; then
		echo "::error::Tag ${version} does not match TOC version ${toc_version}" >&2
		return 1
	fi

	if [ "$version" = "$version_core" ]; then
		release_type=release
	else
		label="${version#*-}"
		label="${label%%.*}"
		label="${label%%+*}"
		label=$(printf '%s' "$label" | tr '[:upper:]' '[:lower:]')
		case "$label" in
			alpha) release_type=alpha ;;
			beta) release_type=beta ;;
			# CurseForge has no rc type.
			rc) release_type=beta ;;
			*)
				echo "::error::Unknown pre-release '${label}' in ${version}. Use alpha, beta, or rc." >&2
				return 1
				;;
		esac
	fi

	printf 'version=%s\nrelease_type=%s\n' "$version" "$release_type"
}

run_tests() {
	local got want

	check() {
		got=$(release_type_of "$1" "$2" "$3") || {
			echo "FAIL $2 (exit)" >&2
			exit 1
		}
		want="version=$4
release_type=$5"
		if [ "$got" != "$want" ]; then
			printf 'FAIL %s\n%s\n' "$2" "$got" >&2
			exit 1
		fi
	}

	expect_fail() {
		if release_type_of "$@" >/dev/null 2>&1; then
			echo "FAIL $2 (expected error)" >&2
			exit 1
		fi
	}

	# A tag, including "Run workflow" on that tag, stays a release.
	check 1.1.0 v1.1.0 tag 1.1.0 release
	check 1.1.0 1.1.0 tag 1.1.0 release
	check 1.1.0 v1.1.0-alpha.1 tag 1.1.0-alpha.1 alpha
	check 1.1.0 v1.1.0-beta.1 tag 1.1.0-beta.1 beta
	check 1.1.0 v1.1.0-rc.1 tag 1.1.0-rc.1 beta
	check 1.1.0 v1.1.0-RC.1 tag 1.1.0-RC.1 beta
	check 1.1.0 v1.1.0-alpha.1+build tag 1.1.0-alpha.1+build alpha
	# Button press on a branch publishes the TOC version as alpha.
	check 1.1.0 main branch 1.1.0 alpha

	expect_fail 1.1.0 v1.2.0 tag
	expect_fail 1.1.0 v1.1.0-preview.1 tag
	expect_fail "" v1.1.0 tag
}

if [ "${1:-}" = "--test" ]; then
	run_tests
	exit 0
fi

if [ "$#" -ne 3 ]; then
	echo "::error::usage: release-type.sh <toc-version> <ref-name> <ref-type>" >&2
	exit 1
fi

release_type_of "$1" "$2" "$3"
