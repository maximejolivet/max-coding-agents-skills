---
name: symfony
description: Guide le développement Symfony (6.4, 7.x, 8.x) - architecture, services, contrôleurs, Doctrine, formulaires et validation, sécurité, Messenger, Twig, tests. Lit d'abord le code existant du projet, propose l'approche, implémente, puis renvoie vers /max:review. À utiliser quand l'utilisateur implémente ou modifie du code Symfony, ajoute un service, un contrôleur, une entité, une commande ou un handler Messenger, ou demande de l'aide sur Symfony, ou invoque /max:symfony.
---

# Développer avec Symfony

Entrée du développement Symfony. Ce skill décrit le **déroulé du travail** ; la connaissance de Symfony elle-même est centralisée dans `stacks/symfony/`, afin que `/max:review`, `/max:pr-review` et `/max:security` s'appuient sur la même source.

## Charger la connaissance Symfony

Lire `${CLAUDE_SKILL_DIR}/../../stacks/symfony/INDEX.md` pour la nature **dev** : elle inclut `## core` (détection, standard de code, injection de dépendances, attributs, environnements, secrets, versions) et `## dev` (structure, services, événements, Doctrine, formulaires, sécurité, Messenger, Twig, tests). Garder cette discipline tout au long du travail.

**`dev` est un socle, pas toujours suffisant.** Quand la demande va au-delà du développement courant, charger aussi la nature adaptée, pour construire avec le bon réflexe dès le départ :

- Demande liée à la **sécurité, aux accès ou à l'exposition de données** (authentification, droits, données privées, dépôt de fichiers, avis de sécurité à traiter) : lire aussi `## security`.
- Intervention sur du **code existant à ne pas casser**, ou changement où standard de code et performances sont l'enjeu principal : lire aussi `## review` pour garder sa checklist en tête (la passe formelle viendra avec `/max:review`).
- Demande de **conteneurisation ou de déploiement** : elle relève de `/max:docker` ou `/max:kubernetes`, qui chargent `## deploy`.

Ne charger que le pertinent ; ne pas tout lire par réflexe.

## Partir de la demande

Si l'utilisateur fournit une issue ou un brief, le lire d'abord et en tirer : le comportement attendu, les contraintes et risques, les fichiers ou services à examiner en premier. Sans cela, demander l'intention en une ligne avant de coder. Ces contraintes déterminent aussi les natures supplémentaires à charger.

## Identifier la version et le contexte

La détection de la stack suit `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (`stacks/detect.sh`) : si le projet n'est pas Symfony, le dire et orienter vers le skill de la bonne techno au lieu d'appliquer des règles Symfony à autre chose.

Avant de choisir une API, savoir sur quoi on travaille :

```bash
composer show symfony/framework-bundle 2>/dev/null | head -5
bin/console about 2>/dev/null | head -20
```

- La **version de Symfony** (voir « Versions » dans la ressource) dicte les API disponibles : `#[IsGranted]` du cœur depuis la 6.2, annotations retirées en 7.0, etc. Aucun code qui exige une API absente de la version du projet, ni qui s'appuie sur une API déjà dépréciée dans cette version.
- Le **runner** du projet : `make`, puis `docker compose`. Lancer `bin/console` et `vendor/bin/*` à travers lui.

## Lire l'existant avant d'écrire

Pour ne rien réinventer ni dupliquer, **lire le code en place** (sauf si c'est déjà fait dans la session) :

- Parcourir `src/` (contrôleurs, services, entités, dépôts, écouteurs, commandes, handlers) et lire `config/services.yaml`, `config/packages/`, `config/routes/` et `composer.json`.
- Repérer les **services, interfaces, traits et classes de base** à étendre ou à injecter, ainsi que les **idiomes locaux** (organisation par domaine ou par type, nommage, DTO, manière de valider), pour que le nouveau code ressemble au projet.
- Noter ce que le changement va toucher, décorer ou remplacer, et signaler les conflits **avant** de coder.

**Sur un gros projet** (plusieurs dizaines de fichiers concernés, ou demande encore floue), confier cette exploration à l'agent **`max:codebase-surveyor`** via l'outil Agent plutôt que d'encombrer le contexte : lui passer la racine du projet, la tâche en quelques lignes, la stack détectée, le chemin de `stacks/<stack>/INDEX.md` et les dossiers à voir en premier. Il rend un résumé de 40 lignes maximum ; relire soi-même les fichiers qu'on va vraiment modifier. Sur un petit projet, lire directement.

Résumer en quelques lignes ce qui a été trouvé (ou confirmer qu'il n'y a rien à réutiliser) avant de proposer une approche.

## Démarche

1. **Classer** le problème : logique métier, infrastructure ou présentation.
2. **Proposer** l'approche la plus propre (structure, services, événements, Doctrine, décoration) en appliquant `## dev`.
3. **Implémenter** par petits pas : un service, son test, puis son branchement.
4. **Signaler** les cas limites.
5. **Signaler** les points de performance : requêtes N+1, `flush()` en boucle, travail à déporter dans Messenger.
6. **Signaler** les tests à ajouter ou mettre à jour et comment les lancer ; les écrire quand c'est raisonnable.
7. **Vérifier avant de conclure** : exécuter ce qui peut l'être via le runner et rapporter ce qui a réellement tourné.

```bash
bin/console lint:container
bin/console lint:yaml config
bin/console lint:twig templates
bin/console doctrine:schema:validate
vendor/bin/phpunit            # la partie liée au changement
vendor/bin/phpstan analyse    # si installé
vendor/bin/php-cs-fixer fix --dry-run --diff   # si installé
```

Un outil absent se note « (indispo) » : rien n'est installé pour l'occasion, et aucun contrôle n'est déclaré passé s'il n'a pas tourné.

8. **Faire relire** : le changement terminé, lancer **`/max:review`** pour un verdict classé par gravité avant d'ouvrir la pull request, puis `/max:pull-request`. Le travail n'est pas fini tant que cette revue n'a pas tourné.

## Garde-fous

- Ne pas toucher à la base de données du projet (`doctrine:schema:update --force`, `doctrine:database:drop`, `doctrine:fixtures:load`) sans accord explicite ; passer par des **migrations** (`doctrine:migrations:diff`) et les relire avant de les proposer.
- Aucun secret dans le code, un `.env` versionné ou la configuration : variables d'environnement et coffre de secrets.
- Ne pas désactiver une protection (CSRF, `access_control`, échappement Twig) pour « faire passer » un cas.
- Rester dans le périmètre demandé : signaler un problème voisin plutôt que de le corriger en passant.
