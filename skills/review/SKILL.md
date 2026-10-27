---
name: review
description: Relit un changement de code avant le merge - bugs de correction, sécurité, performance, standards de code, couverture de tests - et rend un verdict structuré, classé par gravité, avec des actions concrètes. Indépendant de la stack - s'adapte au projet (ex. Symfony) en chargeant sa ressource dans stacks/ ; workflow orienté GitHub. À utiliser quand l'utilisateur demande de relire un diff, une branche, un correctif ou un changement avant de préparer une pull request, ou invoque /max:review.
---

# Revue de code

Relire un changement ciblé et rendre un verdict que l'auteur peut appliquer. Viser la qualité et la correction, pas les remarques de style pour le plaisir. Rester direct : dire ce qui ne va pas, pourquoi, et le correctif exact.

## Définir le périmètre

Déterminer ce qu'il faut relire, dans cet ordre :

1. **Une PR GitHub (URL ou numéro)** fournie par l'utilisateur. La récupérer avec `gh`, sans copier-coller :
   ```bash
   gh pr view <numéro> -R <owner>/<repo>    # titre, description, branches, issue liée
   gh pr diff <numéro> -R <owner>/<repo>    # le diff à relire
   gh pr checks <numéro> -R <owner>/<repo>  # GitHub Actions / checks de statut
   ```
   Le `-R` vient de l'URL (`https://github.com/<owner>/<repo>/pull/<numéro>`) ; sur GitHub Enterprise, définir `GH_HOST=<hôte>`.
2. Un diff, un fichier ou une branche explicitement nommé par l'utilisateur.
3. Sinon, la branche courante par rapport à sa base (`git diff <base>...HEAD`, base généralement `main`).
4. Sinon, le diff de l'arbre de travail (`git diff` / `git diff --cached`).

Lire les lignes modifiées **et** assez de code autour pour les juger (la fonction, ses appelants, le formulaire, la route ou le service concerné). Ne jamais relire un hunk isolément quand le bug peut se trouver dans son contexte.

## Détecter la stack

Ce skill reste indépendant de la stack ; la checklist propre à la techno vient d'une ressource chargée à la demande. Suivre la procédure commune `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` : lancer `stacks/detect.sh`, annoncer la stack détectée, puis charger `stacks/<stack>/INDEX.md` pour la nature **review** (elle tire `core` + `review`). Pour un changement qui touche plusieurs techno (backend et front), charger chacune et n'appliquer à chaque fichier que les règles de sa techno.

**Dégradation propre** - si la stack n'a pas de ressource (ligne `resource` à `aucune`) ou si son `INDEX.md` n'expose pas de section `review` / `core`, appliquer les dimensions génériques ci-dessous avec les indices de `DETECT.md` et **le dire** dans le verdict (« pas de resource review pour la stack `<x>` - dimensions génériques uniquement »). Ne jamais `Read` une ressource inexistante, ne jamais échouer en silence.

## Choisir le mode

Évaluer d'abord la taille du changement (`git diff --shortstat <base>...HEAD`, ou la liste des fichiers modifiés de la PR) :

- **Petit changement** - jusqu'à ~150 lignes modifiées réparties sur 3 fichiers au plus : le relire soi-même en **une seule passe** avec les dimensions ci-dessous.
- **Gros changement** - au-delà, ou dès que le changement touche plusieurs préoccupations (modèle de données + accès + interface) : **déléguer** aux agents de relecture ci-dessous, puis fusionner. Indiquer le mode utilisé en une ligne.

Chaque agent coûte des tokens et du temps : ne lancer que ceux dont le périmètre est réellement touché (voir la colonne « Lancer quand »), jamais les cinq par réflexe.

L'utilisateur peut imposer un mode (« passe rapide », « review approfondie ») ; cela l'emporte sur la règle de taille.

## Déléguer aux agents de relecture

