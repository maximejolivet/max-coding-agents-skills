# Stack : Symfony - spécificités

Point d'entrée des particularités de Symfony (Forme 1 : un fichier unique découpé en sections). Le skill appelant lit `## core` puis la section correspondant à sa nature. Si une section grossit trop, la promouvoir en fichier voisin (Forme 2).

Nature → sections :

| Appelant                           | Sections        |
| ---------------------------------- | --------------- |
| `/max:symfony`                     | core + dev      |
| `/max:test`                        | core + test     |
| `/max:review`, `/max:pr-review`    | core + review   |
| `/max:security`                    | core + security |
| `/max:docker`, `/max:kubernetes`   | core + deploy   |

---

## core

- **Détection** : `symfony/framework-bundle` (ou `symfony/symfony`) dans `composer.json`, présence de `bin/console`, `config/bundles.php` ou `symfony.lock`.
- **Standard de code** : PSR-12 plus les règles Symfony (`@Symfony` de PHP CS Fixer). `declare(strict_types=1);` en tête de fichier, types de paramètres et de retour partout.
- **Injection de dépendances** : par le constructeur, avec autowiring et autoconfiguration. Jamais de service récupéré dans le conteneur (`$container->get()`, `$this->get()`), jamais de service locator sans raison.
- **Configuration par attributs** : routes (`#[Route]`), entités Doctrine (`#[ORM\…]`), écouteurs (`#[AsEventListener]`), commandes (`#[AsCommand]`), contraintes de validation (`#[Assert\…]`). Dans les versions récentes, ni annotations ni YAML pour cela, sauf convention locale contraire.
- **Environnements** : `APP_ENV` et `APP_DEBUG` pilotent le comportement ; la configuration propre à un environnement vit dans `config/packages/<env>/`, jamais dans un `if` du code.
- **Secrets** : variables d'environnement (`.env` pour les valeurs par défaut non sensibles, `.env.local` non versionné) et coffre de secrets (`bin/console secrets:set`) pour le reste.
- **Versions** : viser une version LTS ou la dernière stable encore supportée ; la fin de vie se vérifie sur <https://symfony.com/releases>.
- **Runner** : les commandes passent par `bin/console` et `vendor/bin/*`, lancés via le runner du projet (`make`, puis `docker compose`).

### Versions (6.4, 7.x, 8.x)

Les règles de ce fichier valent pour 6.4, 7.x et 8.x ; ce qui change d'une version à l'autre est listé ici. Ne pas écrire en dur de dates de support ni de version de PHP : elles évoluent, les lire à la source.

