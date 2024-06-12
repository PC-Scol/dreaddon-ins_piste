#!/usr/bin/env python3
# -*- coding: utf-8 mode: python -*- vim:sw=4:sts=4:et:ai:si:sta:fenc=utf-8

import os, sys, argparse, re
from os import path
from urllib.parse import urlparse

sys.path.append(path.join(path.dirname(__file__), "python3"))
import yaml

parser = argparse.ArgumentParser(
    usage="%(prog)s <mappings.yml>",
    description="générer le script sql correspondant aux mappings",
)
parser.add_argument("mappings", nargs=1, metavar="mappings.yml", help="Fichier de mappings")
args = parser.parse_args()

data = {}
if args.mappings:
    with open(args.mappings[0], "rb") as inf:
        data = yaml.load(inf, Loader=yaml.Loader)

source_schema = data["schema_source"]
dest_schema = data["schema_destination"]

for (table_name, table) in data["tables"].items():
    if table is None: continue

    definitions = table.get("definitions", {})
    mappings = table.get("mappings", {})

    cols = {}
    for (col, definition) in definitions.items():
        if not definition: definition = "varchar"
        mo = re.match(r'(\S+)\s*(\(.*)?', definition)
        if mo is not None: cast = mo.group(1)
        else: cast = definition
        if cast == "varchar": cast = None
        cols[col] = dict(name=col, definition=definition, cast=cast, mapping=None)
    for (col, mapping) in mappings.items():
        if mapping is None: continue
        if col in cols:
            cols[col]["mapping"] = mapping
        else:
            cols[col] = dict(name=col, definition="varchar", cast=None, mapping=mapping)

    colnames = [col["name"] for col in cols.values()]
    coldefs = ["%s %s" % (col["name"], col["definition"]) for col in cols.values()]
    print("create table %s.%s (\n  %s\n);" % (dest_schema, table_name, "\n, ".join(coldefs)))

    exprs = []
    for col in cols.values():
        name = col["name"]
        cast = col["cast"]
        key = col["mapping"]
        if key is None: continue
        if type(key) is dict:
            sql = key.get("expr", None)
            key = key["key"]
        else:
            sql = None
        expr = ["source_json"]
        for part in key.split("."):
            if part.isnumeric(): expr.append("->%s" % part)
            else: expr.append("->'%s'" % part)
        expr[-1] = expr[-1].replace("->", "->>")
        expr = "".join(expr)
        if cast is not None:
            expr = "(%s)::%s" % (expr, cast)
        if sql is not None:
            expr = sql % dict(expr=expr)
        exprs.append("%s as %s" % (expr, name))
    print("insert into %s.%s (%s) select\n  %s\nfrom %s.%s;" % (
        dest_schema, table_name,
        ", ".join(colnames),
        "\n, ".join(exprs),
        source_schema, table_name,
    ))
