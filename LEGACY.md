IMPORTANT: Cet addon est obsolète et n'est plus nécessaire au fonctionnement de
`dreaddon-pilotage`. en l'état, il ne sert plus à rien, il peut donc être
supprimé de la configuratoin `ADDON_URLS`

Cependant, une partie de la documentation est gardée pour l'historique, si je
décide d'en refaire quelque chose un jour:

---

Cet addon montre comment faire pour faire des extractions "simples" en suivant
les règles contenues dans un fichier `mappings.yml`:
* `schema_source` indique depuis quel schéma les données json sont récupérées
* `schema_destination` indique dans quel schéma les tables sont provisionnées
* pour chaque table de la clé `tables`, la créer dans le schéma destination avec
  les colonnes de la clé `definitions`. si une colonne est mentionné dans
  `mappings` mais pas dans `definitions`, elle est créée avec le type "varchar"
* pour chaque table, provisionner les colonnes listées dans `mappings` avec la
  clé spécifiée, extraite de la colonne `source_json` de la table du même nom
  dans le schéma source.
* il est possible de sélectionner une table source de nom différent de la table
  destination avec la clé `source` e.g
  ~~~yaml
  tables:
    tabledest:
      source: tablesource
      mappings:
        colonne: objet.code.value
  ~~~

Dans les définitions de mappings, une clé `a.b.c` sera transformée en
`source_json->'a'->'b'->>'c'`

Consulter le fichier `mappings.yml` livré pour un exemple de mapping plus
complexe (cf par exemple le mapping de `type_etablissement_bac`)

Pour changer les règles, faites une copie de ce dépôt, modifiez `mappings.yml`,
décommentez la commande dans le fichier `updates/create-mappings.sh` puis
indiquez votre dépôt privé dans la configuration:
~~~sh
ADDON_URLS="
...
https://compte:motdepasse@gitprive.univ.fr/mondepot.git
...
"
~~~

-*- coding: utf-8 mode: markdown -*- vim:sw=4:sts=4:et:ai:si:sta:fenc=utf-8:noeol:binary