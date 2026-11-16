---
name: pr-review
description: Relit de bout en bout une pull request GitHub existante - contenu et correction, forme, langue, standards de code et checks GitHub Actions - charge l'issue liée, et rédige une note de revue structurée avec une recommandation approve / request-changes. Ne fait que préparer le brouillon par défaut ; ne poste la revue et n'approuve que sur accord explicite de l'utilisateur. Indépendant de la stack (les spécificités passent par max:review) ; orienté GitHub. À utiliser quand l'utilisateur donne une PR (URL ou numéro) à relire en tant que reviewer, ou invoque /max:pr-review.
---

# Relire la PR d'un autre

Revue côté reviewer d'une pull request écrite par quelqu'un d'autre. L'objectif : une revue qu'un humain pourrait poster telle quelle, avec un verdict, un tableau par axe et des commentaires concrets. **L'action est visible de l'extérieur** : tout reste en brouillon par défaut ; publier la revue et approuver ne se font **que** sur accord explicite de l'utilisateur, jamais de sa propre initiative.

## Récupérer la PR

À partir de l'URL ou du numéro, tout charger avec `gh` (le dépôt se lit dans `https://github.com/<owner>/<repo>/pull/<numéro>` ; sur GitHub Enterprise, définir `GH_HOST=<hôte>`) :

```bash
gh pr view <numéro> -R <owner>/<repo>                 # titre, description, auteur, branches, reviews, issues liées
gh pr diff <numéro> -R <owner>/<repo>                 # le diff relu
gh pr view <numéro> -R <owner>/<repo> --json commits  # liste des commits (contrôles de forme et de langue)
gh pr checks <numéro> -R <owner>/<repo>               # GitHub Actions / checks de statut
```

Charger aussi l'issue liée (`gh issue view <issue> -R <owner>/<repo>`) : le diff se compare à elle.

Lire les lignes modifiées **et** assez de code autour pour les juger. Un hunk ne se relit jamais isolément.

## Axes de revue

Reprendre les **dimensions de `max:review`** (Correction, Sécurité, Performance, Standards, Tests), son échelle de gravité **Bloquant / Majeur / Mineur / Détail** et sa règle de **maîtrise du bruit** (Détails repliés, Mineurs en une ligne, bloc complet Pourquoi / Action réservé aux Bloquant et Majeur). `max:review` gère la **détection de la stack** et charge les spécificités depuis `stacks/` : s'en servir ici. Si `max:review` signale qu'aucune ressource n'existe pour la stack détectée, le mentionner dans la revue et s'appuyer sur les dimensions génériques. Lancer les linters du projet quand ils existent, via son runner (`make` puis `docker compose`). Voici les axes propres à la relecture de la PR d'autrui :

