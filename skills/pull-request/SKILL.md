---
name: pull-request
description: Prépare une pull request GitHub - une branche `feat/…` créée depuis `main`, un commit ciblé, le push, puis `gh pr create` avec une description structurée qui référence l'issue. Crée par défaut une PR en Draft vers `main`, et rappelle le nettoyage à faire après le merge. À utiliser quand l'utilisateur demande de préparer, ouvrir ou créer une PR (ou MR) après un correctif ou une fonctionnalité, ou invoque /max:pull-request.
---

# Préparer une pull request

Transformer un changement terminé en pull request GitHub propre et relisible. Action visible de l'extérieur : créer la PR en **Draft** par défaut, et ne jamais la passer en « Ready for review » ni la merger sans accord explicite de l'utilisateur.

## Cycle de vie d'une fonctionnalité

Une branche = une fonctionnalité ou un correctif, de la création au nettoyage :

1. **Démarrer** depuis `main` à jour, sur une nouvelle branche.
2. **Développer** et committer.
3. **Publier** : push de la branche, puis ouverture de la PR (ce skill).
4. **Merger** (par l'utilisateur, sur GitHub).
5. **Nettoyer** le local après le merge (voir la dernière section).

Ce skill couvre surtout les étapes 1 à 3 et rappelle la 5.

## Avant de commencer

1. **Partir de `main`** - Se mettre sur `main` et récupérer les dernières modifications avant de créer la branche, sauf si la branche existe déjà avec du travail :
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feat/<slug>
   ```
2. **Branche** - Toujours sur une branche dédiée, jamais sur `main`. Convention : `<type>/<slug-en-minuscules>`, où `<type>` est le type de commit (voir `max:commit`) : `feat/ma-nouvelle-feature`, `fix/erreur-de-login`. Un numéro d'issue peut précéder le slug (`feat/42-ma-nouvelle-feature`) ; il n'est pas obligatoire.
3. **Branche de base** - `main`. Ne viser une autre base (ex. `develop`) que si le dépôt l'utilise réellement : le vérifier d'après les branches et les PR existantes.
4. **Index propre** - N'ajouter à l'index que les fichiers de ce changement. Inspecter `git status` et exclure explicitement les modifications sans rapport de l'arbre de travail (les laisser hors de l'index - jamais de `git add .` ni de `git add -A` à l'aveugle).
5. **Réutiliser la revue** - Si `/max:review` vient de tourner, reprendre son verdict, ses checks **Vérification ✅** et ses notes **Hors-scope** directement dans la description de la PR plutôt que de les redériver.

## Commit

Un seul commit ciblé. Le message suit le skill **`max:commit`** - à charger pour écrire le message :

```
type(scope): <emoji> <description en anglais, à l'impératif>

<corps : ce qui n'allait pas, la cause racine, et ce que fait le correctif - ~72 colonnes>

Closes #<issue>
```

Rappel : `type` ∈ feat / fix / refactor / perf / docs / style / test / build / ci / chore / revert / security ; le `(scope)` est obligatoire ; la description est en anglais, sans majuscule ni point final. Le numéro d'issue va en trailer (`Closes #42` ou `Refs #42`), jamais dans le scope. Vérifier l'index avant de committer :

```bash
git diff --cached --name-only   # ne doit contenir que les fichiers voulus
```

## Push et création de la PR

```bash
git push -u origin <branche>
gh auth status                              # confirme l'authentification (+ hôte pour GitHub Enterprise : GH_HOST=<hôte>)
gh pr list --head <branche> --state open    # s'arrêter si une PR existe déjà - la mettre à jour, ne pas dupliquer

DESC=$(cat <<'EOF'
<le modèle de description ci-dessous, rempli>
EOF
)

gh pr create \
  --head <branche> \
  --base main \
  --title "<type(scope): description en français>" \
  --body "$DESC" \
  --draft
```

**Le titre et la description de la PR sont rédigés en français** (langue de l'équipe) - `--title` comme `$DESC`. Le titre reprend le préfixe `type(scope):` du commit avec une description en français ; seuls le code et les messages de commit restent en anglais. Construire `$DESC` avec le heredoc ci-dessus pour que le markdown multiligne survive au shell. `--draft` est le drapeau Draft canonique (ne pas le simuler avec un préfixe `Draft:` dans le titre). Si `gh pr list` montre une PR ouverte pour la branche, la mettre à jour (`gh pr edit`) au lieu d'en créer une seconde.

## Modèle de description

Remplit `$DESC` ci-dessus. Il est le même que `.github/pull_request_template.md` du dépôt, qui sert aux PR ouvertes à la main : si le projet cible a son propre modèle, l'utiliser à la place. Lier l'issue avec un mot-clé de fermeture (`Closes #42`) pour que GitHub la ferme au merge, ou avec une simple référence (`Refs #42`) quand la PR ne traite le sujet qu'en partie. Structure :

```markdown
## Contexte

Closes #<issue> - <problème posé, en un paragraphe>

## Cause racine

<la cause racine ; nommer les commits, routes ou services concernés>

## Correctif

<ce qui a changé et pourquoi c'est correct ; ce qui reste volontairement inchangé>

## Vérification

- ✅ <check empirique qui a tourné>
- ✅ linter / tests / CI (GitHub Actions) selon le cas

### UAT manuelle

<étapes exactes qu'un humain suit pour confirmer>

## Hors-scope

<code mort / problèmes latents pour une issue séparée>
```

## Pour finir

Renvoyer l'URL de la PR. Dire clairement que c'est un **Draft** et que la recette (UAT), le passage en « Ready for review » et le merge reviennent à l'utilisateur. Si le dépôt a GitHub Actions, rapporter l'état des checks (`gh pr checks <numéro>`) et signaler s'ils sont encore en cours ou en échec. Indiquer ce qui a été committé et ce qui a été volontairement exclu, puis rappeler le nettoyage ci-dessous.

## Après le merge - nettoyage

Une fois la PR fusionnée sur GitHub (et la branche supprimée, à la main ou par l'option « Automatically delete head branches » du dépôt), le dépôt local ne le sait pas encore. Le synchroniser :

```bash
git checkout main
git pull origin main        # récupère le merge
git fetch -p                # retire les références aux branches supprimées sur GitHub
git branch -d <branche>     # supprime la branche locale, devenue inutile
```

Version courte : `git checkout main && git pull && git fetch -p && git branch -d <branche>`.

`git branch -d` refuse de supprimer une branche non fusionnée : c'est voulu. Ne jamais forcer avec `-D` sans l'accord de l'utilisateur, car le travail non fusionné serait perdu.

## Hors périmètre

- Jamais de `git add .` ni de `git add -A` par-dessus des changements sans rapport ; ne committer que le changement en cours.
- Jamais de passage en « Ready for review » (`gh pr ready`), d'approbation ni de merge sans instruction explicite.
- Jamais de push direct sur `main`.
- Jamais de `git branch -D`, `git push --force` ni de suppression de branche distante sans accord explicite.
