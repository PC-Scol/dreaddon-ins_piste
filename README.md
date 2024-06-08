# dreaddon-ins_piste

Cet addon crée un schéma `schema_ins_piste` et des extractions à partir du
schéma `schema_piste_inscription`, en suivant les règles contenues dans le
fichier `mappings.yml`

Pour utiliser cet addon, rajouter ceci dans la configuration:
~~~sh
ADDON_URLS="
...
PC-Scol/dreaddon-ins_piste.git
...
"
~~~

Pour changer les règles, faites une copie de ce dépôt, modifiez `mappings.yml`,
puis indiquez votre dépôt privé dans la configuration:
~~~sh
ADDON_URLS="
...
https://compte:motdepasse@gitprive.univ.fr/mondepot.git
...
"
~~~

-*- coding: utf-8 mode: markdown -*- vim:sw=4:sts=4:et:ai:si:sta:fenc=utf-8:noeol:binary