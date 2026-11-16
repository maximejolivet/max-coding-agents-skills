---
name: review
description: Relit un changement de code avant le merge - bugs de correction, sécurité, performance, standards de code, couverture de tests - et rend un verdict structuré, classé par gravité, avec des actions concrètes. Indépendant de la stack - s'adapte au projet (ex. Symfony) en chargeant sa ressource dans stacks/ ; workflow orienté GitHub. À utiliser quand l'utilisateur demande de relire un diff, une branche, un correctif ou un changement avant de préparer une pull request, ou invoque /max:review.
---

# Revue de code

Relire un changement précis et rendre un verdict que l'auteur peut appliquer tel quel. Viser la qualité et la correction, pas les remarques de style gratuites. Rester direct : ce qui ne va pas, pourquoi, et le correctif exact.

## Délimiter ce qu'on relit

Déterminer le périmètre dans cet ordre :

1. **Une PR GitHub (URL ou numéro)** donnée par l'utilisateur. La récupérer avec `gh`, sans copier-coller :
   ```bash
   gh pr view <numéro> -R <owner>/<repo>    # titre, description, branches, issue liée
   gh pr diff <numéro> -R <owner>/<repo>    # le diff à relire
   gh pr checks <numéro> -R <owner>/<repo>  # GitHub Actions / checks de statut
   ```
   Le `-R` vient de l'URL (`https://github.com/<owner>/<repo>/pull/<numéro>`) ; sur GitHub Enterprise, définir `GH_HOST=<hôte>`.
2. Un diff, un fichier ou une branche que l'utilisateur désigne.
3. À défaut, la branche courante comparée à sa base (`git diff <base>...HEAD`, base généralement `main`).
4. À défaut, le diff de l'arbre de travail (`git diff` / `git diff --cached`).

Lire les lignes modifiées **et** assez de code autour pour les juger (la fonction, ses appelants, le formulaire, la route ou le service concerné). Jamais un hunk isolé quand le bug peut se cacher dans son contexte.

## Détecter la stack

Ce skill est indépendant de la stack ; la checklist propre à la techno vient d'une ressource chargée à la demande. Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` : lancer `stacks/detect.sh`, annoncer la stack, puis lire `stacks/<stack>/INDEX.md` pour la nature **review** (qui inclut `core` + `review`). Si le changement touche plusieurs technos (backend et front), charger chacune et n'appliquer à chaque fichier que les règles de la sienne.

**Repli** : si la stack n'a pas de ressource (ligne `resource` à `aucune`) ou si son `INDEX.md` n'expose pas de section `review` / `core`, appliquer les dimensions génériques ci-dessous avec les indices de `DETECT.md` et **le dire** dans le verdict (« pas de resource review pour la stack `<x>` - dimensions génériques uniquement »). Ne jamais `Read` une ressource inexistante, ne jamais échouer en silence.

## Choisir le mode

Mesurer d'abord le changement (`git diff --shortstat <base>...HEAD`, ou la liste des fichiers de la PR) :

- **Petit changement** : jusqu'à ~150 lignes modifiées sur 3 fichiers au plus. Le relire soi-même en **une seule passe** avec les dimensions ci-dessous.
- **Gros changement** : au-delà, ou dès que plusieurs préoccupations se mêlent (modèle de données + accès + interface). **Déléguer** aux agents de relecture ci-dessous, puis fusionner. Indiquer le mode choisi en une ligne.

Chaque agent coûte des jetons et du temps : ne lancer que ceux dont le périmètre est réellement touché (colonne « Lancer quand »), jamais les quatre par réflexe.

L'utilisateur peut imposer un mode (« passe rapide », « review approfondie ») ; cela prime sur la règle de taille.

## Déléguer aux agents de relecture

Lancer les agents retenus **dans le même tour** pour qu'ils tournent en parallèle, chacun via l'outil Agent :

| Agent (`subagent_type`) | Couvre | Lancer quand |
| --- | --- | --- |
| `max:correctness-reviewer` | Correction, cause racine, régressions | toujours en mode délégué |
| `max:security-reviewer` | Sécurité applicative du code modifié | toujours en mode délégué |
| `max:standards-reviewer` | Standards (linters), performance, tests, checks CI | toujours en mode délégué |
| `max:frontend-reviewer` | Hydratation, état et effets, composants, accessibilité, paquet | la détection remonte un framework front (nuxt, vue, react, nextjs, angular, svelte) **et** le diff touche des fichiers front (`.vue`, `.tsx`, `.jsx`, composants, styles) |

Donner à chaque agent le même brief, court et précis (liste des fichiers modifiés plutôt que « tout le dépôt »), car aucun ne voit cette conversation :

1. Le diff, ou la commande exacte qui l'affiche (`git diff <base>...HEAD`, `gh pr diff <numéro> -R <owner>/<repo>`), et l'intention de la PR ou de l'issue en quelques lignes.
2. Le chemin absolu de la ressource `stacks/<stack>/INDEX.md` chargée (ou « pas de ressource de stack »).
3. Le runner du projet (`make` / `docker compose`) quand il est connu.
4. Qu'il est en **lecture seule** : aucune modification, aucun commit, aucun push.

Ensuite, **fusionner** soi-même leurs réponses : les agents rapportent, c'est toi qui tranches.

- Dédoublonner : un même défaut vu par deux agents devient un seul constat, à la gravité la plus haute attribuée.
- Revérifier dans le code chaque constat Bloquant et Majeur avant de le garder. Écarter ce qui ne se reproduit pas à la lecture, et le mentionner si cela compte.
- Appliquer les règles de **Gravité** et de **Maîtrise du bruit** ci-dessous, ainsi que le **Format de sortie**. Le verdict se calcule sur la liste fusionnée, pas agent par agent.
- Rassembler les lignes `Vérifié` / `Non vérifié` / `Checks` de chaque agent dans un seul résumé de vérification. Un check n'est « passé » que si un agent l'a réellement exécuté.
- Si un agent échoue ou ne renvoie rien, le dire et couvrir soi-même sa dimension en une passe, au lieu de la déclarer saine.