- **Repérer la version** : `composer show symfony/framework-bundle` ou la ligne correspondante de `composer.lock`. `bin/console about` affiche la version installée avec ses dates de fin de maintenance et de fin de vie.
- **Support** : seule une version listée comme telle sur <https://symfony.com/releases> reçoit des correctifs de sécurité. Toute version hors support (une 6.0 à 6.3, une 7.0 à 7.3 si elle est dépassée) est un constat de fin de vie, même sans CVE nommée.
- **Montées de version** : avancer version mineure par version mineure, sans en sauter. La dernière mineure d'une branche majeure (6.4, 7.4) sert de pont vers la majeure suivante : elle contient les API dépréciées et leurs remplaçants. Corriger toutes les dépréciations sur cette mineure, puis passer à la majeure suivante (7.0, 8.0), qui supprime ce code.
- **Dépréciations** : les relever avant toute montée (journal `deprecation` dans `var/log/` en dev, sortie des tests avec `symfony/phpunit-bridge` s'il est présent, `bin/console debug:container --deprecations`). Employer du code déprécié dans un nouveau changement est un constat Mineur, Majeur si une montée de version est prévue.
- **Points qui varient** :
  - `#[IsGranted]` du cœur (`Symfony\Component\Security\Http\Attribute`) existe depuis la 6.2 ; avant, il venait de `sensio/framework-extra-bundle`.
  - `#[AsDecorator]` existe depuis la 6.1.
  - Les annotations (routes, validation, Doctrine) sont dépréciées en 6.4 et retirées en 7.0 : en 7.x et 8.x, signaler toute annotation restante et la remplacer par un attribut.
  - `password_hashers` remplace `encoders` depuis la 5.3 ; `encoders` n'existe plus en 6.x.
  - La commande `lint:translations` dépend de la version ; `lint:xliff` fonctionne partout.
- **Rector** : si le projet l'utilise, ses jeux de règles Symfony par version (`SymfonySetList`) automatisent une partie des montées ; les lancer en `--dry-run` et relire le diff.
- **En revue** : juger le code d'après la version du projet, pas d'après la dernière. Ne pas exiger une API absente de sa version, ni reprocher une pratique encore normale dans sa branche.

---

## dev

Pour écrire du code Symfony (référence ; aucun skill dédié pour l'instant).

- **Structure** : contrôleurs fins dans `src/Controller`, logique métier dans des services (`src/Service` ou par domaine), entités dans `src/Entity`, dépôts dans `src/Repository`. Un contrôleur valide l'entrée, appelle un service, renvoie une réponse.
- **Services** : un service = une responsabilité, avec une interface quand plusieurs implémentations existent. Préférer la composition ; décorer (`#[AsDecorator]`) plutôt que modifier un service du framework.
- **Événements** : `EventSubscriberInterface` ou `#[AsEventListener]` pour réagir aux événements du noyau ou du domaine ; garder les écouteurs courts et déléguer à un service.
- **Doctrine** : requêtes dans les dépôts, jamais dans les contrôleurs ; `QueryBuilder` ou DQL avec paramètres liés (`setParameter`) ; un `flush()` par unité de travail, pas dans une boucle ; modifications de schéma par migrations (`doctrine:migrations:diff`), jamais `schema:update --force` hors du développement local.
- **Formulaires et validation** : types de formulaire (`AbstractType`) ou DTO + contraintes `Assert` ; la validation se fait côté serveur même si le front la reproduit.
- **Sécurité** : droits par `#[IsGranted]` ou des voters (`Voter`), pas de tests de rôle éparpillés dans les contrôleurs.
- **Asynchrone** : Messenger pour le travail long ; handlers idempotents, messages petits et sérialisables (identifiants plutôt qu'entités).
- **Twig** : logique en PHP, pas dans les gabarits ; échappement automatique conservé.
- **Tests** : PHPUnit ; `KernelTestCase` pour les services, `WebTestCase` pour les routes ; une base de test dédiée ; aucun test dépendant de l'ordre d'exécution.
- **Diagnostic** : `bin/console debug:container`, `debug:router`, `debug:event-dispatcher`, `debug:config`.

---

## review

Lue par `/max:review` et `/max:pr-review`. Vient s'ajouter aux dimensions génériques.

- **Injection de dépendances** : service récupéré via le conteneur, `ContainerInterface` injecté, dépendance statique ou instanciation directe d'un service (`new MonService()`), constructeur qui prend trop de dépendances (signe d'une classe qui en fait trop).
- **Contrôleurs** : logique métier ou requête Doctrine dans le contrôleur, contrôle d'accès absent (`#[IsGranted]` / voter), `Request` lue sans validation.
- **Doctrine** : requête N+1 (boucle sur une relation lazy sans jointure ni `fetch join`), `flush()` dans une boucle, `EAGER` ajouté pour « réparer » un N+1, entité modifiée sans migration, migration irréversible ou mêlant schéma et données.
- **Validation et formulaires** : champs sans contrainte, `allow_extra_fields` ou mass assignment, protection CSRF désactivée sans raison.
- **Twig** : `|raw` ou `autoescape` désactivé sur une donnée venant d'un utilisateur.
- **Configuration** : valeur d'environnement écrite en dur, secret dans un `.env` versionné, paramètre propre à un environnement dans le code.
- **Messenger** : handler non idempotent, message embarquant une entité entière, absence de stratégie de retry / d'échec.
- **Résidus** : `dump()`, `dd()`, `var_dump()`, `error_log()`, code commenté, `TODO` sans issue.
- **Dépréciations** : nouvelle API dépréciée utilisée, ou dépréciation ignorée dans la sortie des tests.
- **Linters** (à lancer via le runner, sur les fichiers modifiés si possible) :
  - `vendor/bin/php-cs-fixer fix --dry-run --diff` (standard)
  - `vendor/bin/phpstan analyse` (typage, niveau fixé par le projet)
  - `bin/console lint:container`, `lint:yaml config`, `lint:twig templates`
  - `bin/console doctrine:schema:validate` (mapping cohérent avec la base)
  - `vendor/bin/phpunit` (la partie des tests liée au changement)
- **Outils complémentaires** : à lancer seulement s'ils sont déjà installés dans le projet (`composer.json`, `vendor/bin/`), jamais à installer pour l'occasion ; sinon écrire « (indispo) » :
  - `phpstan` avec `phpstan/phpstan-symfony` et `phpstan/phpstan-doctrine` : comprend le conteneur, les routes et le mapping Doctrine.
  - `vendor/bin/rector process --dry-run` : code à moderniser ou à migrer (attributs, API dépréciées).
  - `vendor/bin/psalm` : analyse statique alternative à PHPStan, si le projet l'emploie.
  - `vendor/bin/deptrac analyse` : respect des frontières entre couches ou modules.
  - `vendor/bin/phpcs` : seulement si le projet impose un ruleset maison à la place de PHP CS Fixer.
  - `vendor/bin/infection` : tests de mutation, utiles sur une logique métier critique (long, à ne pas lancer par défaut).
  - `bin/console lint:xliff translations` (et `lint:translations` selon la version) : fichiers de traduction valides.
  - `composer validate --strict` : `composer.json` cohérent et à jour avec le lockfile.
  - `vendor/bin/composer-require-checker check` et `composer unused` : dépendances utilisées mais non déclarées, ou déclarées mais inutiles.
  - `vendor/bin/behat` ou `bin/console` + Panther (`symfony/panther`) : tests de comportement et de bout en bout, quand le projet en a.

---

## security

Lue par `/max:security`.

- **Avis de sécurité** :
  - `composer audit --locked` fait référence : il s'appuie sur la base d'avis des paquets PHP, qui couvre `symfony/*`. Les avis Symfony sont aussi annoncés sur <https://symfony.com/blog/category/security-advisories> et dans la GitHub Advisory Database (<https://github.com/advisories?query=symfony>).
  - Si la CLI Symfony fournit un contrôle de sécurité (`symfony security:check`), il peut compléter ; ne pas le supposer présent.
  - Extraire du `composer.lock` les paquets `symfony/*` et leurs versions installées, pour recouper à la main quand le réseau manque.
- **Fin de vie** : la version de Symfony est-elle encore maintenue (correctifs de sécurité) ? Vérifier sur <https://symfony.com/releases>. Une version hors support est un constat à part entière, même sans CVE nommée.
- **Production** : `APP_ENV=prod` et `APP_DEBUG=0` ; le profiler et la barre de debug (`_wdt`, `_profiler`) ne doivent pas être joignables ; `APP_SECRET` unique, long, absent du dépôt.
- **Contrôle d'accès** : dans `security.yaml`, des pare-feux (`firewalls`), un `access_control` qui couvre toutes les routes sensibles (l'ordre des règles compte), aucune route d'administration ouverte par défaut ; des voters pour les droits liés à un objet (sinon, risque d'IDOR).
- **Authentification** : hachage de mot de passe via `password_hashers` (`auto`), pas de hachage maison ; limitation du débit (`rate_limiter`) sur la connexion et la réinitialisation de mot de passe ; cookies de session `secure`, `httponly`, `samesite`.
- **Entrées et sorties** : requêtes Doctrine à paramètres liés, jamais de DQL / SQL concaténé ; Twig avec échappement automatique (vigilance sur `|raw`) ; protection CSRF active sur les formulaires et les actions qui modifient l'état.
- **Fichiers** : envois validés (taille, type MIME réel, extension), stockés hors du répertoire public ou renommés, jamais exécutés.
- **Réseau** : `trusted_proxies` et `trusted_hosts` configurés derrière un proxy ; CORS (avec `nelmio/cors-bundle`) restreint aux origines connues, pas de `*` avec identifiants.
- **Secrets** : aucun secret dans `.env`, `config/` ou le code versionné ; coffre de secrets ou variables injectées par l'infrastructure ; `.env.local` et `config/secrets/*/*.decrypt.private.php` absents du dépôt.
- **Outils complémentaires** : seulement s'ils sont déjà disponibles (rien n'est installé), sinon écrire « (indispo) » :
  - `composer outdated --direct` : retard de version des dépendances directes (hygiène, pas preuve de faille).
  - `roave/security-advisories` dans `composer.json` (`require-dev`) : empêche l'installation de versions connues comme vulnérables. Un constat Info s'il manque.
  - `gitleaks detect` ou `trufflehog filesystem .` : recherche de secrets dans le code et l'historique.
  - `semgrep --config p/php` (règles PHP, avec `p/symfony` si disponible) : analyse statique orientée sécurité du code maison.
  - `trivy fs .` : vulnérabilités des dépendances et mauvaises configurations du dépôt, en complément de `composer audit`.
  - `bin/console debug:config security` et `bin/console debug:router` : relire la configuration de sécurité et les routes réellement exposées.
  - `local-php-security-checker` : ancien outil archivé, remplacé par `composer audit` ; ne le citer que s'il est déjà dans le projet.