Lancer les agents retenus **dans le même tour** pour qu'ils tournent en parallèle, chacun avec l'outil Agent :

| Agent (`subagent_type`) | Couvre | Lancer quand |
| --- | --- | --- |
| `max:correctness-reviewer` | Correction, cause racine, régressions | toujours en mode délégué |
| `max:security-reviewer` | Sécurité applicative du code modifié | toujours en mode délégué |
| `max:standards-reviewer` | Standards (linters), performance, tests, checks CI | toujours en mode délégué |
| `max:frontend-reviewer` | Hydratation, état et effets, composants, accessibilité, paquet | la détection de stack remonte un framework front (nuxt, vue, react, nextjs, angular, svelte) **et** le diff touche des fichiers front (`.vue`, `.tsx`, `.jsx`, composants, styles) |

Donner à chaque agent le même brief, court et précis (liste des fichiers modifiés plutôt que « tout le dépôt »), car aucun ne voit cette conversation :

1. Le diff, ou la commande exacte qui l'affiche (`git diff <base>...HEAD`, `gh pr diff <numéro> -R <owner>/<repo>`), et l'intention de la PR / de l'issue en quelques lignes.
2. Le chemin absolu de la ressource `stacks/<stack>/INDEX.md` chargée (ou « pas de ressource de stack »).
3. Le runner du projet (`make` / `docker compose`) quand il est connu.
4. Qu'il est en **lecture seule** : aucune modification, aucun commit, aucun push.

Ensuite, **fusionner** leurs réponses soi-même - les agents rapportent, c'est toi qui décides :

- Dédoublonner : le même défaut signalé par deux agents devient un seul constat, à la gravité la plus haute donnée.
- Revérifier dans le code chaque constat Bloquant et Majeur avant de le garder. Écarter ce qui ne se reproduit pas à la lecture du code, et dire ce qui a été écarté si cela compte.
- Appliquer les règles **Gravité** et **Maîtrise du bruit** ci-dessous, ainsi que le **Format de sortie**. Le verdict se calcule sur la liste fusionnée, pas par agent.
- Reprendre les lignes `Vérifié` / `Non vérifié` / `Checks` de chaque agent dans un seul résumé de vérification. Un check n'est « passé » que si un agent l'a réellement exécuté.
- Si un agent échoue ou ne renvoie rien, le dire et couvrir soi-même sa dimension en une passe, au lieu de la déclarer propre.

## Dimensions de revue

Ce sont les dimensions d'une **passe unique**, et la référence que les agents se répartissent. Évaluer chacune, et ne rapporter que ce qui s'applique :

- **Correction** - Le changement fait-il ce que dit l'issue ou l'intention ? Suivre le flux de contrôle réel. Pour une régression, confirmer que le changement traite la cause racine et non un symptôme. Quand c'est possible, **vérifier empiriquement** (construire le formulaire, appeler le service, exécuter le chemin) plutôt qu'affirmer.
- **Sécurité** - Validation des entrées, contrôles d'accès, SQL/XSS/CSRF, secrets, frontières de privilèges. Signaler tout ce qui élargit la surface d'attaque.
- **Performance et cache** - Appliquer la checklist de la stack chargée (ex. la couche HTTP/cache du framework, requêtes N+1). En général : travail inutile sur les chemins chauds, cache manquant, motifs N+1.
- **Standards** - Respecter l'**idiome local** du fichier (ne pas imposer l'injection de dépendances à un module entièrement procédural, etc.) et le standard de code de la stack chargée. Lancer les linters (voir plus bas) plutôt que d'estimer à l'œil.
- **Tests** - La nouvelle logique est-elle couverte ? Si le projet n'a pas d'infrastructure de tests, le dire et le recommander (ne pas fabriquer un test isolé et inutilisable) ; documenter plutôt des étapes de recette manuelle.

## Exécuter ce qui peut l'être

