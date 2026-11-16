# Django

```bash
python -m django --version 2>/dev/null
ls manage.py pyproject.toml requirements*.txt 2>/dev/null
```

Lire `## core`, puis la section de la nature (tableau : `stacks/DETECT.md`).

---

## core

- Signaux : `manage.py`, dépendance `django`.
- Lire les notes de version de la cible avant d'affirmer qu'une API existe ; vérifier que la version est encore supportée.
- Commandes : `python manage.py` (`makemigrations`, `migrate`, `test`, `check --deploy`), dans l'environnement virtuel du projet.
- Secrets et paramètres lus dans l'environnement, jamais en dur dans `settings.py`.
- Requêtes paresseuses : `select_related` pour les clés étrangères, `prefetch_related` pour les relations multiples.

---

## dev

- Vues fines ; logique métier dans des services, des modèles ou des managers.
- Validation par `ModelForm` ou un sérialiseur DRF. Jamais `request.POST` brut.
- Modèles : `on_delete` explicite, `related_name`, index sur les champs filtrés, `UniqueConstraint`, `CheckConstraint`.
- `transaction.atomic` pour les écritures liées, `transaction.on_commit` pour les effets de bord.
- Tâches lentes dans Celery ou une file, pas dans la requête.

Migrations : générées puis relues, `RunPython` toujours avec `reverse_code`, jamais modifiées une fois appliquées ailleurs (`/max:migrate-db`). Vérifier : `ruff` ou `flake8`, `mypy` s'il est présent, `manage.py check`, tests.

---

## review

- N+1 : relation lue dans une boucle ou un gabarit.
- `raw()`, `extra()`, `cursor.execute` avec formatage de chaîne.
- Vue sans `login_required` ni permission ; filtrage par propriétaire oublié.
- Migration irréversible, verrou long, données et schéma dans la même migration.
- Sérialiseur en `fields = '__all__'` qui expose un champ sensible.

Aussi : `null=True` sur un champ texte, `CASCADE` non voulu, `print`, `pdb`, `DEBUG=True` commité.

---

## security

- `pip-audit` ou `safety` ; avis officiels de Django.
- `python manage.py check --deploy`.
- `DEBUG=False`, `SECRET_KEY` hors du dépôt, `ALLOWED_HOSTS` restreint, `SECURE_SSL_REDIRECT`, HSTS.
- `@csrf_exempt`, `|safe` et `mark_safe` : chaque occurrence se justifie.
- Permissions par objet ; limitation de débit sur la connexion et l'API ; téléversements validés, `MEDIA_ROOT` hors du code.

---

## test

- `manage.py test` ou pytest avec `pytest-django` ; `TestCase`, `Client`, `APIClient`, `factory_boy`.
- Tester la réponse, la base et les effets, pas l'implémentation.
- Couvrir les permissions et les erreurs ; `freezegun` ou `mock` pour le temps et le réseau.

---

## deploy

- Gunicorn (WSGI) ou Uvicorn (ASGI) derrière un proxy ; `collectstatic`, puis statiques servis par le proxy ou WhiteNoise.
- `migrate` à part, une fois par déploiement, jamais au démarrage de chaque instance.
- Dépendances verrouillées (`pip install --require-hashes` ou lockfile) ; `DJANGO_SETTINGS_MODULE` et secrets injectés par l'environnement.