---

## deploy

Lue par `/max:docker` et `/max:kubernetes` quand le projet est un projet Symfony. Vient s'ajouter à leurs règles générales.

### Image et Dockerfile

- **Runtime** : PHP-FPM derrière un serveur web (Nginx ou Caddy) dans un conteneur séparé, ou FrankenPHP (un seul conteneur, mode worker possible). Suivre le choix déjà fait par le projet.
- **Extensions PHP** : n'installer que celles utilisées (`intl`, `opcache`, `pdo_<pilote>`, `zip`, `apcu` si besoin) ; `opcache` activé en production.
- **Build de production** (étape finale) :
  - `composer install --no-dev --optimize-autoloader --no-scripts --classmap-authoritative` depuis `composer.lock`, puis les scripts nécessaires ;
  - `APP_ENV=prod` et `APP_DEBUG=0` dans l'image ;
  - `bin/console cache:warmup --env=prod` au build, pour ne pas compiler au premier accès ;
  - `bin/console assets:install` et compilation des assets (AssetMapper `asset-map:compile`, ou Webpack Encore / Vite) dans une étape de build dédiée, sans embarquer `node_modules` dans l'image finale.
- **Fichiers inscriptibles** : seul `var/` (cache, logs) doit l'être ; avec un système de fichiers en lecture seule, monter un volume (`emptyDir` sur Kubernetes) sur `var/` et `/tmp`. Journaliser sur `stderr` (canal `php://stderr`), pas dans `var/log/`.
- **Secrets** : jamais de `.env.local`, `.env.*.local` ni `APP_SECRET` dans l'image ; le `.dockerignore` couvre `.env*`, `var/`, `vendor/` (reconstruit) et `.git`.
- **Utilisateur** : non root (`www-data` ou un utilisateur dédié), propriétaire de `var/`.
- **Santé** : une route de santé minimale (par exemple `/health`) qui répond sans dépendre de la base de données pour la liveness ; la readiness peut vérifier la base.

