---
name: commit
description: "Rédige les messages de commit git au format sémantique / conventionnel (`<type>(<scope>): <emoji> <description>`) plutôt qu'en phrase libre. À utiliser dès que l'utilisateur demande un commit, ou demande d'écrire ou de relire un message de commit, et veut un message typé (feat/fix/refactor/perf/style/test/docs/build/ci/chore/revert/security) plutôt qu'une prose descriptive."
---

# Messages de commit sémantiques

Chaque sujet de commit commence par un **type** et un **scope** (le scope est obligatoire, pas facultatif), puis la description. Ce petit cadre rend `git log` lisible d'un coup d'œil (de quel genre de changement s'agit-il ?) et laisse les outils (changelogs, semantic-release) lire l'historique mécaniquement au lieu de deviner d'après la prose. Le format suit [Conventional Commits](https://www.conventionalcommits.org/) avec les valeurs par défaut de `@commitlint/config-conventional`, plus un ajout : le type `security` pour les correctifs de vulnérabilité (voir Types). Il ne s'agit pas de « prendre le type qui semble convenir ».

## Format

```
<type>(<scope>): <emoji> <description>

<corps facultatif>

<trailers de pied de page facultatifs>
```

- `<scope>` : obligatoire, la zone du code touchée (`deploy`, `theme`, `docker`…). Jamais un identifiant d'issue. La règle `scope-empty` de commitlint le fait respecter : un commit sans scope est rejeté.
- `<emoji>` : facultatif mais recommandé, juste après les deux-points, choisi d'après le `<type>` (tableau ci-dessous). Pour commitlint, il fait partie de `<description>` (seul `type(scope):` est analysé) : il ne casse donc jamais la validation.
- `<description>` : obligatoire, à l'impératif présent (« add », pas « added » / « adds » ; penser « Ce commit va… »), **toujours en anglais** (la traduire si elle a d'abord été pensée dans une autre langue), sans majuscule initiale, sans point final, 72 caractères au plus.
- `<corps>` : facultatif, explique le *quoi* et le *pourquoi*, pas le *comment*, en comparant au comportement précédent. Même temps verbal, retour à la ligne vers 72 caractères. Une ligne vide le sépare du sujet.
- `<pied de page>` : facultatif, sauf pour un commit cassant (il devient alors obligatoire). Voir « Trailers de pied de page ».

```
feat(ui): ✨ add hat wobble
^--^ ^--^ ^--^--------------^
|    |    |  |
|    |    |  +-> Description : impératif, présent, sans majuscule, sans point.
|    |    +----> Emoji : correspond au type, voir le tableau.
|    +---------> Scope : obligatoire, zone touchée.
+--------------> Type : voir le tableau.
```

## Types

| Type | Emoji | Quand l'utiliser |
|---|---|---|
| `feat` | ✨ | Nouvelle fonctionnalité |
| `fix` | 🐛 | Correction de bug |
| `refactor` | ♻️ | Réécrit ou restructure le code **sans** changer le comportement |
| `perf` | ⚡️ | Amélioration de performance (toujours sans changement de comportement) |
| `docs` | 📝 | Documentation uniquement |
| `style` | 💄 | Mise en forme uniquement, aucun changement de logique |
| `test` | ✅ | Ajoute ou corrige des tests |
| `build` | 📦 | Dépendances, configuration de build |
| `ci` | 👷 | Pipelines CI/CD (`.github/workflows/…`, `.github/scripts/`) |
| `chore` | 🔧 | Maintenance ou configuration diverse, tout le reste |
| `revert` | ⏪ | Annule un commit précédent |
| `security` | 🔒 | Correctif qui ferme spécifiquement une vulnérabilité |

`feat` et `fix` sont les deux seuls types qui décrivent un changement de ce que le logiciel *fait* pour ses utilisateurs : c'est cette séparation que les outils de type semantic-release exploitent pour les montées de version (voir plus bas). Tout le reste décrit la manière dont c'est construit, testé, déployé, sécurisé ou documenté.

