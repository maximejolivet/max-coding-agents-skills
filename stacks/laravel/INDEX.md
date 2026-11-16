# Stack : Laravel - spécificités

Point d'entrée des particularités de Laravel (Forme 1 : un fichier unique découpé en sections). Le skill appelant lit `## core` puis la section correspondant à sa nature. Si une section grossit trop, la promouvoir en fichier voisin (Forme 2).

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

- **Détection** : `laravel/framework` dans `composer.json`, fichier `artisan`. Version : `composer show laravel/framework` ; lire le guide de mise à niveau de la version visée avant d'affirmer qu'une API existe.
- **Structure** : `app/` (Models, Http/Controllers, Jobs, Policies), `routes/`, `database/migrations`, `config/`, `resources/`. Ne pas modifier `vendor/` ni `bootstrap/cache`.
- **Commandes** : `php artisan` (`route:list`, `migrate`, `test`, `queue:work`), `composer`, `./vendor/bin/pint` (formatage), `./vendor/bin/phpstan` s'il est présent. Lire les scripts de `composer.json` avant de supposer.
- **Configuration** : `.env` jamais commité ; lire la configuration par `config('…')`, jamais `env()` en dehors des fichiers de `config/` (cassé après `config:cache`).
- **Eloquent** : `$fillable` ou `$guarded` explicites, relations déclarées, casts pour les types.

---

## dev

- **Contrôleurs fins** : la logique métier va dans des actions ou services, la validation dans des Form Requests, l'autorisation dans des Policies.
- **Validation** : Form Request (`rules()`, `authorize()`) plutôt que `$request->all()` ; n'exploiter que `validated()`.
- **Requêtes** : charger les relations avec `with()` (éviter le N+1), `chunkById` / `lazy` pour les gros volumes, transactions (`DB::transaction`) pour les écritures liées.
- **Files et tâches** : le travail lent va dans un `Job` en file (`ShouldQueue`), idempotent, avec `tries` et `backoff`.
- **Migrations** : réversibles (`down`), jamais modifiées une fois appliquées ailleurs (voir `/max:migrate-db`).
- **Ressources d'API** : `JsonResource` pour la forme des réponses ; ne pas renvoyer un modèle Eloquent brut.
- **Qualité** : `pint`, analyse statique et `php artisan test` doivent passer.

---

## review

- **Mass assignment** : `$guarded = []`, `Model::unguard()`, `create($request->all())`.
- **N+1** : relation lue dans une boucle sans `with()`, `count()` répétés.
- **Validation et autorisation** : route sans Policy ni middleware `can`, validation dans le contrôleur au lieu d'un Form Request.
- **`env()` hors config**, `dd()` / `dump()` / `Log::debug` oubliés, `DB::raw` avec entrée utilisateur.
- **Migrations** : irréversible, `dropColumn` sans plan de retour, verrou long sur une grosse table.
- **Files** : job non idempotent, pas de `tries`, effet de bord avant la transaction validée (`afterCommit`).

---

## security

- **Mises à jour** : `composer audit` ; avis du framework sur le site officiel et dans les alertes Dependabot.
- **Configuration** : `APP_DEBUG=false` et `APP_KEY` définie en production ; `.env` hors du dépôt et hors de la racine web (seul `public/` est exposé).
- **Entrées** : protection CSRF active (`@csrf`), échappement Blade `{{ }}` (vigilance sur `{!! !!}`), requêtes paramétrées (pas de concaténation dans `DB::raw` / `whereRaw`).
- **Accès** : Policies ou Gates sur chaque ressource, limitation de débit (`throttle`) sur la connexion et les API, Sanctum ou Passport correctement configurés.
- **Fichiers** : validation du type et de la taille des téléversements, disque privé par défaut.

---

## test

- **Outils** : Pest ou PHPUnit (`php artisan test`) ; `RefreshDatabase` / `DatabaseTransactions` ; factories et seeders pour les données.
- **Niveaux** : Feature (HTTP, base) pour le comportement, Unit pour la logique pure. Simuler le temps (`Carbon::setTestNow`), les files (`Queue::fake`), les mails (`Mail::fake`), le HTTP externe (`Http::fake`).
- **Règles** : un test vérifie un comportement, pas l'implémentation ; tester l'autorisation autant que le cas nominal.

---

## deploy

- **Build** : `composer install --no-dev --optimize-autoloader`, puis `php artisan config:cache route:cache view:cache` ; assets via Vite (`npm run build`).
- **Exécution** : PHP-FPM derrière un serveur web pointant sur `public/` ; `php artisan migrate --force` à part, jamais au démarrage de chaque instance sans verrou ; `queue:work` en processus supervisé ; planificateur (`schedule:run`) chaque minute.
- **Image** : multi-étapes, utilisateur non root, `storage/` et `bootstrap/cache` accessibles en écriture, `.env` injecté par l'environnement.