### Docker Compose (développement)

- Services habituels : l'application, le serveur web, la base de données (avec `healthcheck`), éventuellement Mailpit pour les e-mails et un worker Messenger.
- Le code est monté en bind mount en développement ; `vendor/` et `var/` en volumes nommés pour éviter la lenteur des montages.
- `depends_on` avec `condition: service_healthy` pour attendre la base avant les migrations.

### Kubernetes

- **Un Deployment pour le web**, **un Deployment distinct par worker Messenger** (`bin/console messenger:consume <transport> --time-limit=3600 --memory-limit=256M` : le conteneur s'arrête proprement et Kubernetes le relance). Les workers se mettent à l'échelle indépendamment du web.
- **Migrations** : un `Job` (ou un hook Helm `pre-upgrade`) qui lance `bin/console doctrine:migrations:migrate --no-interaction`, exécuté une seule fois avant le déploiement des pods applicatifs ; jamais dans l'entrypoint de chaque réplica.
- **Tâches planifiées** : un `CronJob` par commande (`bin/console app:ma-commande`) ou le Scheduler de Symfony dans un worker dédié ; pas de `cron` dans le conteneur web.
- **Configuration** : variables d'environnement via `ConfigMap` (non sensible) et `Secret` (`APP_SECRET`, `DATABASE_URL`, `MESSENGER_TRANSPORT_DSN`, clés d'API) ; aucun vrai `.env` dans l'image.
- **Probes** : `readinessProbe` et `livenessProbe` sur la route de santé ; `startupProbe` si le premier démarrage (cache) est lent.
- **Sécurité du pod** : `readOnlyRootFilesystem: true` avec `emptyDir` sur `var/` ; `trusted_proxies` configuré dans Symfony derrière l'Ingress pour que l'IP cliente et le schéma HTTPS soient corrects.
- **Fichiers téléversés** : jamais sur le système de fichiers d'un pod (éphémère) ; volume persistant ou stockage objet (Flysystem, S3).
- **Sessions et cache** : stockage partagé (Redis, base de données) dès qu'il y a plusieurs réplicas.