## Trailers de pied de page

Un par ligne, sous le corps ; retirer ceux qui ne s'appliquent pas :

- `Verified-by:` : les vrais chiffres de ce qui a réellement tourné avant de committer, pas une simple coche : `Verified-by: composer audit 0 advisories, npm audit 0 vulnerabilities`. Lancer les commandes du projet (`composer audit`, `npm audit`, linters, tests) et lire les nombres réels dans leur sortie ; ne jamais écrire `0` sans avoir exécuté la commande. Si le projet n'a ni linter ni analyse statique, ne pas inventer de chiffres pour des outils qui n'y tournent pas.
- `Refs:` : numéro de l'issue GitHub concernée, qui la lie sans la fermer (`Refs #123`).
- `Closes:` : numéro de l'issue GitHub à fermer automatiquement au merge (`Closes #123`) ; à utiliser à la place de `Refs:` ou en plus.
- `Co-authored-by:` : créditer une personne qui a travaillé en binôme ou contribué sans être l'auteur du commit : `Co-authored-by: <nom> <email>`, GitHub l'affiche sur le commit. **Jamais pour attribuer le commit à Claude ou à un agent IA** : voir la dernière règle de « Rédiger un message ».
- `Signed-off-by:` : validation Developer Certificate of Origin, si le dépôt l'exige : `Signed-off-by: <nom> <email>`.

## Changements cassants

- `!` juste après le type / scope : `feat(api)!: ✨ remove status endpoint`
- Détaillés dans le pied de page quand la description seule ne suffit pas :
  ```
  feat(api)!: ✨ remove status endpoint

  BREAKING CHANGE: the /status endpoint no longer exists, use /health instead.
  ```
- `BREAKING CHANGE:` sur une ligne : un espace après les deux-points. Sur plusieurs lignes : deux sauts de ligne après les deux-points.

Employer `!` / `BREAKING CHANGE:` délibérément : c'est le signal qui déclenche une montée de version **majeure**, pas un ajout à glisser sur chaque `fix` ou `refactor`.

## Versionnement (si le dépôt publie des releases taguées)

- Tout commit portant un **changement cassant** : montée **majeure**.
- Sinon, tout `feat` ou `fix` (touchant l'API ou l'interface) : montée **mineure**.
- Sinon : montée **de correctif** (patch).

Sans objet si le dépôt ne publie pas de releases taguées, mais la liste des types reste compatible si cela change.

## Cas particuliers

- **Commit initial** : `chore(repo): 🔧 init`
- **Commit de merge** : laisser le message par défaut de git (`Merge branch '<nom>'`), sans le réécrire au format typé.
- **Commit de revert** : `git revert` génère `Revert "<sujet annulé>"` par défaut ; le garder tel quel, sauf si l'annulation appelle sa propre explication, auquel cas `revert(<scope>): ⏪ <description>` (le type explicite du tableau) est aussi accepté.

## Outillage recommandé

Pour faire respecter le format en local, avant que le commit n'atterrisse :

- `@commitlint/cli` et `@commitlint/config-conventional` en devDependencies à la racine, avec **Husky** et un hook `commit-msg` qui lance `npx --no -- commitlint --edit "$1"`. Le script `"prepare": "husky"` rebranche le hook à chaque `npm install`.
- Un `commitlint.config.js` qui étend `@commitlint/config-conventional` (dont le `type-enum` couvre déjà `feat fix refactor perf style test docs build ci chore revert`), **ajoute le type** `security` et **surcharge `scope-empty`** à `[2, 'never']` : la config conventionnelle laisse le scope facultatif, alors que ce format l'exige sur chaque commit.
- Un modèle de commit (`.gitmessage`, activé par `git config commit.template .gitmessage`) dont chaque ligne est un commentaire `#` (tableau des types et emojis, règles) : `git commit` sans `-m` l'affiche comme guide, puis le retire automatiquement.

