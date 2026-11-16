---
name: review
description: "Relit un changement de code avant le merge - correction, sécurité, performance, standards, tests - et rend un verdict classé par gravité avec le correctif exact de chaque constat. Dernière vérification avant livraison au client. À utiliser quand Maxime demande de relire un diff, une branche, un correctif ou une PR avant de l'ouvrir, ou invoque /max:review."
argument-hint: "[numéro ou URL de PR | branche | fichier]"
---

# Revue de code

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session. Elle donne la branche par défaut (`<défaut>`).
2. Fixer le périmètre, dans cet ordre :

   | Donné par Maxime | Commande |
   | :-- | :-- |
   | Une PR (URL ou numéro) | `gh pr view <n> -R <owner>/<repo>`, `gh pr diff <n> -R …`, `gh pr checks <n> -R …` |
   | Un diff, un fichier, une branche | celui-là |
   | Rien, sur une branche | `git diff <défaut>...HEAD` |
   | Rien, sur `<défaut>` | `git diff`, `git diff --cached` |

3. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **review**.
4. Mesurer : `git diff --shortstat <défaut>...HEAD`, ou la liste des fichiers de la PR.

## Étapes

1. Choisir le mode et l'annoncer en une ligne. Un mode demandé par Maxime (« passe rapide », « revue approfondie ») prime.

   | Changement | Mode |
   | :-- | :-- |
   | Jusqu'à 150 lignes environ, sur 3 fichiers au plus | Passe unique |
   | Au-delà, ou plusieurs préoccupations mêlées (données, accès, interface) | Délégation |

2. **Passe unique.** Lire la section `## Contrôles` de chaque agent concerné dans `${CLAUDE_SKILL_DIR}/../../agents/`, puis l'appliquer au diff et à son contexte : fonction, appelants, route, formulaire.
3. **Délégation.** Lancer les agents retenus dans le même tour, avec l'outil Agent et le brief de l'annexe.

   | Agent (`subagent_type`) | Lancer quand |
   | :-- | :-- |
   | `max:correctness-reviewer` | toujours |
   | `max:security-reviewer` | toujours |
   | `max:standards-reviewer` | toujours |
   | `max:frontend-reviewer` | la stack a un framework front et le diff touche des fichiers front (`.vue`, `.tsx`, `.jsx`, styles) |

4. Lancer ce qui peut l'être par le runner : `make lint`, sinon `docker compose exec <svc> <linter> <chemin>`. Si la PR a des résultats GitHub Actions, les lire au lieu de les rejouer.
5. Fusionner : dédoublonner à la gravité la plus haute, revérifier dans le code chaque Bloquant et chaque Majeur, écarter ce qui ne se reproduit pas à la lecture.
6. Rendre le verdict au format de l'annexe.

## Points d'arrêt

- Aucune ressource pour la stack : le dire dans le verdict (« pas de resource review pour la stack `<x>` - dimensions génériques uniquement »).
- Un agent échoue ou ne répond pas : le dire et couvrir sa dimension en une passe.
- Un contrôle prévu n'a pas tourné : pas de verdict « livrable » sans nommer ce qui reste non vérifié.
- Un secret ou une donnée client dans le diff : constat Bloquant, valeur jamais recopiée.

## Ce qu'il ne fait pas

- Modifier le code : il donne le correctif, Maxime décide.
- Réécrire l'architecture à partir d'un diff.
- Signaler ce que le changement n'a pas introduit : une ligne en hors-scope.
- Ouvrir la PR : quand le verdict est livrable, renvoyer vers `/max:pull-request`.
- Auditer les dépendances ou l'infrastructure : `/max:security`.

## Annexe

### Brief des agents

Aucun agent ne voit la conversation. Donner à chacun :

1. Le diff, ou la commande exacte qui l'affiche, et l'intention en quelques lignes.
2. Le chemin absolu de la ressource de stack, ou « pas de ressource de stack ».
3. Le runner du projet, s'il est connu.
4. Le rappel : lecture seule.

### Gravité et verdict

| Niveau | Sens |
| :-- | :-- |
| Bloquant | À corriger avant le merge : perte de données, faille, fonctionnalité cassée |
| Majeur | À corriger : bug de correction ou de performance, contrôle d'accès absent |
| Mineur | Utile : cas limite, cache faible, hypothèse fragile |
| Détail | Facultatif : style, nommage |

Verdict : un Bloquant ou un Majeur donne **modifications nécessaires** ; seulement Mineur ou Détail, **livrable avec détails** ; rien, **livrable**. Il se calcule sur la liste fusionnée.

Maîtrise du bruit :

- Aucun constat sans conséquence nommée.
- Bloc `Pourquoi` / `Action` pour Bloquant et Majeur seulement.
- Un Mineur tient en une ligne.
- Les Détails se replient sur une ligne finale, dépliée seulement sur demande.

### Format de sortie

Verdict en première ligne. Tableau limité aux dimensions ⚠️ ou ❌ ; les dimensions saines sur une ligne (`✅ Sécurité, Tests`). Si tout passe : le verdict seul.

```
- [Bloquant|Majeur] <symptôme> (<fichier>:<ligne>)
  Pourquoi : <raison>
  Action : <modification ou commande exacte - copiable, jamais « investiguer X »>
- [Mineur] <symptôme> (<fichier>:<ligne>) - <correctif en ligne>
Détails : <a> ; <b> ; <c>
```

Puis, seulement s'il y a matière : `Vérifié` (ce qui a réellement tourné), `Non vérifié`, `Hors-scope`, étapes de recette manuelle.