### CI GitHub Actions

- Construire l'image à chaque PR (sans la publier), la publier depuis `main` ou un tag.
- Dans la CI, avant le build : `composer validate --strict`, `composer audit --locked`, `bin/console lint:container`, `lint:yaml config` et les tests ; ces contrôles évitent de publier une image cassée.
- Cache Composer (`actions/cache` sur le répertoire de cache de Composer, clé fondée sur `composer.lock`).

---

## test

Lue par `/max:test` (et utile à `/max:symfony`). Outils et conventions de test d'un projet Symfony.

- **Outil** : PHPUnit (`vendor/bin/phpunit`), configuré par `phpunit.xml.dist` ; Pest si le projet l'a retenu. Lancer via le runner du projet. Environnement `APP_ENV=test` (fichier `.env.test`).
- **Niveaux** :
  - **Unitaire** : `PHPUnit\Framework\TestCase` pour la logique pure, sans conteneur ni base.
  - **Intégration** : `Symfony\Bundle\FrameworkBundle\Test\KernelTestCase` (`self::getContainer()->get(...)`) pour un service avec ses vraies dépendances, base de test comprise.
  - **Fonctionnel** : `WebTestCase` (`$client = static::createClient()`) pour une route de bout en bout : statut, redirection, contenu, droits. Les contrôleurs se testent ici, pas en unitaire.
  - **Bout en bout navigateur** : Symfony Panther (`symfony/panther`) pour quelques parcours critiques en JavaScript.
- **Base de données** : une base **dédiée** aux tests (`DATABASE_URL` dans `.env.test`), jamais celle de développement ou de production. La créer et la migrer avant la suite (`bin/console doctrine:database:create --env=test`, `doctrine:migrations:migrate --env=test --no-interaction`, ou `doctrine:schema:create`). Isoler les tests par transaction avec `dama/doctrine-test-bundle` s'il est installé, sinon vider ou recréer entre les tests.
- **Données** : factories avec `zenstruck/foundry` (états, séquences, `Factory::create()`) quand il est installé, sinon des builders maison ; les fixtures Doctrine ne servent pas de socle à tous les tests. Aucune dépendance à un jeu de données partagé.
- **Authentification** : `$client->loginUser($user)` pour tester un utilisateur connecté sans passer par le formulaire de connexion ; tester explicitement les refus (403, redirection vers la connexion) en plus des succès.
- **Doublures** : `createMock()` / `createStub()` aux frontières seulement. Remplacer un service dans le conteneur de test (`static::getContainer()->set(...)`) pour simuler un appel externe. E-mails : `assertEmailCount()` (`MailerAssertionsTrait`) ; Messenger : transport `in-memory://` et `InteractsWithMessenger` ou assertions du transport ; requêtes HTTP sortantes : `MockHttpClient`.
- **Temps** : `Symfony\Component\Clock\MockClock` avec le composant Clock, ou l'horloge injectée, à la place d'un `new \DateTimeImmutable()` en dur dans le code testé.
- **Formulaires et validation** : tester les contraintes sur le validateur (`$validator->validate()`) ou via `TypeTestCase` pour un type de formulaire.
- **Commandes console** : `CommandTester` ou `ApplicationTester`, en vérifiant code de retour et sortie.
- **Contrôles utiles** : `bin/console lint:container` (le conteneur compile), `doctrine:schema:validate` (mapping cohérent avec la base).
- **Dépréciations** : surveiller la sortie des tests (`SYMFONY_DEPRECATIONS_HELPER`, `symfony/phpunit-bridge` s'il est présent) : un test qui passe en émettant des dépréciations prépare une montée de version cassée.
- **Couverture** : Xdebug ou PCOV (`--coverage-text`) s'ils sont installés ; mutation avec Infection seulement s'il est déjà dans le projet.
