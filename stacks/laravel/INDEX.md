# Stack : Laravel - spécificités

Point d'entrée des spécificités Laravel (Forme 1 : fichier unique sectionné). L'appelant lit `## core` plus la section correspondant à sa nature. Promouvoir une section en fichier voisin (Forme 2) si elle grossit.

Nature → sections :

| Appelant                           | Sections        |
| ---------------------------------- | --------------- |
| `/max:review`, `/max:pr-review`    | core + review   |
| `/max:security`                    | core + security |
| `/max:test`                        | core + test     |
| `/max:docker`, `/max:kubernetes`   | core + deploy   |
| `/max:debug`, `/max:refactor`, `/max:perf`, `/max:migrate-db`, `/max:a11y` | core + dev |

---

## core

- **Détection** : `laravel/framework` dans `composer.json`, fichier `artisan`. Version : `composer show laravel/framework` ; lire le guide de mise à niveau de la version cible avant d'affirmer qu'une API existe.
- **Structure** : `app/` (Models, Http/Controllers, Jobs, Policies), `routes/`, `database/migrations`, `config/`, `resources/`. Ne pas modifier `vendor/` ni `bootstrap/cache`.
- **Commandes** : `php artisan` (`route:list`, `migrate`, `test`, `queue:work`), `composer`, `./vendor/bin/pint` (formatage), `./vendor/bin/phpstan` si présent. Lire `composer.json` (scripts) avant de supposer.
- **Configuration** : `.env` jamais committé ; lire la configuration via `config('…')`, jamais `env()` hors des fichiers de `config/` (cassé après `config:cache`).
- **Eloquent** : propriétés `$fillable` / `$guarded` explicites, relations déclarées, casts pour les types.

---

## dev

- **Contrôleurs fins** : la logique métier va dans des actions/services, des Form Requests pour la validation, des Policies pour l'autorisation.
- **Validation** : Form Request (`rules()`, `authorize()`) plutôt que `$request->all()` ; n'utiliser que `validated()`.
- **Requêtes** : charger les relations avec `with()` (éviter le N+1), `chunkById` / `lazy` pour les gros volumes, transactions (`DB::transaction`) pour les écritures liées.
- **Files et tâches** : travail lent dans un `Job` en file (`ShouldQueue`), idempotent, avec `tries` / `backoff`.
- **Migrations** : réversibles (`down`), jamais modifiées une fois appliquées ailleurs (voir `/max:migrate-db`).
- **Ressources d'API** : `JsonResource` pour la forme des réponses, pas de modèle Eloquent renvoyé brut.
- **Qualité** : `pint`, analyse statique, `php artisan test` doivent passer.

---

## review

- **Mass assignment** - `$guarded = []`, `Model::unguard()`, `create($request->all())`.
- **N+1** - relation lue dans une boucle sans `with()`, `count()` répétés.
- **Validation / autorisation** - route sans Policy ni middleware `can`, validation dans le contrôleur au lieu d'un Form Request.
- **`env()` hors config**, `dd()` / `dump()` / `Log::debug` oubliés, `DB::raw` avec entrée utilisateur.
- **Migrations** - non réversible, `dropColumn` sans plan de retour, verrou long sur une grosse table.
- **Files** - job non idempotent, pas de `tries`, effet de bord avant la transaction validée (`afterCommit`).

---

## security

- **Mises à jour** : `composer audit` ; avis du framework sur le site officiel et dans les alertes Dependabot.
- **Configuration** : `APP_DEBUG=false` et `APP_KEY` définie en production ; `.env` hors du dépôt et hors du web root (`public/` seul exposé).
- **Entrées** : protection CSRF active (`@csrf`), échappement Blade `{{ }}` (attention à `{!! !!}`), requêtes paramétrées (pas de concaténation dans `DB::raw` / `whereRaw`).
- **Accès** : Policies / Gates sur chaque ressource, limitation de débit (`throttle`) sur la connexion et les API, Sanctum / Passport correctement configurés.
- **Fichiers** : validation du type et de la taille des uploads, disque privé par défaut.

---

## test

- **Outils** : Pest ou PHPUnit (`php artisan test`) ; `RefreshDatabase` / `DatabaseTransactions` ; factories et seeders pour les données.
- **Niveaux** : Feature (HTTP, base) pour le comportement, Unit pour la logique pure. Simuler le temps (`Carbon::setTestNow`), les files (`Queue::fake`), les mails (`Mail::fake`), le HTTP externe (`Http::fake`).
- **Règles** : un test vérifie un comportement, pas l'implémentation ; tester l'autorisation autant que le cas nominal.

---

## deploy

- **Build** : `composer install --no-dev --optimize-autoloader`, puis `php artisan config:cache route:cache view:cache` ; assets via Vite (`npm run build`).
- **Exécution** : PHP-FPM derrière un serveur web pointant sur `public/` ; `php artisan migrate --force` à part, jamais au démarrage de chaque instance sans verrou ; `queue:work` en processus supervisé ; planificateur (`schedule:run`) toutes les minutes.
- **Image** : multi-étapes, utilisateur non root, `storage/` et `bootstrap/cache` en écriture, `.env` injecté par l'environnement.
