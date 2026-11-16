# Symfony

```bash
composer show symfony/framework-bundle 2>/dev/null | head -5
bin/console about 2>/dev/null | head -20     # version, fin de maintenance, fin de vie
```

Lire `## core`, puis la section de la nature (tableau : `stacks/DETECT.md`). Valable pour 6.4, 7.x et 8.x.

---

## core

### Repérer

- Signaux : `symfony/framework-bundle` dans `composer.json`, `bin/console`, `config/bundles.php`, `symfony.lock`.
- Commandes : `bin/console` et `vendor/bin/*`, lancés par le runner du projet.
- Standard : PSR-12 et règles `@Symfony` de PHP CS Fixer.

### Règles

- `declare(strict_types=1);` et types de paramètres et de retour partout.
- Injection par le constructeur. Jamais `$container->get()`, `$this->get()` ni service locator sans raison.
- Attributs pour les routes, Doctrine, écouteurs, commandes et contraintes. Ni annotations ni YAML, sauf convention locale.
- La configuration propre à un environnement vit dans `config/packages/<env>/`, jamais dans un `if`.
- Secrets : `.env.local` non versionné ou coffre (`bin/console secrets:set`). `.env` ne porte que des défauts non sensibles.

### Versions

Ne pas écrire de date de support ni de version de PHP en dur : les lire sur <https://symfony.com/releases>.

Support et montées :

- Une version absente des versions supportées est un constat de fin de vie, même sans CVE.
- Monter mineure par mineure. La dernière mineure d'une branche (6.4, 7.4) porte les API dépréciées et leurs remplaçants : y corriger toutes les dépréciations avant la majeure suivante.
- Relever les dépréciations : journal `deprecation` de `var/log/`, sortie des tests avec `symfony/phpunit-bridge`, `bin/console debug:container --deprecations`.
- Rector, si le projet l'a : `SymfonySetList` en `--dry-run`, puis relire le diff.
- Juger le code d'après la version du projet, pas d'après la dernière.

Ce qui varie :

| API | Disponibilité |
| :-- | :-- |
| `#[IsGranted]` du cœur | depuis 6.2 ; avant, `sensio/framework-extra-bundle` |
| `#[AsDecorator]` | depuis 6.1 |
| Annotations (routes, validation, Doctrine) | dépréciées en 6.4, retirées en 7.0 |
| `password_hashers` | remplace `encoders` depuis 5.3 ; `encoders` absent en 6.x |
| `lint:translations` | selon la version ; `lint:xliff` partout |

---

## dev

### Où va le code

- Un contrôleur valide l'entrée, appelle un service, renvoie une réponse. Rien d'autre.
- Requêtes dans les dépôts, avec `setParameter`. Un `flush()` par unité de travail, jamais dans une boucle.
- Schéma : `doctrine:migrations:diff`, puis relire la migration. `schema:update --force` reste au poste local.
- Droits : `#[IsGranted]` ou voters, pas de test de rôle dispersé.
- Travail long : Messenger, handlers idempotents, messages qui portent des identifiants et non des entités.

### Étendre

- Décorer un service du framework (`#[AsDecorator]`) plutôt que le modifier.
- Écouteurs courts (`#[AsEventListener]`, `EventSubscriberInterface`) qui délèguent à un service.
- Formulaires : `AbstractType` ou DTO avec contraintes `Assert`. La validation serveur reste, même si le front valide.
- Twig : aucune logique métier, échappement automatique conservé.

### Vérifier

```bash
bin/console lint:container
bin/console lint:yaml config
bin/console lint:twig templates
bin/console doctrine:schema:validate
vendor/bin/phpunit                              # la partie liée au changement
vendor/bin/phpstan analyse                      # si installé
vendor/bin/php-cs-fixer fix --dry-run --diff    # si installé
```

Diagnostic : `bin/console debug:container`, `debug:router`, `debug:event-dispatcher`, `debug:config`.

### Ne pas faire sans accord