Préférer les signaux réels à l'opinion. Préfixer les linters et les sondes rapides avec le runner du projet (`make` → `docker compose`). La commande exacte du linter vient de la stack chargée (ex. `php -l`, `phpcs`, `phpstan`, `eslint`), lancée via ce runner :

```bash
make lint                                   # si le projet l'expose
docker compose exec <svc> <linter> <chemin> # sinon
```

Si la PR a déjà des résultats GitHub Actions, les lire (`gh pr checks`) plutôt que de relancer ce que la CI couvre, et traiter un check rouge comme un constat.

Ne déclarer un check « passé » qu'après l'avoir réellement exécuté. Si un outil est absent, écrire « (indispo) » - ne jamais affirmer qu'il est passé.

## Gravité

Étiqueter chaque constat avec un niveau ; le verdict en découle mécaniquement :

- **Bloquant** - à corriger avant le merge (perte de données, faille de sécurité, fonctionnalité cassée).
- **Majeur** - à corriger (bug de correction ou de performance, contrôle d'accès manquant).
- **Mineur** - utile à corriger (cas limite, cache faible, hypothèse fragile).
- **Détail** - facultatif (style, nommage).

Verdict : au moins un Bloquant/Majeur → **modifications nécessaires** ; seulement Mineur/Détail → **livrable avec détails** ; rien → **livrable**.

**Maîtrise du bruit** - rapporter le signal, pas chaque observation :

- Les constats **Détail** sont _repliés par défaut_ : les regrouper sur une seule ligne finale (`Détails : <a> ; <b> ; <c>`), ou les omettre si le changement est propre. Ne les déplier que si l'utilisateur demande une passe complète.
- Un constat **Mineur** tient en une ligne (symptôme + correctif en ligne) - pas de bloc `Pourquoi` / `Action`.
- Réserver le bloc complet `Pourquoi` / `Action` aux seuls **Bloquant/Majeur**.
- Ne pas meubler : aucun constat sans conséquence concrète. Si l'on ne peut pas nommer ce qui casse, c'est un Détail au mieux.

## Format de sortie

Commencer par le verdict en une ligne (livrable / livrable avec détails / modifications nécessaires). Rester concis - ne montrer que ce qui informe.

**Tableau des dimensions** - ne lister que les dimensions ⚠️/❌ ; regrouper toutes les dimensions saines sur une seule ligne sous le tableau (`✅ Sécurité, Cache, Tests`). Si _tout_ passe, sauter le tableau et donner uniquement le verdict.

| Dimension                          | Verdict               |
| ---------------------------------- | --------------------- |
| <uniquement les dimensions ⚠️/❌> | ⚠️ / ❌ + une ligne |

Puis les constats, du plus grave au moins grave. Bloc complet pour **Bloquant/Majeur** ; une ligne pour **Mineur** ; **Détails** repliés sur une seule ligne finale (voir Maîtrise du bruit) :

```
- [Bloquant|Majeur] <symptôme> (<fichier>:<ligne>)
  Pourquoi : <raison>
  Action : <modification ou commande exacte - copiable, jamais « investiguer X »>
- [Mineur] <symptôme> (<fichier>:<ligne>) - <correctif en ligne>
Détails : <a> ; <b> ; <c>
```

Terminer seulement s'il y a quelque chose à dire : notes **Hors-scope** (problèmes latents pour une issue séparée) et **étapes de recette manuelle** quand c'est pertinent - omettre chaque section si elle est vide plutôt que d'écrire « aucun ». Quand le verdict est livrable / livrable avec détails, orienter l'auteur vers `/max:pull-request` pour ouvrir la PR.

## Hors périmètre

- Ne pas réécrire l'architecture à partir d'un diff. Recommander, cadrer, et laisser l'auteur décider.
- Ne pas signaler un comportement préexistant que le changement n'a pas introduit - le noter comme hors-scope.
- Ne pas approuver ce qui n'a pas pu être vérifié ; dire ce qui ne l'est pas.
