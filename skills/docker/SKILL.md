---
name: docker
description: Guide le travail sur Docker - Dockerfile, Docker Compose, Makefile et CI GitHub Actions - avec un accent sur les builds reproductibles, les images minimales, la sécurité et le confort de développement. À utiliser quand l'utilisateur écrit ou relit un Dockerfile, un compose.yaml, un Makefile ou un workflow de build d'image, ou demande de l'aide sur Docker, la conteneurisation ou l'environnement de développement local, ou invoque /max:docker.
---

# Docker

Écrire et relire Dockerfile, fichiers Compose, Makefile et CI GitHub Actions qui construit les images. Quatre objectifs, dans cet ordre : un build **reproductible**, une image **minimale**, une configuration **sûre**, un usage **confortable** au quotidien.

Pour un audit de sécurité complet de la configuration Docker (privilèges, socket, secrets, scan d'image), passer par `/max:security` : ce skill pose les bonnes pratiques à l'écriture, l'audit les contrôle après coup.

## Lire l'existant d'abord

Avant d'écrire quoi que ce soit, regarder ce qui existe et en suivre les conventions :

```bash
ls Dockerfile* compose*.y*ml docker-compose*.y*ml .dockerignore Makefile 2>/dev/null
ls .github/workflows/*.y*ml 2>/dev/null
```

- Le **runner** du projet est, par ordre de priorité, `make` puis `docker compose`. S'y brancher plutôt que d'ajouter une autre façon de lancer les mêmes choses.
- Repérer les images de base, versions de langage et de dépendances déjà choisies, et la distinction éventuelle entre dev et production.
- Dire en une phrase ce qui existe et ce qui va changer avant de le faire.
- **Spécificités de la stack** : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`) ; pour chaque framework doté d'une ressource, lire `stacks/<stack>/INDEX.md` pour la nature **deploy** (elle inclut `core` + `deploy`) et l'appliquer en plus des règles générales ci-dessous. Sans ressource ou sans section `deploy`, rester générique et le dire ; ne jamais `Read` une ressource inexistante.

## Dockerfile

**Reproductible**
- Épingler l'image de base : tag précis (`php:8.4-fpm-alpine`, jamais `latest`), idéalement avec son digest (`@sha256:…`) pour la production.
- Épingler les versions installées quand le gestionnaire le permet ; installer depuis un lockfile (`composer install`, `npm ci`, `pip install -r` à versions fixées) plutôt que depuis un manifeste libre.
- Ordonner les couches de la moins à la plus changeante pour profiter du cache : fichiers de dépendances d'abord, installation, puis code source.

**Minimale**
- **Multi-stage** : une étape de build (compilateurs, outils de dev) et une étape finale qui ne reprend que le résultat (`COPY --from=build`).
- Image de base légère adaptée à la techno (`-slim`, `-alpine`, `distroless`), après avoir vérifié la compatibilité (musl contre glibc) avant de choisir Alpine.
- `apt-get install --no-install-recommends` puis `rm -rf /var/lib/apt/lists/*` dans la **même** instruction `RUN`.
- Un `.dockerignore` strict : `.git`, `node_modules`, `vendor` si reconstruit, `.env*`, fichiers de test, documentation.
- Dépendances de production uniquement dans l'image finale (`composer install --no-dev --optimize-autoloader`, `npm ci --omit=dev`).

**Sûre**
- Utilisateur non root : créer l'utilisateur et passer à `USER` avant `CMD`, avec `COPY --chown=` pour les fichiers de l'application.
- Aucun secret dans `ENV`, `ARG` ni dans une couche. Pour un secret nécessaire au build : `RUN --mount=type=secret,id=<nom> …` (BuildKit), jamais `COPY .env`.
- Pas d'outils inutiles à l'exécution (`curl`, `git`, shell de debug) dans l'image finale.
- Pas de `curl … | sh` sans vérification d'empreinte.

**Exploitable**
- `CMD` et `ENTRYPOINT` en forme **exec** (`["php-fpm"]`), pour que les signaux atteignent le processus.
- Un seul processus principal par conteneur.
- Un `HEALTHCHECK` quand le service offre un moyen simple de vérifier qu'il répond.
- `WORKDIR` explicite, `EXPOSE` pour documenter les ports.
- Commentaires courts sur le *pourquoi* des choix peu évidents (version épinglée, contournement).

## Docker Compose

- Fichier `compose.yaml` (le champ `version:` est obsolète : l'omettre). Un fichier de base commun plus un `compose.override.yaml` pour le développement local, ou des fichiers dédiés (`compose.prod.yaml`), plutôt qu'un seul fichier bourré de cas.
- **Santé et ordre de démarrage** : `healthcheck` sur les services dont d'autres dépendent (base de données, cache) et `depends_on` avec `condition: service_healthy`, pas un simple `depends_on` qui n'attend rien.
- **Ports** : en développement, publier sur `127.0.0.1` (`"127.0.0.1:8080:80"`) plutôt que sur toutes les interfaces ; ne publier ni la base de données ni l'administration sans nécessité.
- **Volumes** : volumes nommés pour les données qui doivent survivre ; bind mounts seulement pour le code en développement, jamais de montage large (`/`, `$HOME`) ni du socket Docker sans raison.
- **Configuration** : `env_file` et variables, sans secret en dur dans le fichier ; valeurs par défaut sûres (`${VAR:-valeur}`) ; un `.env.example` versionné, jamais le vrai `.env`.
- **Réseaux** : un réseau dédié par application ; ne pas s'appuyer sur `container_name` (il empêche la mise à l'échelle), utiliser le nom du service.
- **Limites et redémarrage** : `restart: unless-stopped` en production ; limites de ressources quand le déploiement le permet ; `profiles` pour les services optionnels (outils de debug, mail local).
- **Valider** : `docker compose config` doit passer et afficher la configuration finale fusionnée.

## Makefile

Un Makefile léger qui offre un point d'entrée mémorisable au-dessus de Compose. Il relie le développeur aux commandes sans réinventer la logique.

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

build: ## Reconstruit les images
	$(COMPOSE) build

logs: ## Suit les logs
	$(COMPOSE) logs -f

sh: ## Ouvre un shell dans le service applicatif
	$(COMPOSE) exec app sh

test: ## Lance les tests
	$(COMPOSE) exec app <commande de test du projet>

lint: ## Lance les linters
	$(COMPOSE) exec app <commande de lint du projet>
```

- Déclarer les cibles en `.PHONY`, fournir une cible `help` auto-documentée, laisser `COMPOSE` surchargeable.
- Les cibles `test` et `lint` appellent les commandes **déjà utilisées** par le projet ; ne pas en inventer.
- Aucune cible destructrice (`down -v`, `system prune`) sans nom explicite et sans avertissement.

## CI GitHub Actions

Construire l'image à chaque PR (sans la publier) et ne la publier sur le registre (GHCR) que depuis `main` ou un tag. Exemple de base à adapter :

```yaml
name: docker

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write          # nécessaire seulement pour publier sur GHCR
    steps:
      - uses: actions/checkout@<sha de la release>
      - uses: docker/setup-buildx-action@<sha de la release>
      - uses: docker/login-action@<sha de la release>
        if: github.event_name != 'pull_request'
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - id: meta
        uses: docker/metadata-action@<sha de la release>
        with:
          images: ghcr.io/${{ github.repository }}
      - uses: docker/build-push-action@<sha de la release>
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

- **Épingler chaque action sur un SHA de commit complet** (version en commentaire). Les `<sha de la release>` ci-dessus sont des emplacements à remplir avec le SHA réel de la dernière release de chaque action : ne jamais en inventer un.
- **Permissions minimales** : `contents: read` par défaut, `packages: write` seulement pour le job qui publie.
- Aucune injection : ne pas interpoler `${{ github.event.* }}` directement dans un `run:`.
- Scanner l'image (Trivy ou Docker Scout) en étape de CI si le projet le souhaite, sans bloquer par défaut sur des alertes dépourvues de correctif.
- Pour les secrets de build, utiliser `secrets:` de `build-push-action`, pas `build-args`.

## Vérifier

Exécuter ce qui peut l'être et rapporter ce qui a réellement tourné ; ne jamais affirmer qu'un contrôle est passé sans l'avoir lancé. Un outil absent se note « (indispo) » : rien n'est installé pour l'occasion.

```bash
docker compose config                 # le fichier Compose est valide, configuration fusionnée
docker build --check .                # règles de lint intégrées de BuildKit, si disponibles
hadolint Dockerfile                   # lint du Dockerfile, si hadolint est installé
docker build -t <nom>:test .          # le build passe, de bout en bout
docker images <nom>:test              # taille de l'image finale
docker history <nom>:test             # taille de chaque couche
```

Comparer la taille avant et après quand le changement visait à alléger l'image, et la donner en chiffres réels.

## Forme de la réponse

- Ce qui a été modifié ou créé, fichier par fichier, avec le *pourquoi* des choix peu évidents.
- Les commandes pour essayer (`make up`, `docker compose up -d`), et ce qui a été vérifié ou non.
- Les compromis assumés (par exemple Alpine contre compatibilité glibc) et les points laissés ouverts.

## Limites

- Aucune commande destructrice sans accord explicite : `docker system prune`, `docker volume rm`, `docker compose down -v`, suppression d'images ou de conteneurs qui ne sont pas les nôtres.
- Jamais de publication d'image (`docker push`) ni de déploiement sans demande explicite.
- Jamais de secret dans un fichier versionné, une image ou un journal.
- Ne pas refondre toute l'infrastructure d'un projet pour une demande ciblée : proposer, cadrer, laisser l'utilisateur décider.
- L'audit de sécurité approfondi relève de `/max:security`, la revue du diff de `/max:review`.
