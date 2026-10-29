# Stack : Django - spécificités

Point d'entrée des spécificités Django (Forme 1 : fichier unique sectionné). L'appelant lit `## core` plus la section correspondant à sa nature. Promouvoir une section en fichier voisin (Forme 2) si elle grossit.

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

- **Détection** : `manage.py`, dépendance `django` (`requirements*.txt`, `pyproject.toml`). Version : `python -m django --version` ; lire les notes de version de la cible avant d'affirmer qu'une API existe, et vérifier l'état de support de la version.
- **Structure** : un projet (`settings`, `urls`, `wsgi/asgi`) et des applications (`models`, `views`, `urls`, `forms`, `admin`, `migrations`). Une application = un domaine.
- **Commandes** : `python manage.py` (`runserver`, `makemigrations`, `migrate`, `test`, `check --deploy`), dans l'environnement virtuel du projet.
- **Configuration** : secrets et paramètres d'environnement lus depuis l'environnement, jamais en dur dans `settings.py`.
- **ORM** : requêtes paresseuses ; `select_related` (clés étrangères) et `prefetch_related` (relations multiples) contre le N+1.

---

## dev

- **Vues** : fines ; logique métier dans des services ou des méthodes de modèle/manager. Vues basées sur des classes ou fonctions, selon l'existant.
- **Formulaires / sérialiseurs** : validation via `ModelForm` ou Django REST Framework ; ne jamais lire `request.POST` brut sans validation.
- **Modèles** : `on_delete` explicite, `related_name`, index sur les champs filtrés, contraintes (`UniqueConstraint`, `CheckConstraint`).
- **Migrations** : générées puis relues, réversibles, jamais modifiées une fois appliquées ailleurs (voir `/max:migrate-db`) ; pas de `RunPython` sans `reverse_code`.
- **Transactions** : `transaction.atomic` pour les écritures liées, `transaction.on_commit` pour les effets de bord.
- **Tâches lentes** : Celery / file de tâches plutôt que dans la requête.
- **Qualité** : `ruff`/`flake8`, `black`, `mypy` si présents ; `manage.py check` et les tests doivent passer.

---

## review

- **N+1** - accès à une relation dans une boucle ou un gabarit sans `select_related`/`prefetch_related`.
- **Requêtes brutes** - `raw()`, `extra()`, `cursor.execute` avec formatage de chaîne.
- **Autorisation** - vue sans `login_required`/permission, filtrage par propriétaire oublié (accès à l'objet d'un autre).
- **Migrations** - non réversible, `RunPython` sans retour, verrou long, données modifiées dans la même migration que le schéma.
- **Modèles** - `null=True` sur un champ texte, `on_delete=CASCADE` non voulu, champ sensible exposé par un sérialiseur (`fields = '__all__'`).
- **Résidus** - `print`, `pdb`, `DEBUG=True` committé.

---

## security

- **Mises à jour** : `pip-audit` / `safety` ; avis de sécurité officiels de Django (versions de correctif) et alertes Dependabot.
- **Configuration** : `python manage.py check --deploy` ; `DEBUG=False`, `SECRET_KEY` hors du dépôt, `ALLOWED_HOSTS` restreint, `SECURE_SSL_REDIRECT`, cookies `Secure`/`HttpOnly`, HSTS.
- **Entrées** : CSRF actif (`{% csrf_token %}`, attention à `@csrf_exempt`), échappement automatique des gabarits (attention à `|safe` et `mark_safe`), requêtes paramétrées.
- **Fichiers** : validation des uploads, `MEDIA_ROOT` hors du code, pas de service direct de fichiers privés.
- **Accès** : permissions par objet, limitation de débit sur la connexion et l'API, `SESSION_COOKIE_SAMESITE`.

---

## test

- **Outils** : `manage.py test` (unittest) ou pytest + `pytest-django` ; `TestCase` (transaction annulée), `Client` / `APIClient`, factories (`factory_boy`).
- **Règles** : tester le comportement (réponse, base, effets) plutôt que l'implémentation ; couvrir les permissions et les cas d'erreur ; `freezegun`/`mock` pour le temps et le réseau.

---

## deploy

- **Serveur** : Gunicorn (WSGI) ou Uvicorn (ASGI) derrière un proxy ; `collectstatic` puis fichiers statiques servis par le proxy ou WhiteNoise.
- **Étapes** : `migrate` lancé à part (une fois par déploiement, avec verrou), pas au démarrage de chaque instance.
- **Image** : multi-étapes, environnement virtuel verrouillé (`pip install --require-hashes` ou lockfile), utilisateur non root, `DJANGO_SETTINGS_MODULE` et secrets injectés par l'environnement.
