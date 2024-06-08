#!/usr/bin/env python3
# -*- coding: utf-8 mode: python -*- vim:sw=4:sts=4:et:ai:si:sta:fenc=utf-8

import os, sys, argparse
from os import path
from urllib.parse import urlparse

sys.path.append(path.join(path.dirname(__file__), "python3"))
import yaml

parser = argparse.ArgumentParser(
    usage="%(prog)s <mappings.yml>",
    description="générer le script sql correspondant aux mappings",
)
parser.add_argument("mappings", nargs=1, metavar="mappings.yml", help="Fichier de mappings")
parser.add_argument("-s", "--source-schema", help="Sélectionner le schéma source")
parser.add_argument("-d", "--dest-schema", help="Sélectionner le schéma destination")
args = parser.parse_args()

mappings = {}
if args.mappings:
    with open(args.mappings[0], "rb") as inf:
        mappings = yaml.load(inf, Loader=yaml.Loader)

source_schema = args.source_schema or "piste_inscription"
dest_schema = args.dest_schema or "ins_piste"

for (collection, mappings) in mappings["mappings"].items():
    if mappings is None: continue
    cols = mappings.keys()
    coldefs = ["%s varchar" % col for col in cols]
    print("create table %s.%s (\n  %s\n);" % (dest_schema, collection, "\n, ".join(coldefs)))

    exprs = []
    for (col, user_expr) in mappings.items():
        expr = ["source_json"]
        for part in user_expr.split("."):
            if part.isnumeric(): expr.append("->%s" % part)
            else: expr.append("->'%s'" % part)
        expr[-1] = expr[-1].replace("->", "->>")
        exprs.append("%s as %s" % ("".join(expr), col))
    print("insert into %s.%s (%s) select\n  %s\nfrom %s.%s;" % (
        dest_schema, collection,
        ", ".join(cols),
        "\n, ".join(exprs),
        source_schema, collection,
    ))
