---
name: security
description: "Audite la sécurité des dépendances et de l'infrastructure d'un projet - lockfiles et outils d'audit de chaque écosystème, avis du framework, configuration Docker, workflows GitHub Actions - classe chaque constat selon son risque réel dans le projet, puis propose le correctif ciblé ou la marche à suivre. À utiliser quand Maxime demande un audit de sécurité, une vérification de CVE ou de dépendances, ou invoque /max:security."
---

# Audit de sécurité

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. Lister ce qui existe :

   ```bash
   ls composer.lock package-lock.json pnpm-lock.yaml yarn.lock poetry.lock uv.lock requirements*.txt go.sum Gemfile.lock Cargo.lock 2>/dev/null
   ls Dockerfile* docker-compose*.y*ml compose*.y*ml 2>/dev/null
   ls .github/workflows/*.y*ml .github/dependabot.yml 2>/dev/null
   ```

3. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **security**. Son tableau « Défauts par langage » donne la commande d'audit de chaque écosystème.

## Étapes

1. Annoncer les domaines audités (dépendances, Docker, GitHub Actions) et ceux qui sont écartés faute de fichiers.
2. Choisir le mode et l'annoncer. Un mode demandé par Maxime (« audit rapide », « audit complet ») prime.

   | Domaines présents | Mode |
   | :-- | :-- |
   | Un seul | Passe unique : lire la section `## Contrôles` de l'agent du domaine dans `${CLAUDE_SKILL_DIR}/../../agents/` et l'appliquer |
   | Deux ou plus | Délégation : un agent par domaine, lancés dans le même tour avec l'outil Agent |

   | Agent (`subagent_type`) | Lancer quand |
   | :-- | :-- |
   | `max:dependencies-auditor` | un lockfile existe |
   | `max:docker-auditor` | un Dockerfile ou un fichier compose existe |
   | `max:actions-auditor` | `.github/workflows/` existe |

3. Fusionner : dédoublonner, revérifier dans les fichiers chaque Critique et chaque Élevée, rejuger la gravité à l'échelle du projet. Un constat peut en aggraver un autre : une action non épinglée avec un token en écriture sur un dépôt qui publie des images.
4. Classer avec l'échelle de l'annexe et expliquer tout écart avec la gravité de l'avis.
5. Donner pour chaque constat un correctif ciblé ou une marche à suivre (annexe).
6. Rendre le rapport au format de l'annexe. S'il y a des correctifs à livrer : `/max:review`, puis `/max:pull-request`.

## Points d'arrêt

- Aucune ressource pour la stack : le dire, seule la couverture générique s'applique.
- Un outil d'audit n'atteint pas le réseau : descendre d'un échelon (runner, hôte, puis `WebFetch`). Jamais « 0 vulnérabilité » sans audit réel.
- Un agent échoue ou ne répond pas : le dire et auditer ce domaine en une passe.
- Avant d'appliquer un correctif : attendre la demande de Maxime. Après : relancer l'audit.
- Un secret trouvé : `fichier:ligne`, jamais la valeur.

## Ce qu'il ne fait pas

- Exploiter une faille, écrire un payload, sonder une cible en production.
- Monter tout l'arbre de dépendances pour faire taire un avis.
- Livrer une sortie d'audit brute.
- Relever les bugs applicatifs du code maison (injection, XSS) : `/max:review`.

## Annexe

### Brief des agents

Aucun agent ne voit la conversation. Donner à chacun :

1. La racine absolue du projet et ses fichiers : lockfiles, Dockerfile et compose, workflows.
2. Le runner, et `owner/repo` sur GitHub.
3. Le chemin absolu de la ressource de stack, ou « pas de ressource de stack ».
4. À l'auditeur de dépendances : la commande d'audit de chaque écosystème.
5. Le rappel : lecture seule, aucun `update`, aucun `audit fix`, aucun build.

### Criticité

Jugée dans le projet, pas d'après le seul CVSS.

| Niveau | Sens |
| :-- | :-- |
| Critique | Exploitable à distance sur du code livré : exécution de code, contournement d'authentification, secret exposé, évasion de conteneur |
| Élevée | Vulnérabilité sérieuse sur un chemin atteignable, ou privilège et secret sous condition |
| Moyenne | Réelle mais contrainte : authentification requise, chemin difficile, surface peu exposée |
| Faible | Développement seulement, théorique, ou exigeant déjà des droits élevés |
| Info | Hygiène sans CVE : paquet abandonné, image non épinglée, version en fin de vie |

Ce qui déplace un constat : production ou développement, exécution ou build, exposé ou interne, version corrigée disponible, chemin vulnérable réellement utilisé.

### Remédiation

| Cas | Réponse |
| :-- | :-- |
| Correctif sûr et mécanique | La commande ciblée : `composer require <vendor>/<paquet>:^X.Y`, `npm audit fix` sans rupture |
| Montée majeure | Étapes de migration, quoi tester, ce qui risque de casser |
| Aucune version corrigée | La parade (configuration, règle WAF, fonction coupée, épinglage) et quoi surveiller |
| Mise à jour avec migration de schéma | Étapes ordonnées, sauvegarde de la base d'abord |
| Paquet abandonné | Remplacer, forker ou supprimer, avec le compromis de chaque option |

Chaque montée de version se limite au paquet concerné et à ses dépendances nécessaires.

### Format de sortie

Première ligne : décompte par gravité et action la plus urgente. Puis une ligne par domaine audité :

| Domaine | Audité | Critique | Élevée | Moyenne | Faible | Info |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| Dépendances (prod) | ✅ | … | … | … | … | … |
| Docker | ✅ | … | … | … | … | … |
| GitHub Actions | ✅ | … | … | … | … | … |

Un domaine n'est « audité » que si son outil a réellement tourné.

```
- [Critique] <paquet/composant> - <vulnérabilité> (CVE/GHSA/SA-id)
  Affecté : <plage de versions> · Installé : <actuelle> · Corrigé en : <version | pas encore>
  Risque ici : <pourquoi cette gravité DANS ce projet - atteignable ? prod ? exposé ?>
  Correctif : <commande exacte, ou marche à suivre numérotée si cassant>
- [Moyenne] <composant> - <vulnérabilité> (<id>) → <remédiation en une ligne>
Info : <paquet X non supporté> ; <image de base Y non épinglée> ; <action Z non épinglée sur un SHA>
```

Dernière section : ce qui n'a pas pu être vérifié, avec l'échelon atteint.
