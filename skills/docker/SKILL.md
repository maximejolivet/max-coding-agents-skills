---
name: docker
description: "Écrit et relit Dockerfile, fichiers Compose et Makefile pour des builds reproductibles, des images minimales, une configuration sûre et un environnement local confortable. À utiliser quand Maxime écrit ou relit un Dockerfile, un compose.yaml ou un Makefile, veut conteneuriser un projet ou monter son environnement de développement, ou invoque /max:docker."
---

# Docker

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. Lancer :

   ```bash
   ls Dockerfile* compose*.y*ml docker-compose*.y*ml .dockerignore Makefile 2>/dev/null
   ls .github/workflows/*.y*ml 2>/dev/null
   ```

3. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **deploy**.
4. Dire en une phrase ce qui existe et ce qui va changer.

## Étapes

1. Reprendre les choix du projet : runner (`make`, puis `docker compose`), images de base, versions, séparation entre développement et production.
2. Écrire ou corriger le Dockerfile avec les quatre groupes de l'annexe, dans cet ordre de priorité : reproductible, minimal, sûr, exploitable.
3. Écrire ou corriger le fichier Compose (annexe).
4. Ajouter ou compléter le Makefile seulement s'il sert de point d'entrée (annexe).
5. Pour le workflow qui construit l'image : appliquer les règles de `/max:ci`.
6. Vérifier (annexe) et rapporter ce qui a réellement tourné, avec la taille de l'image avant et après quand le but était de l'alléger.
7. Rendre compte : chaque fichier touché, la raison des choix non évidents, les commandes pour essayer, les compromis.

## Points d'arrêt

- Alpine est envisagé : vérifier la compatibilité musl contre glibc avant de choisir.
- Un secret est nécessaire au build : `RUN --mount=type=secret,id=<nom>`, jamais `COPY .env`, `ENV` ni `ARG`.
- Un SHA d'action ou un digest d'image n'est pas retrouvable : laisser un emplacement, ne pas l'inventer.
- La demande est ciblée mais le projet gagnerait à être refondu : le proposer, ne pas le faire.

## Ce qu'il ne fait pas

- `docker system prune`, `docker volume rm`, `docker compose down -v`, ni supprimer une image ou un conteneur qu'il n'a pas créé.
- `docker push`, ni déclencher un déploiement.
- Écrire un secret dans un fichier versionné, une image ou un journal.
- Auditer la configuration existante : `/max:security`.

## Annexe

### Dockerfile

Reproductible :

- Image de base épinglée sur un tag précis, avec son digest en production. Jamais `latest`.
- Installation depuis le lockfile : `composer install`, `npm ci`, `pip install -r` à versions fixées.
- Couches de la moins à la plus changeante : fichiers de dépendances, installation, puis code.

Minimal :

- Multi-étapes : l'étape finale ne copie que le résultat (`COPY --from=build`).
- Base légère adaptée à la techno : `-slim`, `-alpine`, `distroless`.
- `apt-get install --no-install-recommends` et `rm -rf /var/lib/apt/lists/*` dans le même `RUN`.
- `.dockerignore` strict : `.git`, `node_modules`, `.env*`, tests, documentation.
- Dépendances de production seulement dans l'image finale.

Sûr :

- Utilisateur non root : `USER` avant `CMD`, `COPY --chown=`.
- Aucun outil inutile à l'exécution : `curl`, `git`, shell de debug.
- Pas de `curl … | sh` sans vérification d'empreinte.

Exploitable :

- `CMD` et `ENTRYPOINT` en forme exec, pour que les signaux atteignent le processus.
- Un processus principal par conteneur.
- `HEALTHCHECK` quand le service sait dire qu'il répond.
- `WORKDIR` explicite, `EXPOSE` pour documenter.

### Compose

Fichiers et réseau :

- `compose.yaml` sans champ `version:`, plus `compose.override.yaml` pour le local ou des fichiers dédiés (`compose.prod.yaml`).
- Un réseau par application. Pas de `container_name` : utiliser le nom du service.
- `profiles` pour les services optionnels.

Fiabilité :

- `healthcheck` sur les services dont d'autres dépendent, et `depends_on` avec `condition: service_healthy`.
- `restart: unless-stopped` en production.
- Volumes nommés pour les données à conserver ; bind mount pour le code en développement seulement.

Exposition et configuration :

- Ports publiés sur `127.0.0.1` en développement. Ni base ni administration publiées sans besoin.
- Aucun montage large (`/`, `$HOME`) ni du socket Docker sans raison.
- `env_file` et variables avec défauts sûrs (`${VAR:-valeur}`) ; `.env.example` versionné, jamais le vrai `.env`.

### Makefile

```makefile
COMPOSE ?= docker compose

.DEFAULT_GOAL := help
.PHONY: help up down build logs sh test lint

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

up: ## Démarre l'environnement
	$(COMPOSE) up -d --wait

down: ## Arrête l'environnement
	$(COMPOSE) down

sh: ## Ouvre un shell dans le service applicatif
	$(COMPOSE) exec app sh

test: ## Lance les tests
	$(COMPOSE) exec app <commande de test du projet>
```

Les cibles `test` et `lint` appellent les commandes que le projet utilise déjà. Aucune cible destructrice (`down -v`, `prune`) sans nom explicite.

### Vérifier

```bash
docker compose config            # configuration fusionnée valide
docker build --check .           # lint de BuildKit, si disponible
hadolint Dockerfile              # si installé
docker build -t <nom>:test .
docker images <nom>:test         # taille finale
docker history <nom>:test        # taille par couche
```
