#!/bin/bash
# -*- coding: utf-8 mode: sh -*- vim:sw=4:sts=4:et:ai:si:sta:fenc=utf-8
MYDIR="$(dirname -- "$0")"

"$MYDIR/../lib/mappings2sql.py" "$MYDIR/../mappings.yml" | psql
