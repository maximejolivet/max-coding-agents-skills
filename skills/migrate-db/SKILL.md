---
name: migrate-db
description: "Conçoit et vérifie une migration de base de données sûre - réversible, sans verrou long, en expand/contract pour un changement incompatible, essayée sur une copie, avec un plan de retour. À utiliser quand Maxime écrit ou relit une migration (Doctrine, Prisma, Alembic, Django, Laravel, SQL), change un schéma, renomme ou supprime une colonne, migre des données, ou invoque /max:migrate-db."
argument-hint: "[changement de schéma]"
---

# Migrer une base

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lire `<max>/references/regles.md`, une fois par session.
2. Détecter la stack : suivre `<max>/stacks/DETECT.md`, nature **dev**. Annoncer l'outil de migration du projet.
3. Relever la cible : moteur et version, taille des tables touchées (`SELECT count(*)`), environnements, et si l'ancien code tourne encore pendant le déploiement.

## Étapes

1. Écrire le changement en une phrase : l'état avant, l'état après.
2. Choisir le plan. Un changement compatible tient en une migration. Un changement incompatible (renommer, supprimer, changer un type) passe en expand/contract :
   1. ajouter la nouvelle structure et écrire dans les deux ;
   2. migrer les données par lots ;
   3. basculer la lecture ;
   4. retirer l'ancienne structure dans un déploiement ultérieur.
3. Écrire la migration avec son `down`, un changement logique par migration.
4. La jouer sur une copie de données réalistes : mesurer la durée et les verrous.
5. Enchaîner `up`, `down`, `up` : le schéma final est identique.
6. Lancer la suite de tests sur le nouveau schéma (`/max:test`).
7. Rendre le plan de déploiement et le plan de retour : sauvegarde nommée, commande de retour, point de non-retour.

Sur une grosse table : pas de colonne ajoutée avec un défaut non constant, pas d'`ALTER` de type, index créé avec `CONCURRENTLY` sous PostgreSQL. Vérifier dans la documentation du moteur et de sa version. `NOT NULL` et clés étrangères viennent en dernier, une fois les données remplies.

## Points d'arrêt

- Le `down` est impossible (suppression de données) : le dire et faire valider.
- Aucune copie de données n'est disponible : la migration reste non vérifiée, le dire.
- La migration mêle schéma et gros transfert de données : la scinder.
- La migration à corriger est déjà appliquée ailleurs : en écrire une nouvelle.

## Ce qu'il ne fait pas

- Lancer une migration sur la production ou un environnement partagé.
- `DROP`, `TRUNCATE`, `DELETE` massif, ou `UPDATE` sans `WHERE` borné sur une grosse table.
- Migrer des données en une seule passe non reprenable.
