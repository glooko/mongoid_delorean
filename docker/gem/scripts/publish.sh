#!/bin/sh

set -u
set -e
set -x

GEM_TO_RELEASE=/tmp/release.gem
GEMRC_FILE=$HOME/.gem/credentials

mkdir -p "`dirname "${GEMRC_FILE}"`"
mkdir -p "`dirname "${GEM_TO_RELEASE}"`"

set +e && rm ${GEM_TO_RELEASE} 2> /dev/null && set -e

cat >> "${GEMRC_FILE}" << EOF
---
:github: Bearer ${GITHUB_GLOOKO_BUNDLE_PASSWORD}
EOF

chmod 0600 $GEMRC_FILE

gem build ${GEMSPEC_FILE} --output=${GEM_TO_RELEASE}
gem push --key github --host https://rubygems.pkg.github.com/glooko --verbose ${GEM_TO_RELEASE}