- `doctrine:schema:update --force`, `doctrine:database:drop`, `doctrine:fixtures:load`.
- Désactiver CSRF, `access_control` ou l'échappement Twig pour faire passer un cas.

---

## review

### Injection et contrôleurs

- Service pris dans le conteneur, `ContainerInterface` injecté, `new MonService()`.
- Constructeur aux dépendances trop nombreuses.
- Logique métier ou requête Doctrine dans un contrôleur.
- Route sans `#[IsGranted]` ni voter.
- `Request` lue sans validation.

### Doctrine

- N+1 : boucle sur une relation lazy sans jointure ni `fetch join`.
- `flush()` dans une boucle.
- `EAGER` ajouté pour masquer un N+1.
- Entité modifiée sans migration.
- Migration irréversible, ou qui mêle schéma et données.

### Formulaires, Twig, configuration

- Champ sans contrainte, `allow_extra_fields`, affectation de masse.
- CSRF désactivé sans raison.
- `|raw` ou `autoescape` coupé sur une donnée d'utilisateur.
- Valeur d'environnement en dur, secret dans un `.env` versionné.

### Messenger, résidus, dépréciations

- Handler non idempotent, message qui embarque une entité, aucune stratégie d'échec.
- `dump()`, `dd()`, `var_dump()`, `error_log()`, code commenté, `TODO` sans issue.
- API dépréciée dans du code neuf : Mineur, Majeur si une montée de version est prévue.

### Linters

Les commandes de `dev` > « Vérifier », sur les fichiers modifiés si possible.

### Outils complémentaires

Seulement s'ils sont déjà dans `composer.json` ou `vendor/bin/` ; sinon « (indispo) ».

Analyse :

- `phpstan` avec `phpstan-symfony` et `phpstan-doctrine`.
- `vendor/bin/rector process --dry-run`.
- `vendor/bin/psalm`.
- `vendor/bin/deptrac analyse`.
- `vendor/bin/phpcs`, si le projet impose son propre ruleset.

Dépendances, traductions, tests :

- `composer validate --strict`.
- `vendor/bin/composer-require-checker check`, `composer unused`.
- `bin/console lint:xliff translations`.
- `vendor/bin/behat`, Panther.
- `vendor/bin/infection` : long, jamais par défaut.

---

## security

### Avis et fin de vie

- `composer audit --locked` fait référence pour `symfony/*`.
- Annonces : <https://symfony.com/blog/category/security-advisories> et <https://github.com/advisories?query=symfony>.
- `symfony security:check` complète s'il existe. Ne pas le supposer présent.
- Sans réseau : extraire de `composer.lock` les paquets `symfony/*` et recouper à la main.
- Version hors support sur <https://symfony.com/releases> : constat à part entière.

### Production

- `APP_ENV=prod`, `APP_DEBUG=0`.
- `_wdt` et `_profiler` injoignables.
- `APP_SECRET` unique, long, absent du dépôt.
- `trusted_proxies` et `trusted_hosts` configurés derrière un proxy.

### Accès et authentification

- `security.yaml` : `access_control` couvre toutes les routes sensibles, et l'ordre des règles compte.
- Voters pour les droits liés à un objet (IDOR sinon).
- `password_hashers: auto`, aucun hachage maison.
- `rate_limiter` sur la connexion et la réinitialisation du mot de passe.
- Cookies de session `secure`, `httponly`, `samesite`.

### Entrées, fichiers, secrets

- DQL et SQL à paramètres liés, jamais concaténés.
- CSRF actif sur les formulaires et les actions qui modifient l'état ; `|raw` surveillé.
- Fichiers envoyés : taille, type MIME réel et extension validés, stockés hors du répertoire public, jamais exécutés.
- CORS (`nelmio/cors-bundle`) limité aux origines connues, pas de `*` avec identifiants.
- `.env.local` et `config/secrets/*/*.decrypt.private.php` absents du dépôt.

### Outils complémentaires

Seulement s'ils sont déjà disponibles ; sinon « (indispo) ».

