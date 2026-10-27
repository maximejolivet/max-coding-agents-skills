---
name: symfony
description: Guide le développement Symfony (6.4, 7.x, 8.x) - architecture, services, contrôleurs, Doctrine, formulaires et validation, sécurité, Messenger, Twig, tests. Lit d'abord le code existant du projet, propose l'approche, implémente, puis renvoie vers /max:review. À utiliser quand l'utilisateur implémente ou modifie du code Symfony, ajoute un service, un contrôleur, une entité, une commande ou un handler Messenger, ou demande de l'aide sur Symfony, ou invoque /max:symfony.
---

# Développement Symfony

Point d'entrée du développement Symfony. Ce skill porte le **workflow** ; le savoir Symfony lui-même vit dans la ressource partagée `stacks/symfony/`, pour que `/max:review`, `/max:pr-review` et `/max:security` puisent à la même source.

## Charger le savoir Symfony

Charger `${CLAUDE_SKILL_DIR}/../../stacks/symfony/INDEX.md` pour la nature **dev** : elle tire `## core` (détection, standard de code, injection de dépendances, attributs, environnements, secrets, versions) et `## dev` (structure, services, événements, Doctrine, formulaires, sécurité, Messenger, Twig, tests). Appliquer cette discipline pendant tout le travail ci-dessous.

**`dev` est la base, pas toujours assez.** Quand la demande dépasse du développement courant, charger aussi la nature concernée pour construire avec le bon regard dès le départ :

- Demande touchant la **sécurité, les accès ou l'exposition de données** (authentification, droits, données privées, envoi de fichiers, avis de sécurité à corriger) → lire aussi la section `## security`.
- Travail sur du **code existant à ne pas casser**, ou changement où le standard de code et les performances sont le cœur du sujet → lire aussi `## review`, pour garder sa checklist en tête (la passe formelle se fait ensuite avec `/max:review`).
- Demande de **conteneurisation ou de déploiement** → relève de `/max:docker` ou `/max:kubernetes`, qui chargent la section `## deploy`.

Charger ce qui est pertinent, ignorer le reste - ne pas tout lire par réflexe.

## Partir de la demande

Si l'utilisateur donne une issue ou un brief, le lire d'abord et en extraire : le comportement attendu, les contraintes et risques, et les fichiers ou services à examiner en premier. S'il n'y en a pas, demander l'intention en une ligne avant de coder. Ces contraintes décident aussi quelles natures supplémentaires charger.

## Repérer la version et le contexte

La détection de la stack elle-même suit `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (`stacks/detect.sh`) : si le projet n'est pas un projet Symfony, le dire et orienter vers le skill de la bonne techno plutôt que d'appliquer des règles Symfony à autre chose.


Avant de choisir une API, savoir sur quoi on travaille :

```bash
composer show symfony/framework-bundle 2>/dev/null | head -5
bin/console about 2>/dev/null | head -20
```

- La **version de Symfony** (voir « Versions » dans la ressource) décide des API disponibles : `#[IsGranted]` du cœur depuis la 6.2, annotations retirées en 7.0, etc. Ne pas écrire de code qui exige une API absente de la version du projet, ni d'API déjà dépréciée dans cette version.
- Le **runner** du projet : `make` → `docker compose`. Lancer `bin/console` et `vendor/bin/*` à travers lui.

## Explorer le code existant d'abord

Avant d'écrire du code, **lire l'existant** pour ne pas réinventer ni dupliquer. Sauf si cela a déjà été fait dans la session :

- Lister `src/` (contrôleurs, services, entités, dépôts, écouteurs, commandes, handlers) et lire `config/services.yaml`, `config/packages/`, `config/routes/` et `composer.json`.
- Repérer les **services, interfaces, traits et classes de base** à étendre ou à injecter plutôt qu'à refaire, les **idiomes locaux** (organisation par domaine ou par type, nommage, DTO, façon de valider) pour que le nouveau code s'accorde au style du projet.
- Relever ce que le changement va toucher, décorer ou remplacer, et signaler les conflits **avant** de coder.

**Sur un gros projet** (plusieurs dizaines de fichiers pertinents, ou une demande encore floue), déléguer cette exploration à l'agent **`max:codebase-surveyor`** avec l'outil Agent plutôt que de remplir le contexte : lui donner la racine du projet, la tâche en quelques lignes, la stack détectée, le chemin de la ressource `stacks/<stack>/INDEX.md` et les dossiers à regarder en premier. Il rend un résumé de 40 lignes au plus ; relire lui-même les fichiers qu'on va réellement modifier. Sur un petit projet, lire directement.

Résumer en quelques lignes ce qui a été trouvé (ou confirmer qu'il n'y a rien de réutilisable) avant de proposer une approche.

## Démarche

1. **Classer** le problème : logique métier, infrastructure ou présentation.
2. **Proposer** l'approche la plus propre (structure, services, événements, Doctrine, décoration), en appliquant la section `## dev`.
3. **Puis** implémenter, par petits pas : un service, son test, puis son branchement.
4. **Mentionner** les cas limites.
5. **Mentionner** les points de performance : requêtes N+1, `flush()` en boucle, travail à déporter dans Messenger.
6. **Mentionner** les tests à ajouter ou mettre à jour, et comment les lancer. Les écrire quand c'est raisonnable.
7. **Vérifier avant de conclure** : lancer ce qui peut l'être via le runner et rapporter ce qui a réellement tourné.

```bash
bin/console lint:container
bin/console lint:yaml config
bin/console lint:twig templates
bin/console doctrine:schema:validate
vendor/bin/phpunit            # la partie liée au changement
vendor/bin/phpstan analyse    # si installé
vendor/bin/php-cs-fixer fix --dry-run --diff   # si installé
```

Les outils absents se notent « (indispo) » : ne rien installer pour l'occasion, et ne jamais affirmer qu'un contrôle est passé s'il n'a pas tourné.

8. **Relire avant de finir** - une fois le changement terminé, lancer **`/max:review`** pour obtenir un verdict classé par gravité avant d'ouvrir la pull request, puis `/max:pull-request`. Ne pas considérer le travail comme fini tant que cette revue n'a pas tourné.

## Garde-fous

- Ne pas modifier la base de données du projet (`doctrine:schema:update --force`, `doctrine:database:drop`, `doctrine:fixtures:load`) sans accord explicite ; passer par des **migrations** (`doctrine:migrations:diff`) et les relire avant de les proposer.
- Ne jamais écrire de secret dans le code, `.env` versionné ou la configuration ; utiliser les variables d'environnement et le coffre de secrets.
- Ne pas désactiver une protection (CSRF, `access_control`, échappement Twig) pour « faire passer » un cas.
- Rester dans le périmètre demandé : signaler un problème voisin plutôt que de le corriger en passant.
