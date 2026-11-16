---
name: migrate-db
description: Conçoit et vérifie des migrations de base de données sûres - réversibles, sans verrou long, en expand/contract pour les changements incompatibles, avec sauvegarde, essai sur une copie et plan de retour. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core + dev). À utiliser quand l'utilisateur écrit ou relit une migration (Doctrine, Prisma, Alembic, Laravel, SQL), change un schéma, renomme ou supprime une colonne, migre des données, ou invoque /max:migrate-db.
---

# Migrations de base de données sans casse

Faire évoluer un schéma **sans couper le service** ni perdre de données. Une migration est du code de production : elle doit être réversible, testée et relue.

## Stack

Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack et l'outil de migration (Doctrine Migrations, Prisma, Alembic/Django, Laravel, Flyway…), puis lire `stacks/<stack>/INDEX.md` pour la nature **dev** (qui inclut `core`). Sans ressource, s'en tenir aux conventions lues dans le projet. Ne jamais `Read` une ressource inexistante.

## Cadrer

1. **Le changement** : l'état avant et après, en une phrase.
2. **La base visée** : moteur et version, taille des tables concernées (`SELECT count(*)`, poids sur disque), trafic, environnements (dev, recette, production).
3. **Compatibilité** : l'ancien code continue-t-il de tourner pendant le déploiement ? Si oui, le changement doit convenir aux deux versions.

## Règles de sûreté

- **Réversible** : écrire le `down`, ou expliquer pourquoi c'est impossible (suppression de données, par exemple).
- **Petite et atomique** : une migration = un changement logique ; ne pas mêler schéma et gros transfert de données.
- **Verrous** : sur une grosse table, éviter les opérations bloquantes (colonne ajoutée avec défaut non constant, `ALTER` de type, index sans `CONCURRENTLY` sous PostgreSQL). Vérifier dans la documentation du moteur et de sa version.
- **Expand / contract** pour tout changement incompatible (renommer, supprimer, changer un type) :
  1. *expand* : ajouter la nouvelle structure et écrire dans les deux ;
  2. *migrer* les données par lots ;
  3. basculer la lecture vers la nouvelle structure ;
  4. *contract* : retirer l'ancienne structure lors d'un déploiement **ultérieur**.
- **Données** : par lots, idempotente, reprenable ; jamais d'`UPDATE` sans `WHERE` borné sur une grosse table.
- **Contraintes** : `NOT NULL` et clés étrangères en dernier, une fois les données remplies.

## Vérifier

1. Jouer la migration **sur une copie** de données réalistes ; mesurer durée et verrous.
2. Enchaîner `up`, `down`, `up` : le schéma final doit être identique.
3. Lancer la suite de tests sur le nouveau schéma (`/max:test`).
4. Rédiger le **plan de retour** : sauvegarde nommée, commande de retour, point de non-retour.

## Forme de la réponse

1. Le changement, la base visée et l'outil de migration.
2. Le plan (une ou plusieurs migrations, ordre de déploiement) et sa justification.
3. Les risques : verrous, durée estimée, compatibilité avec l'ancien code.
4. La vérification réellement effectuée (up/down/up, tests) et le plan de retour.

## Limites

- Aucune migration sur la production ou un environnement partagé, aucun `DROP`, `TRUNCATE` ou `DELETE` massif sans accord explicite et sauvegarde vérifiée.
- Une migration déjà appliquée ailleurs ne se modifie pas : en écrire une nouvelle.
- La relecture relève de `/max:review`, les tests de `/max:test`.