- `composer outdated --direct` : hygiène, pas preuve de faille.
- `roave/security-advisories` en `require-dev` : constat Info s'il manque.
- `gitleaks detect` ou `trufflehog filesystem .`.
- `semgrep --config p/php`, `trivy fs .`.
- `bin/console debug:config security`, `debug:router` : ce qui est réellement exposé.

---

## test

### Outil et niveaux

PHPUnit (`vendor/bin/phpunit`, `phpunit.xml.dist`) ou Pest, en `APP_ENV=test`, par le runner.

| Niveau | Classe | Pour |
| :-- | :-- | :-- |
| Unitaire | `PHPUnit\Framework\TestCase` | logique pure, sans conteneur |
| Intégration | `KernelTestCase` | un service avec ses vraies dépendances |
| Fonctionnel | `WebTestCase` | une route : statut, contenu, droits. Les contrôleurs se testent ici |
| Navigateur | Panther | quelques parcours JavaScript critiques |

### Base et données

- Base dédiée (`DATABASE_URL` de `.env.test`), jamais celle de développement.
- Avant la suite : `doctrine:database:create --env=test`, puis `doctrine:migrations:migrate --env=test --no-interaction`.
- Isolation : `dama/doctrine-test-bundle` s'il est installé, sinon base vidée entre les tests.
- Données : `zenstruck/foundry` s'il est installé, sinon builders maison. Aucun jeu partagé.

### Doublures

| Frontière | Moyen |
| :-- | :-- |
| Utilisateur connecté | `$client->loginUser($user)` ; tester aussi les refus (403, redirection) |
| Service externe | `static::getContainer()->set(...)` |
| E-mails | `assertEmailCount()` |
| Messenger | transport `in-memory://` |
| HTTP sortant, horloge | `MockHttpClient`, `MockClock` |

### Autres contrôles

- Commandes console : `CommandTester`, code de retour et sortie.
- Contraintes : `$validator->validate()` ou `TypeTestCase`.
- Dépréciations émises pendant les tests (`SYMFONY_DEPRECATIONS_HELPER`) : à traiter, elles préparent une montée cassée.
- Couverture : Xdebug ou PCOV s'ils sont installés.

---

## deploy

### Image

- Runtime : PHP-FPM derrière Nginx ou Caddy, ou FrankenPHP. Suivre le choix du projet.
- Étape finale : `composer install --no-dev --optimize-autoloader --no-scripts --classmap-authoritative`, `APP_ENV=prod`, `APP_DEBUG=0`, `bin/console cache:warmup --env=prod`.
- Assets (`asset-map:compile`, Encore ou Vite) dans une étape dédiée ; pas de `node_modules` dans l'image finale.
- Seul `var/` est inscriptible. Logs sur `php://stderr`.
- `.dockerignore` : `.env*`, `var/`, `vendor/`, `.git`. Aucun `APP_SECRET` dans l'image.

Santé : une route `/health` qui ne dépend pas de la base pour la liveness. Extensions : seulement celles utilisées, `opcache` actif.

### Compose (développement)

- Base de données avec `healthcheck`, attendue par `depends_on: condition: service_healthy`.
- Code en bind mount ; `vendor/` et `var/` en volumes nommés.
- Mailpit et un worker Messenger si le projet en a besoin.

### Kubernetes

- Un Deployment web, un Deployment par worker : `messenger:consume <transport> --time-limit=3600 --memory-limit=256M`.
- Migrations dans un `Job` ou un hook Helm `pre-upgrade`, une fois par déploiement, jamais dans l'entrypoint.
- Tâches planifiées en `CronJob`, pas de `cron` dans le conteneur web.
- `readOnlyRootFilesystem: true` avec `emptyDir` sur `var/` ; `trusted_proxies` derrière l'Ingress.
- Sessions, cache et fichiers téléversés hors du pod : Redis, base, stockage objet.

### CI

Avant de construire l'image : `composer validate --strict`, `composer audit --locked`, `bin/console lint:container`, `lint:yaml config`, tests. Cache Composer indexé sur `composer.lock`.
