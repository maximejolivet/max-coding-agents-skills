---
name: migrate-db
description: Conçoit et vérifie des migrations de base de données sûres - réversibles, sans verrou long, en expand/contract pour les changements incompatibles, avec sauvegarde, essai sur une copie et plan de retour. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core + dev). À utiliser quand l'utilisateur écrit ou relit une migration (Doctrine, Prisma, Alembic, Laravel, SQL), change un schéma, renomme ou supprime une colonne, migre des données, ou invoque /max:migrate-db.
---

# Migrations de base de données sûres

Un schéma change **sans interrompre le service** et sans perdre de données. Une migration est du code de production : réversible, testée, relue.

## Détecter la stack

Suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack et l'outil de migration (Doctrine Migrations, Prisma, Alembic/Django, Laravel, Flyway…), puis charger `stacks/<stack>/INDEX.md` pour la nature **dev** (qui tire `core`). Sans ressource, s'en tenir aux conventions lues dans le projet. Ne jamais `Read` une ressource inexistante.

## Cadrer

1. **Le changement** : ce qui doit exister avant/après, en une phrase.
2. **La base cible** : moteur et version, taille des tables touchées (`SELECT count(*)`, taille sur disque), trafic, environnements (dev, recette, production).
3. **Compatibilité** : l'ancien code tourne-t-il encore pendant le déploiement ? Si oui, le changement doit être compatible avec les deux versions.

## Règles de sûreté

- **Réversible** : fournir le `down` (ou dire pourquoi c'est impossible, par exemple une suppression de données).
- **Petit et atomique** : une migration = un changement logique ; ne pas mélanger schéma et grosse migration de données.
- **Verrous** : sur une grosse table, éviter les opérations qui bloquent (ajout de colonne avec défaut non constant, `ALTER` de type, index sans `CONCURRENTLY` sous PostgreSQL). Consulter la documentation du moteur et de la version.
- **Expand / contract** pour tout changement incompatible (renommer, supprimer, changer un type) :
  1. *expand* : ajouter la nouvelle structure, écrire dans les deux ;
  2. *migrer* les données par lots ;
  3. basculer la lecture sur la nouvelle structure ;
  4. *contract* : supprimer l'ancienne structure dans un déploiement **ultérieur**.
- **Données** : migration par lots, idempotente, reprenable ; jamais de `UPDATE` sans `WHERE` borné sur une grosse table.
- **Contraintes** : `NOT NULL` et clés étrangères ajoutées en dernier, après remplissage des données.

## Vérifier

1. Lancer la migration **sur une copie** des données réalistes ; mesurer la durée et les verrous.
2. Lancer `up`, puis `down`, puis `up` : le schéma final est identique.
3. Lancer la suite de tests contre le nouveau schéma (`/max:test`).
4. Écrire le **plan de retour** : sauvegarde nommée, commande de retour, point de non-retour.

## Format de la réponse

1. Le changement, la base cible et l'outil de migration.
2. Le plan (une ou plusieurs migrations, ordre de déploiement) et pourquoi.
3. Les risques : verrous, durée estimée, compatibilité avec l'ancien code.
4. La vérification réelle (up/down/up, tests) et le plan de retour.

## Hors périmètre

- Jamais de migration lancée sur la production ou un environnement partagé, ni de `DROP`, `TRUNCATE` ou `DELETE` massif, sans accord explicite et sauvegarde vérifiée.
- Ne pas modifier une migration déjà appliquée ailleurs : en écrire une nouvelle.
- La relecture relève de `/max:review`, les tests de `/max:test`.
