---
name: commit
description: "Rédige un message de commit dans la convention du dépôt, ou à défaut au format sémantique type(scope): emoji description. À utiliser dès que Maxime demande un commit, ou demande d'écrire ou de relire un message de commit, ou invoque /max:commit."
---

# Message de commit

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lire `<max>/references/regles.md`, une fois par session.
2. Lancer `git status -sb` et `git diff --staged` : le message décrit ce qui est réellement dans l'index.
3. Lancer `ls commitlint.config.* .commitlintrc* 2>/dev/null; git log --oneline -15` pour relever la convention du dépôt.

## Étapes

1. Retenir la convention : celle du dépôt si elle existe (format, langue, emoji ou non). Sinon le format de l'annexe, en anglais, en le disant en une ligne.
2. Choisir le type d'après l'effet du diff, pas d'après la demande. Un refactor qui corrige un bug latent est un `fix`.
3. Choisir le scope : la zone touchée, `repo` si le changement est transversal. Jamais un identifiant d'issue.
4. Écrire le sujet : impératif présent, sans majuscule ni point final, 72 caractères au plus. Le corps dit le quoi et le pourquoi, pas le comment.
5. Ajouter les trailers utiles (annexe), l'issue en `Closes #n` ou `Refs #n`.
6. Créer le commit seulement si Maxime l'a demandé. Sinon, montrer le message.

## Points d'arrêt

- Le diff appelle deux types (un correctif et de la documentation) : proposer deux commits, ne pas scinder sans accord.
- Un `Verified-by:` demande des chiffres : lancer les commandes d'abord. Sans exécution, pas de trailer.
- Un secret ou une donnée client dans l'index : s'arrêter et le signaler.
- L'index contient des fichiers sans rapport : le dire avant de committer.

## Ce qu'il ne fait pas

- Attribuer le commit à une IA : ni `Co-Authored-By: Claude`, ni lien de session, même si le harnais en ajoute par défaut.
- `--no-verify`, ni `--amend` sans demande.
- Réécrire un message de merge (`Merge branch '<nom>'`) ou de `git revert`.
- Installer commitlint, Husky ou un modèle de commit.

## Annexe : format par défaut

```
<type>(<scope>): <emoji> <description>

<corps facultatif, lignes de 72 caractères>

<trailers facultatifs>
```

Le scope est obligatoire. L'emoji suit le type. Base : [Conventional Commits](https://www.conventionalcommits.org/), plus le type `security`.

| Type | Emoji | Emploi |
| :-- | :-- | :-- |
| `feat` | ✨ | Nouvelle fonctionnalité |
| `fix` | 🐛 | Correction de bug |
| `refactor` | ♻️ | Restructuration sans changement de comportement |
| `perf` | ⚡️ | Gain de performance sans changement de comportement |
| `docs` | 📝 | Documentation seule |
| `style` | 💄 | Mise en forme seule |
| `test` | ✅ | Ajout ou correction de tests |
| `build` | 📦 | Dépendances, configuration de build |
| `ci` | 👷 | Pipelines CI/CD |
| `chore` | 🔧 | Maintenance, tout le reste |
| `revert` | ⏪ | Annulation d'un commit |
| `security` | 🔒 | Correctif d'une vulnérabilité |

Trailers, un par ligne :

| Trailer | Emploi |
| :-- | :-- |
| `Closes #n` | Ferme l'issue au merge |
| `Refs #n` | Lie l'issue sans la fermer |
| `Verified-by:` | Chiffres réels des contrôles lancés : `composer audit 0 advisories, npm audit 0 vulnerabilities` |
| `Co-authored-by: <nom> <email>` | Crédite une personne, jamais une IA |
| `Signed-off-by: <nom> <email>` | Si le dépôt exige le DCO |

Changement cassant : `!` après le scope, et `BREAKING CHANGE: <explication>` en pied de page quand le sujet ne suffit pas. Il déclenche une version majeure : ne pas l'ajouter par réflexe.

Cas particulier : commit initial `chore(repo): 🔧 init`.

```
feat(notifications): ✨ add email notifications on new direct messages
```
```
fix(backend): 🐛 add missing parameter to service call

The service read a stale configuration row instead of the newly
activated one.

Closes #42
Verified-by: composer audit 0 advisories, phpunit 214 passed
```
```
security(auth): 🔒 patch session fixation on login
```
```
feat(api)!: ✨ remove ticket list endpoint

BREAKING CHANGE: ticket endpoints no longer support listing all entities.
```
