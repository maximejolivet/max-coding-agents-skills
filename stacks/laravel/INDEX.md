# Laravel

```bash
composer show laravel/framework 2>/dev/null | head -5
php artisan --version 2>/dev/null
```

Lire `## core`, puis la section de la nature (tableau : `<max>/stacks/DETECT.md`).

---

## core

- Signaux : `laravel/framework` dans `composer.json`, fichier `artisan`.
- Lire le guide de mise à niveau de la version visée avant d'affirmer qu'une API existe.
- Commandes : `php artisan`, `./vendor/bin/pint`, `./vendor/bin/phpstan` s'il est présent, scripts de `composer.json`.
- Configuration lue par `config('…')`. `env()` hors de `config/` casse après `config:cache`.
- Ne pas modifier `vendor/` ni `bootstrap/cache`. `.env` jamais commité.

---

## dev

- Validation dans un Form Request (`rules()`, `authorize()`) ; n'utiliser que `validated()`.
- Autorisation par Policies ; logique métier dans des actions ou services.
- `with()` contre le N+1 ; `chunkById` ou `lazy` pour les gros volumes ; `DB::transaction` pour les écritures liées.
- Travail lent dans un `Job` `ShouldQueue`, idempotent, avec `tries` et `backoff`.
- Réponses d'API par `JsonResource`, jamais un modèle brut.

Migrations : avec `down`, jamais modifiées une fois appliquées ailleurs (`/max:migrate-db`). Vérifier : `pint`, analyse statique, `php artisan test`.

---

## review

- Affectation de masse : `$guarded = []`, `Model::unguard()`, `create($request->all())`.
- N+1 : relation lue dans une boucle sans `with()`, `count()` répétés.
- Route sans Policy ni middleware `can` ; validation dans le contrôleur.
- `env()` hors configuration, `DB::raw` avec une entrée d'utilisateur, `dd()`, `dump()`.
- Job non idempotent, sans `tries`, ou effet de bord avant la validation de la transaction (`afterCommit`).

Migrations : irréversible, `dropColumn` sans plan de retour, verrou long sur une grosse table.

---

## security

- `composer audit` ; avis du framework sur le site officiel.
- Production : `APP_DEBUG=false`, `APP_KEY` définie, seul `public/` exposé.
- CSRF actif (`@csrf`) ; `{!! !!}` surveillé ; pas de concaténation dans `DB::raw` ni `whereRaw`.
- Policies ou Gates sur chaque ressource ; `throttle` sur la connexion et les API.
- Téléversements : type et taille validés, disque privé par défaut.

---

## test

- Pest ou PHPUnit par `php artisan test` ; `RefreshDatabase` ou `DatabaseTransactions` ; factories.
- Feature pour le comportement HTTP et base, Unit pour la logique pure.
- Frontières simulées : `Carbon::setTestNow`, `Queue::fake`, `Mail::fake`, `Http::fake`.
- Tester l'autorisation autant que le cas nominal.

---

## deploy

- Build : `composer install --no-dev --optimize-autoloader`, puis `php artisan config:cache route:cache view:cache` ; assets par `npm run build`.
- `php artisan migrate --force` à part, une fois par déploiement, jamais au démarrage de chaque instance.
- `queue:work` en processus supervisé ; `schedule:run` chaque minute.
- `storage/` et `bootstrap/cache` inscriptibles ; `.env` injecté par l'environnement.
