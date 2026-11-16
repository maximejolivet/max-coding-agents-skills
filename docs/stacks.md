# Stacks : détection et ajout d'une techno

Aucun skill transverse ne connaît de techno. Il repère la stack du projet, puis lit le fichier `stacks/<techno>/INDEX.md` qui lui correspond. Ajouter une techno revient donc à ajouter deux choses, jamais à modifier un skill.

## Comment la stack est repérée

`stacks/detect.sh` inspecte les fichiers du projet sans rien exécuter ni installer. Il imprime des lignes `catégorie<TAB>identifiant<TAB>preuve`, avec ces catégories : `language`, `package-manager`, `framework`, `parent`, `test`, `tooling`, `runner`, `resource`. La procédure complète se trouve dans `stacks/DETECT.md`.

Principes d'interprétation :

- le framework l'emporte sur le langage ;
- on retient d'abord la techno la plus précise, puis son parent (`nuxt`, puis `vue`) ;
- avec plusieurs frameworks, chacun ne couvre que ses propres fichiers ;
- dans un monorepo, le script est relancé dans chaque sous-dossier ;
- pour exécuter une commande, on essaie `make`, puis `docker compose`.

## Brancher une nouvelle techno

1. Déclarer sa détection dans `stacks/detect.sh`.
2. Créer `stacks/<techno>/INDEX.md`.
3. Exécuter `sh tests/check.sh`.

C'est tout : les skills la prennent en charge d'eux-mêmes.

## Deux organisations possibles

- **Un seul fichier.** `INDEX.md` découpé en sections. C'est la forme de toutes les stacks livrées (Symfony, Nuxt, React, Next.js, Vue, Laravel, Django) ; à privilégier au départ.
- **Plusieurs fichiers.** `INDEX.md` sert d'aiguillage vers `CORE.md`, `DEV.md`, `REVIEW.md`, `SECURITY.md`, `TEST.md` et `DEPLOY.md`. À envisager lorsqu'un seul fichier devient trop long.

## Les sections

| Section       | Lue quand le skill a besoin de… | Contenu |
| :------------ | :------------------------------ | :------ |
| `## core`     | toujours                        | Conventions et pièges de la techno, rédigés une seule fois. |
| `## dev`      | écrire du code                  | Façon idiomatique de coder. |
| `## review`   | relire                          | Points de contrôle d'une revue. |
| `## security` | auditer                         | Avis, configuration sensible, éléments à vérifier. |
| `## test`     | tester                          | Outils et style de tests. |
| `## deploy`   | construire et déployer          | Build, image, mise en production. |

N'écris que les sections utiles : une nature demandée charge `core` plus sa propre section.