## Dimensions de revue

Ce sont celles d'une **passe unique**, et la référence que les agents se partagent. Évaluer chacune et ne rapporter que ce qui s'applique :

- **Correction** : le changement fait-il ce que dit l'issue ou l'intention ? Suivre le flux de contrôle réel. Pour une régression, confirmer que la cause racine est traitée et pas seulement un symptôme. Quand c'est possible, **vérifier empiriquement** (construire le formulaire, appeler le service, exécuter le chemin) plutôt qu'affirmer.
- **Sécurité** : validation des entrées, contrôles d'accès, SQL/XSS/CSRF, secrets, frontières de privilèges. Signaler tout ce qui élargit la surface d'attaque.
- **Performance et cache** : appliquer la checklist de la stack chargée (ex. la couche HTTP/cache du framework, requêtes N+1). En général : travail inutile sur les chemins chauds, cache absent, motifs N+1.
- **Standards** : respecter l'**idiome local** du fichier (ne pas imposer l'injection de dépendances à un module entièrement procédural, par exemple) et le standard de code de la stack. Lancer les linters (voir plus bas) plutôt que d'estimer à l'œil.
- **Tests** : la logique nouvelle est-elle couverte ? Si le projet n'a aucune infrastructure de tests, le dire et la recommander (ne pas fabriquer un test isolé inutilisable) ; documenter plutôt des étapes de recette manuelle.

## Exécuter ce qui peut l'être

Préférer les signaux réels à l'opinion. Préfixer linters et sondes rapides par le runner du projet (`make`, puis `docker compose`). La commande exacte du linter vient de la stack chargée (ex. `php -l`, `phpcs`, `phpstan`, `eslint`), lancée via ce runner :

```bash
make lint                                   # si le projet l'expose
docker compose exec <svc> <linter> <chemin> # sinon
```

Si la PR a déjà des résultats GitHub Actions, les lire (`gh pr checks`) plutôt que de relancer ce que la CI couvre, et traiter un check rouge comme un constat.

Ne déclarer un check « passé » qu'après l'avoir réellement exécuté. Si un outil est absent, écrire « (indispo) », jamais qu'il est passé.

## Gravité

Étiqueter chaque constat d'un niveau ; le verdict en découle mécaniquement :

- **Bloquant** : à corriger avant le merge (perte de données, faille de sécurité, fonctionnalité cassée).
- **Majeur** : à corriger (bug de correction ou de performance, contrôle d'accès manquant).
- **Mineur** : utile à corriger (cas limite, cache faible, hypothèse fragile).
- **Détail** : facultatif (style, nommage).

Verdict : au moins un Bloquant/Majeur → **modifications nécessaires** ; seulement Mineur/Détail → **livrable avec détails** ; rien → **livrable**.

**Maîtrise du bruit** : rapporter le signal, pas chaque observation.

- Les **Détails** sont _repliés par défaut_ : les regrouper sur une ligne finale (`Détails : <a> ; <b> ; <c>`), ou les omettre si le changement est propre. Ne les déplier que si l'utilisateur demande une passe complète.
- Un **Mineur** tient en une ligne (symptôme + correctif en ligne) : pas de bloc `Pourquoi` / `Action`.
- Réserver le bloc complet `Pourquoi` / `Action` aux seuls **Bloquant/Majeur**.
- Ne pas meubler : aucun constat sans conséquence concrète. Si on ne peut pas nommer ce qui casse, c'est au mieux un Détail.

## Format de sortie

Ouvrir par le verdict en une ligne (livrable / livrable avec détails / modifications nécessaires). Rester concis : ne montrer que ce qui informe.

**Tableau des dimensions** : ne lister que les dimensions ⚠️/❌ ; regrouper toutes les dimensions saines sur une seule ligne sous le tableau (`✅ Sécurité, Cache, Tests`). Si _tout_ passe, sauter le tableau et ne donner que le verdict.

| Dimension                          | Verdict               |
| ---------------------------------- | --------------------- |
| <uniquement les dimensions ⚠️/❌> | ⚠️ / ❌ + une ligne |

Puis les constats, du plus grave au plus léger. Bloc complet pour **Bloquant/Majeur** ; une ligne pour **Mineur** ; **Détails** repliés sur une dernière ligne (voir Maîtrise du bruit) :

```
- [Bloquant|Majeur] <symptôme> (<fichier>:<ligne>)
  Pourquoi : <raison>
  Action : <modification ou commande exacte - copiable, jamais « investiguer X »>
- [Mineur] <symptôme> (<fichier>:<ligne>) - <correctif en ligne>
Détails : <a> ; <b> ; <c>
```

Conclure seulement s'il y a quelque chose à ajouter : notes **Hors-scope** (problèmes latents pour une issue séparée) et **étapes de recette manuelle** quand c'est pertinent. Omettre une section vide plutôt que d'écrire « aucun ». Quand le verdict est livrable ou livrable avec détails, orienter l'auteur vers `/max:pull-request` pour ouvrir la PR.

## Limites

- Ne pas réécrire l'architecture à partir d'un diff : recommander, cadrer, laisser l'auteur décider.
- Ne pas signaler un comportement antérieur que le changement n'a pas introduit : le noter comme hors-scope.
- Ne pas approuver ce qui n'a pas pu être vérifié ; dire ce qui ne l'est pas.
