#!/bin/bash
#
# Generates flattened reference bundles for the ebean-orm skill
# from the source guides in the ebean repo.
#
# By default, looks for the ebean repo at ../ebean (sibling directory).
# Override with: EBEAN_REPO=/path/to/ebean ./generate-references.sh
#
# Usage:
#   ./generate-references.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EBEAN_REPO="${EBEAN_REPO:-$SCRIPT_DIR/../ebean}"
GUIDES_DIR="$EBEAN_REPO/docs/guides"
REFS_DIR="$SCRIPT_DIR/ebean-orm/references"

if [ ! -d "$GUIDES_DIR" ]; then
  echo "Error: guides directory not found at $GUIDES_DIR" >&2
  echo "Set EBEAN_REPO to point to your ebean checkout:" >&2
  echo "  EBEAN_REPO=/path/to/ebean ./generate-references.sh" >&2
  exit 1
fi

mkdir -p "$REFS_DIR"

# Generate a flattened bundle from one or more source guides.
#   generate_bundle <output-name> <title> <guide1> [guide2] ...
generate_bundle() {
  local output_name="$1"
  local title="$2"
  shift 2
  local output_file="$REFS_DIR/${output_name}.md"

  {
    echo "# Ebean ORM Bundle — ${title} (Flattened)"
    echo ""
    echo "> Flattened bundle. Content from source markdown guides is inlined below."
    for guide in "$@"; do
      local guide_file="$GUIDES_DIR/$guide"
      if [ ! -f "$guide_file" ]; then
        echo "Warning: guide not found: $guide_file" >&2
        continue
      fi
      echo ""
      echo "---"
      echo ""
      echo "## Source: \`${guide}\`"
      echo ""
      cat "$guide_file"
    done
  } > "$output_file"

  echo "  Generated $output_name.md ($(wc -c < "$output_file" | tr -d ' ') bytes)"
}

echo "Generating ebean-orm skill references from $GUIDES_DIR ..."

generate_bundle "setup" "Setup" \
  add-ebean-postgres-maven-pom.md \
  add-ebean-postgres-test-container.md \
  add-ebean-postgres-database-config.md

generate_bundle "modeling" "Modeling" \
  entity-bean-creation.md \
  lombok-with-ebean-entity-beans.md

generate_bundle "querying" "Querying" \
  writing-ebean-query-beans.md

generate_bundle "write-transactions" "Write & Transactions" \
  persisting-and-transactions-with-ebean.md

generate_bundle "testing" "Testing" \
  testing-with-testentitybuilder.md

generate_bundle "db-migrations" "DB Migrations" \
  add-ebean-db-migration-generation.md

echo "Done. References written to ebean-orm/references/"