- **Contenu** : le diff livre-t-il ce que demande l'issue, de bout en bout ? S'attaque-t-il à la cause racine ou au symptôme ? C'est la Correction de `max:review`, évaluée face à l'issue chargée.
- **CI** : état des checks GitHub Actions. Un check rouge est un constat (Bloquant si c'est un vrai échec, Mineur s'il est instable ou sans rapport, en précisant lequel). Checks en attente : les signaler comme non vérifiés. Si le diff touche `.github/workflows/`, relire aussi le workflow (voir `max:security`, GitHub Actions).
- **Forme** : hygiène des commits et de la PR :
  - **Commits atomiques** : un changement logique par commit ; signaler ceux qui mélangent plusieurs sujets.
  - **Commits sémantiques** conformes à `max:commit` : `type(scope): <emoji> description`, scope obligatoire (jamais un identifiant d'issue), description en anglais à l'impératif, sans majuscule ni point final, 72 caractères au plus ; trailer `Closes #n` / `Refs #n` pour l'issue. Scope manquant : Mineur ; commit cassant sans `!` ni `BREAKING CHANGE:` : Majeur.
  - **Lien avec l'issue** : la description de la PR renvoie à l'issue par un mot-clé de fermeture (`Closes #42`) ; l'absence totale d'issue est tolérée mais doit rester rare, et se signale dans les deux cas. Le numéro d'issue va en trailer, pas dans le scope.
  - **Titre et description** : titre au format `type(scope): description` (en français), description complète (Contexte / Cause racine / Correctif / Vérification, comme `.github/pull_request_template.md`).
  - **Branche** : `<type>/<slug>` (`feat/ma-nouvelle-feature`, `fix/erreur-de-login`), créée depuis `main` et visant `main` ; signaler un préfixe `feature/` ou une branche sans type.
  - **Index ciblé** : pas de fichiers parasites ni de modifications étrangères.
- **Langue** : deux registres, jamais mélangés :
  - **Français** : titre et description de la PR, ainsi que ta note de revue (langue de l'équipe).
  - **Anglais** : tout le code, soit identifiants, commentaires, docblocks, et chaînes visibles par l'utilisateur via l'API de traduction de la stack quand elle en a une. Code ou commentaires dans une autre langue : commentaire étiqueté **« à revoir »** en **Mineur**, _sans effet sur le verdict_.
  - Fautes de frappe ou de grammaire dans l'un ou l'autre registre : commentaire.
- **Standards** : ceux de `max:review` (respecter l'idiome local du fichier et le standard de code de la stack chargée ; lancer les linters via le runner plutôt que d'estimer à l'œil), **plus la règle de la maison : toute fonction est typée (paramètres et retour) et porte un docblock**. Signaler toute fonction qui manque de l'un ou de l'autre.

## Verdict

Mécanique, selon la gravité maximale relevée :

- Au moins un **Bloquant/Majeur** → **request-changes**.
- Seulement du **Mineur/Détail**, ou rien → **approve** (détails mentionnés dans le commentaire).

Ce que ça engage dépend de la protection de branche du dépôt : avec **« Require conversation resolution »**, chaque fil ouvert bloque le merge tant qu'il n'est pas résolu, et **« Require approvals »** compte ton approbation. Choisir `request-changes` ou `approve` revient donc à décider si _tu_ ajoutes une approbation : la retenir pour de vrais défauts de Contenu, de CI, de Sécurité ou de Standards ; les remarques de langue ou de style étiquetées **« à revoir »** sont Mineures et ne retiennent pas l'approbation à elles seules.

Ne jamais recommander approve sur ce qui n'a pas pu être vérifié : dire ce qui ne l'est pas et basculer sur request-changes.

## Rédiger la revue

Deux sorties, toutes deux **dans la langue de la PR** (le français ici) :

**1. La note globale** : un commentaire de synthèse, qui devient le corps de la review. Il contient le verdict, le tableau par axe, l'état de la vérification et la checklist de recette. Pas de liste de constats ici (chacun devient son propre commentaire en ligne ou son propre fil). Limiter le tableau aux axes ⚠️/❌ ; regrouper les axes sains sur une ligne (`✅ Forme, Langue, Tests`).

```markdown
## Revue - <approve | demande de modifs>

| Axe                         | Verdict             |
| --------------------------- | ------------------- |
| <uniquement les axes ⚠️/❌> | ⚠️ / ❌ + une ligne |

✅ <axes OK regroupés sur une ligne>

Détail des points en commentaires ci-dessous.

### Vérifié

- ✅ <contrôle empirique ou check Actions exécuté> / ⚠️ <ce qui n'a pas pu être vérifié>

### UAT manuelle

- [ ] <étape exacte>
```

**2. Un commentaire par constat** : chacun ouvre un fil de revue résoluble. Corps de chaque commentaire :

```markdown
**[Bloquant|Majeur|Mineur|Détail|à revoir]** <symptôme>
<pourquoi, et le correctif exact - copiable, jamais « investiguer X »>
```

Ancrer le commentaire sur une ligne précise du diff chaque fois que le constat s'y rattache ; sinon l'intégrer à la note globale (constats sur les commits, la branche ou la description). Ne garder que de vrais constats : **un par Bloquant/Majeur/Mineur ; jamais un par Détail.** Regrouper les Détails sur une seule ligne en bas de la note globale (`Détails : <a> ; <b>`).

Montrer à l'utilisateur la note et la liste des commentaires. **Ne rien publier pour l'instant.** Énoncer le verdict recommandé et ce qui n'a pas été vérifié.

## Publier : uniquement sur accord explicite

Quand, et seulement quand, l'utilisateur valide explicitement, publier. Une seule **review** porte la note globale et tous les commentaires en ligne : l'auteur reçoit une seule notification et chaque commentaire devient un fil résoluble. Utiliser ici l'événement `COMMENT` ; l'approbation est une étape distincte, plus bas.

Récupérer le SHA de tête une fois, puis construire le JSON avec `jq` (encodage sûr) et l'envoyer avec `--input` :

```bash
HEAD=$(gh pr view <numéro> -R <owner>/<repo> --json headRefOid -q .headRefOid)

jq -n --arg head "$HEAD" --arg body "$(cat note.md)" --slurpfile comments comments.json \
  '{commit_id:$head, event:"COMMENT", body:$body, comments:$comments[0]}' > review.json

gh api -X POST "repos/<owner>/<repo>/pulls/<numéro>/reviews" --input review.json
```

`comments.json` est un tableau à un objet par constat ancré :

```json
[{ "path": "<fichier>", "line": <nouvelle_ligne>, "side": "RIGHT", "body": "**[Majeur]** …" }]
```

- `line` = numéro de ligne côté **nouveau** (`side: "RIGHT"`, lignes ajoutées ou de contexte). Pour une ligne **supprimée**, utiliser `side: "LEFT"` avec l'ancien numéro. Une plage multiligne ajoute `start_line` / `start_side`.
- Position invalide : HTTP 422 (« Line could not be resolved »). Vérifier que la ligne appartient bien au diff de ce fichier.

**Approuver / demander des changements** : étape distincte et explicite, uniquement si l'utilisateur l'a demandée :

```bash
gh pr review <numéro> -R <owner>/<repo> --approve -b "<court message en français>"
gh pr review <numéro> -R <owner>/<repo> --request-changes -b "<court message en français>"
```

Confirmer ce qui a été publié (URL de la review, nombre de commentaires, ancrés ou généraux, état de l'approbation). Ne jamais merger ni passer en « Ready for review ».

## Limites

- Brouillon par défaut. Publier la review et approuver exigent chacun l'accord explicite de l'utilisateur ; l'accord donné pour une revue ne vaut pas pour la suivante.
- Ne jamais approuver ce qui n'a pas pu être vérifié, ni en présence de constats Bloquant/Majeur.
- Ne jamais merger ni passer la PR en « Ready for review ».
- Ne pas signaler du code antérieur que la PR n'a pas touché : le noter comme hors-scope.