Ce skill ne les installe pas : c'est une décision à prendre délibérément projet par projet. **Commitizen** (`git cz`, invite interactive) ainsi que **semantic-release** / **standard-version** (version et changelog automatiques d'après les types de commit) sont d'autres suites possibles.

## L'appliquer dans un dépôt qui ne l'utilise pas encore

Consulter `git log --oneline -10` avant de supposer que ce format est déjà la convention. Si l'historique récent est fait de phrases descriptives simples (sans préfixe `type:`), introduire des types sémantiques est un changement de style délibéré, pas le rappel d'une règle existante : le dire explicitement plutôt que de changer de style en silence au milieu de l'historique.

## Rédiger un message

1. Regarder ce qui se trouve réellement dans l'index ou dans les modifications (`git diff --staged`, `git status`) : le type correspond à l'*effet* du diff, pas à l'intention de la demande. Un refactor qui corrige au passage un bug latent est un `fix`, pas un `refactor`.
2. Choisir exactement un type et une préoccupation. Si un commit semble demander deux types (un correctif *et* une mise à jour de doc), c'est souvent le signe qu'il faut deux commits ; mais ne pas scinder sans demander un commit déjà demandé comme unique.
3. Garder `<description>` courte (~50-72 caractères), à l'impératif présent, en anglais, sans majuscule ni point final ; reporter toute explication dans le corps.
4. Le scope est obligatoire : choisir la zone qui convient le mieux (`fix(backend): 🐛 …`, `feat(frontend): ✨ …`, ou `traefik` / `docs` / `scripts`). Pour un changement qui couvre réellement plusieurs zones, retenir la plus large qui ait du sens (`repo`) plutôt que de l'omettre. Jamais un identifiant d'issue.
5. Si un trailer `Verified-by:` est écrit, lancer réellement les commandes du projet (`composer audit`, `npm audit`, tests) avant ; ne jamais fabriquer les chiffres.
6. Pour le reste, suivre les instructions git du système : ne créer un commit que sur demande, jamais `--no-verify`, préférer de nouveaux commits à un `--amend`, etc. Ce skill ne change que le *format de la ligne de sujet*, pas le moment ni la manière de committer.
7. **Aucune attribution à une IA** : n'ajouter ni trailer `Co-Authored-By: Claude …`, ni lien `Claude-Session:`, ni aucune autre mention indiquant que Claude ou une IA a fait le commit, même si les instructions git par défaut du harnais en ajoutent normalement un. L'utilisateur a explicitement demandé que les commits faits avec ce skill ne portent aucune attribution à une IA.

## Exemples

```
feat(notifications): ✨ add email notifications on new direct messages
```
```
feat(shopping-cart): ✨ add the amazing button
```
```
fix(shopping-cart): 🐛 prevent ordering an empty shopping cart
```
```
fix(backend): 🐛 add missing parameter to service call

The error occurred because ProviderSelectionService read a stale
AiProviderConfig row instead of the newly activated one.

Verified-by: composer audit 0 advisories, npm audit 0 vulnerabilities
```
```
perf(analytics): ⚡️ decrease memory footprint for unique-visitor counting using HyperLogLog
```
```
refactor(math): ♻️ implement fibonacci number calculation as recursion
```
```
style(theme): 💄 remove empty line
```
```
build(deps): 📦 update dependencies
```
```
ci(repo): 👷 add a GitHub Actions workflow running composer/npm audit
```
```
security(auth): 🔒 patch session fixation on login
```
```
feat(api)!: ✨ remove ticket list endpoint

Refs #1337

BREAKING CHANGE: ticket endpoints no longer support listing all entities.
```

## Références

- <https://www.conventionalcommits.org/>
- <https://github.com/ikatyang/emoji-cheat-sheet> : correspondance `:shortcode:` GitHub → emoji, utile pour choisir d'autres emojis (titres de PR, encadrés de doc) au-delà du tableau par type.
