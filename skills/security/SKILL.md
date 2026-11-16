---
name: security
description: Audite la sécurité des dépendances et de l'infrastructure d'un projet - lance composer/npm audit, vérifie les avis de sécurité du CMS ou du framework, passe en revue la configuration Docker et les workflows GitHub Actions, classe chaque constat selon sa criticité réellement exploitable, puis applique les correctifs sûrs ou donne la marche à suivre détaillée. Indépendant de la stack - les contrôles d'avis propres à une techno (ex. le flux d'avis d'un framework) viennent de la ressource stacks/ chargée. À utiliser quand l'utilisateur demande un audit de sécurité, une vérification de CVE ou de vulnérabilités, un passage sur la sécurité des dépendances, ou invoque /max:security.
---

# Audit de sécurité

Conduire un audit des dépendances et de l'infrastructure, puis rendre un rapport priorisé et exploitable. Ce qui compte, c'est l'exploitabilité réelle, pas le nombre brut d'avis. Rester direct : ce qui est vulnérable, la gravité _dans ce projet_, et le correctif exact.

L'audit est **défensif** : on trouve et on corrige les faiblesses, on ne les exploite pas.

## Délimiter le périmètre

Détecter la stack avant de lancer quoi que ce soit : ne pas auditer un outil que le projet n'emploie pas. Depuis la racine du projet :

```bash
ls composer.json composer.lock package.json package-lock.json pnpm-lock.yaml yarn.lock 2>/dev/null
ls Dockerfile docker-compose.yml docker-compose.yaml compose.yaml 2>/dev/null
ls .github/workflows/*.yml .github/workflows/*.yaml .github/dependabot.yml 2>/dev/null
```

Puis identifier :

1. **PHP** : présence de `composer.json` / `composer.lock`.
2. **Stack / CMS** : appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), puis lire `stacks/<stack>/INDEX.md` pour la nature **security**. Elle apporte les spécificités d'avis de la stack (outil de contrôle de sécurité ou flux d'avis du framework, vérification de fin de vie de la version) en plus de l'audit générique ci-dessous. Aucune ressource (`aucune`), ou un `INDEX.md` sans section `security` : rester générique avec les valeurs par défaut de `DETECT.md` et **le dire** (seule la couverture générique `composer audit` / `npm audit` / équivalent s'applique). Ne jamais `Read` une ressource inexistante.
3. **JS** : le lockfile présent désigne l'outil (`package-lock.json` → npm, `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn). Pas de `npm audit` sur un projet pnpm.
4. **Docker** : tout Dockerfile ou fichier compose.
5. **GitHub Actions** : tout workflow sous `.github/workflows/`.

Trouver le runner du projet (priorité `make` puis `docker compose`). Lancer les audits composer et du gestionnaire de paquets **dans** le runner s'il existe (la version de PHP de l'hôte correspond rarement), tout en sachant qu'un `*audit` sur le lockfile versionné reste acceptable depuis l'hôte.

Annoncer d'emblée quels écosystèmes ont été trouvés et seront audités, et écarter explicitement les autres.

## Choisir le mode

Compter les écosystèmes trouvés dans « Délimiter le périmètre » (dépendances, Docker, GitHub Actions) :

- **Un seul écosystème** : l'auditer soi-même en **une passe** avec les sections ci-dessous.
- **Deux ou plus** : **déléguer** aux agents auditeurs, un par écosystème présent. Indiquer le mode retenu en une ligne.

L'utilisateur peut imposer un mode (« audit rapide », « audit complet ») ; cela prime sur le décompte.

## Déléguer aux agents auditeurs

Ne lancer **que les agents dont l'écosystème existe**, tous dans le même tour pour qu'ils tournent en parallèle, chacun via l'outil Agent :

| Agent (`subagent_type`) | À lancer quand | Couvre |
| --- | --- | --- |
| `max:dependencies-auditor` | un lockfile Composer ou JS existe | Versions du lockfile, `composer audit` / `npm audit`, avis de la stack, alertes Dependabot |
| `max:docker-auditor` | un Dockerfile ou un fichier compose existe | Image de base, privilèges, socket, secrets, ports, scan d'image |
| `max:actions-auditor` | `.github/workflows/` existe | Épinglage, permissions du token, déclencheurs, injection, secrets, runners |

Donner à chaque agent le même brief, car aucun ne voit cette conversation :

1. La racine absolue du projet et les fichiers que chacun doit examiner (lockfiles, chemins des Dockerfile et compose, chemins des workflows).
2. Le runner du projet (`make` / `docker compose`) quand il est connu, et `owner/repo` si le projet est sur GitHub.
3. Le chemin absolu de la ressource `stacks/<stack>/INDEX.md` chargée (ou « pas de ressource de stack ») : l'auditeur de dépendances lit sa section `security`.
4. Qu'il est en **lecture seule** : aucune modification, aucun `update` / `audit fix`, aucun build, aucun commit.

Ensuite, **fusionner** soi-même leurs réponses : les agents rapportent, c'est toi qui tranches.

- Dédoublonner et classer l'ensemble avec **Prioriser par criticité** ci-dessous. La gravité donnée par un agent est une proposition : la rejuger dans le contexte de tout le projet (un constat dans un domaine peut en aggraver un autre, par exemple une action non épinglée disposant d'un accès en écriture à un dépôt qui publie des images).
- Revérifier dans les fichiers chaque constat Critique et Élevé avant de le conserver. Écarter ce qui ne se reproduit pas à la lecture du code.
- Bâtir le tableau de synthèse d'après leurs lignes `Audité` : un écosystème n'est marqué audité que si un agent a réellement exécuté son outil. Reporter les lignes `Non vérifié` dans la section finale, avec l'échelon atteint (runner → hôte → WebFetch).
- Si un agent échoue ou ne renvoie rien, le dire et auditer soi-même cet écosystème en une passe, au lieu de le déclarer sain.
- **La remédiation reste de ton côté** : les agents ne corrigent jamais rien. Appliquer les règles de **Remédier** ci-dessous, et ne modifier de fichiers que si l'utilisateur le demande.

## Lancer les audits

Ces sections décrivent une **passe unique**, et la référence que suivent les trois agents.

Préférer les signaux réels aux suppositions. Lancer ce qui s'applique, capturer la sortie, ne jamais inventer d'identifiant d'avis.

**Deux démarches sont obligatoires et complémentaires : faire LES DEUX, jamais l'une sans l'autre.**

1. **Lire les fichiers de paquets et de verrouillage** (`composer.lock`, `package-lock.json` / `pnpm-lock.yaml` / `yarn.lock`) pour extraire les _versions exactes installées_. Le lockfile dit la vérité sur « ce qui est réellement installé ». Mais **un lockfile ne contient AUCUNE donnée de CVE ni d'avis** : seulement des versions et un drapeau `abandoned` facultatif. Le lire est nécessaire, jamais suffisant.
2. **Lancer le véritable audit** (`composer audit`, `npm audit`, plus tout outil de stack comme `symfony security:check`), qui interroge la **base d'avis par le réseau** et relie versions installées et identifiants CVE / GHSA / SA. C'est de là que vient le vrai signal de vulnérabilité.

Se contenter du lockfile donne des constats d'hygiène (paquets abandonnés, préversions) mais RATE toute vraie CVE. Toujours associer les deux : extraire les versions du lock, puis les confronter aux avis.

### Où lancer : runner, puis hôte, puis repli hors ligne

Essayer dans cet ordre ; ne pas s'arrêter au premier échec, passer à l'échelon suivant :

1. **Dans le runner** (`<runner> composer audit`, `<runner> npm audit`, et tout outil de stack tel que `<runner> symfony security:check`) : environnement initialisé, avec accès réseau. Meilleur signal. Le démarrer s'il est arrêté.
2. **Sur l'hôte** : si le runner est à l'arrêt (Docker éteint, démarrage en échec), lancer `composer audit --locked` / `npm audit` directement sur l'hôte. La version de PHP de l'hôte peut différer, mais `--locked` audite le lockfile versionné, donc le résultat reste valable.
3. **Repli hors ligne via `WebFetch`** : si l'environnement n'a **aucun réseau depuis le shell** (`composer audit` / `npm audit` en bac à sable échouent sur des erreurs curl), NE PAS renoncer et NE PAS affirmer « 0 vulnérabilité ». Extraire les versions installées du lockfile (voir plus bas), puis récupérer les flux d'avis avec `WebFetch` (autre chemin réseau, qui fonctionne souvent quand le shell est isolé) et recouper à la main. La ressource de stack chargée donne les flux propres à la stack ; la GitHub Advisory Database (`https://github.com/advisories`) couvre la plupart des écosystèmes.

Le but est d'obtenir de la **vraie matière**, d'une façon ou d'une autre. Un rapport « rien n'a pu tourner » est un dernier recours, pas une première réponse : épuiser runner → hôte → WebFetch avant de conclure.

### PHP / Composer

D'abord, extraire du lockfile les versions exactes installées (fonctionne sans réseau, sur l'hôte comme dans le runner) :

```bash
# Tous les paquets + versions + drapeaux abandonné / préliminaire
php -r '$l=json_decode(file_get_contents("composer.lock"),true);
foreach(($l["packages"]??[]) as $p){
  $ab=!empty($p["abandoned"])?" [ABANDONED]":"";
  $pre=preg_match("#(alpha|beta|-rc|dev-)#i",$p["version"])?" [pre-release]":"";
  echo str_pad($p["name"],45)." ".$p["version"].$ab.$pre."\n";
}'
```

La ressource de stack chargée peut ajouter une extraction propre à la stack (par exemple filtrer le cœur du framework et ses bundles). Puis lancer le vrai audit :

```bash
composer audit --locked --format=plain     # audite composer.lock face à la base d'avis PHP
composer audit --locked --format=json      # exploitable par machine : gravité, CVE, versions affectées
```

`--locked` audite ce qui est réellement versionné (`composer.lock`), pas seulement l'arbre résolu. Chaque avis porte un identifiant CVE / GHSA, une plage de versions affectées et un lien : les conserver pour le rapport.

### Avis du CMS / framework (propres à la stack)

Certains écosystèmes ne publient pas tous leurs avis sur packagist ou npm et disposent de leurs propres outils et flux : **appliquer ici la ressource de stack chargée**. Sa section `security` liste les outils propres à la stack, la vérification de fin de vie de la version et les flux pour le recoupement hors ligne. Un audit limité à packagist peut donner un faux « tout va bien » pour ces écosystèmes. Si aucune ressource de stack n'a été chargée, noter que seule la couverture générique `composer audit` / `npm audit` s'applique.

Sur un dépôt GitHub, lire aussi les **alertes Dependabot** quand le token le permet : elles couvrent les lockfiles avec la base d'avis propre à GitHub :

```bash
gh api "repos/<owner>/<repo>/dependabot/alerts?state=open" --jq '.[] | {pkg: .dependency.package.name, sev: .security_advisory.severity, id: .security_advisory.ghsa_id, fixed: .security_vulnerability.first_patched_version.identifier}'
```

Si l'appel est refusé (403 / 404 : alertes désactivées ou droits insuffisants), le dire, et le noter comme constat Info si `.github/dependabot.yml` est absent.

### JavaScript

Utiliser l'outil qui correspond au lockfile :

```bash
npm audit --omit=dev                        # ou : npm audit --json
pnpm audit --prod                           # ou : pnpm audit --json
yarn npm audit --environment production     # yarn berry
```

Séparer les dépendances de **production** de celles de **développement** : une CVE de gravité élevée dans une devDependency utilisée seulement au build pèse bien moins que la même dans du code livré à l'exécution. Noter de quel côté se situe chaque constat. Pour une chaîne d'assets ou de thème compilés (gulp / webpack / postcss / sass transformés en CSS/JS statiques), _tout_ l'arbre npm relève en pratique du build : classer ces constats en risque réel Faible et expliquer pourquoi, mais lancer quand même l'audit.

Si `npm audit` n'atteint pas le réseau, lire `package.json` + `package-lock.json` pour les versions installées et recouper les paquets notables avec la **GitHub Advisory Database** (`WebFetch https://github.com/advisories?query=<paquet>`) plutôt que d'ignorer le JS.

### Configuration Docker

Si un Dockerfile ou un fichier compose existe, auditer la _configuration_. Vérifier :

- **Image de base** : tags flottants (`:latest`, non épinglé), ou base elle-même en fin de vie ou vulnérable.
- **Privilèges** : conteneur exécuté en `root` (pas de `USER`), `privileged: true`, capabilities ajoutées, `--privileged`.
- **Socket Docker** : `/var/run/docker.sock` monté dans un conteneur (surface d'évasion).
- **Secrets** : identifiants dans `ENV` / `ARG`, en dur dans le compose ou copiés dans les couches de l'image ; `.env` versionné.
- **Surface exposée** : ports liés à `0.0.0.0` qui devraient rester internes ; ports d'admin ou de base de données publiés sans nécessité.
- **Système de fichiers** : pas de `read_only`, montages inscriptibles inutiles, chemins de l'hôte montés trop largement.
- **Scan d'image** (si un scanner est disponible) : `docker scout cves <image>` ou `trivy image <image>` / `trivy config .`, avec les CVE de l'OS et des bibliothèques de l'image construite. Sans scanner installé, le dire ; ne pas fabriquer de résultats.

### Workflows GitHub Actions

Si `.github/workflows/` existe, auditer les workflows eux-mêmes : la CI fait partie de la chaîne d'approvisionnement. Vérifier :

- **Actions non épinglées** : `uses: owner/action@v4` ou `@main` au lieu d'un SHA de commit complet (surtout pour les actions tierces ; `actions/*` est moins risqué).
- **Permissions** : pas de bloc `permissions:` à la racine (les défauts peuvent être en lecture-écriture), ou `write-all` ; chaque job devrait demander le minimum (`contents: read`).
- **Déclencheurs dangereux** : `pull_request_target` ou `workflow_run` qui récupère et exécute le code de la tête de PR, exposant les secrets à des forks non fiables.
- **Injection de script** : `${{ github.event.* }}` (titre, branche ou corps d'issue / de PR) interpolé directement dans une étape `run:` ; le faire passer par une variable `env:`.
- **Secrets** : affichés dans les logs, écrits dans des artefacts ou des caches, transmis à des actions non fiables, ou clés cloud durables là où l'OIDC suffirait.
- **Runners self-hosted** sur des dépôts publics, et `GITHUB_TOKEN` ou PAT d'une portée plus large que nécessaire.
- **Dependabot pour les Actions** : `.github/dependabot.yml` sans l'écosystème `github-actions`.

## Prioriser par criticité

Classer chaque constat : le nombre d'avis est du bruit, les constats _exploitables_ sont le signal. Étiqueter chacun d'un niveau, jugé **dans son contexte**, pas d'après le seul CVSS :

- **Critique** : exploitable à distance sur du code livré ou en production, exécution de code à distance, contournement d'authentification, secret exposé, évasion de conteneur. À corriger tout de suite.
- **Élevée** : vulnérabilité sérieuse sur un chemin d'exécution atteignable, ou problème de privilège ou de secret conditionné par une circonstance.
- **Moyenne** : réelle mais contrainte : authentification requise, chemin difficile à atteindre, ou surface de production peu exposée.
- **Faible** : dépendance de développement seulement, théorique, ou exigeant déjà des droits élevés.
- **Info** : hygiène (module non supporté, image de base non épinglée, version mineure en fin de vie) sans CVE nommée pour l'instant.

Ce qui fait monter ou descendre un constat : dépendance de production ou de développement ; atteignable à l'exécution ou seulement au build ; exposée sur Internet ou interne ; existence réelle d'une version corrigée ; usage effectif du chemin de code vulnérable. **Expliquer pourquoi** un constat est placé où il l'est quand cela diffère de la gravité nominale de l'avis.

## Remédier

Pour chaque constat, fournir l'un de ces deux éléments, jamais un vague « mettez à jour vos dépendances » :

**A. Proposer le correctif** (quand il est sûr et mécanique) :

```bash
composer require <vendor>/<paquet>:^X.Y      # monter à la version corrigée (limité au paquet concerné)
npm audit fix                                 # sans rupture, quand cela résout l'avis
```

La ressource de stack chargée donne la remédiation propre à la stack (la commande `composer update <paquets du framework> --with-dependencies` ciblée, les étapes de migration). Proposer de les appliquer à l'arbre de travail si l'utilisateur le souhaite. Après application, **relancer l'audit** pour confirmer que le constat disparaît et que rien d'autre n'a cassé (build / tests si c'est rapide).

**B. Donner la marche à suivre** (quand le correctif est cassant, risqué, ou sans version corrigée pour l'instant) :

- Montée de version majeure avec ruptures de compatibilité : détailler les étapes de migration, quoi tester, ce qui risque de casser.
- Aucune version corrigée : la parade (contournement par configuration, règle WAF, désactivation de la fonctionnalité, épinglage + suivi de l'avis), et quoi surveiller.
- Mise à jour du framework ou du CMS qui demande une étape de migration (migration de schéma, synchro de configuration) : les étapes ordonnées, avec le rappel de sauvegarder la base d'abord.
- Paquet abandonné ou non supporté : le remplacer, le forker et le corriger, ou le supprimer, avec les compromis de chaque option.

Être explicite sur le **risque de rupture** : pas de `composer update` aveugle qui tire tout l'arbre en avant. Limiter chaque montée de version aux paquets concernés et à leurs dépendances nécessaires.

## Format de sortie

Commencer par un titre d'une ligne : décompte par gravité et action la plus urgente. Puis :

**Tableau de synthèse** : une ligne par écosystème audité :

| Écosystème         | Audité | Critique | Élevée | Moyenne | Faible | Info |
| ------------------ | ------ | -------- | ------ | ------- | ------ | ---- |
| Composer (PHP/CMS) | ✅     | …        | …      | …       | …      | …    |
| npm (prod)         | ✅     | …        | …      | …       | …      | …    |
| Config Docker      | ✅     | …        | …      | …       | …      | …    |
| GitHub Actions     | ✅     | …        | …      | …       | …      | …    |

Puis les constats, **du plus critique au moins critique**. Bloc complet pour Critique / Élevée, une ligne pour Moyenne / Faible, Info repliée sur une ligne finale :

```
- [Critique] <paquet/composant> - <vulnérabilité> (CVE/GHSA/SA-id)
  Affecté : <plage de versions> · Installé : <actuelle> · Corrigé en : <version | pas encore>
  Risque ici : <pourquoi cette gravité DANS ce projet - atteignable ? prod ? exposé ?>
  Correctif : <commande exacte, ou marche à suivre numérotée si cassant>
- [Moyenne] <composant> - <vulnérabilité> (<id>) → <remédiation en une ligne>
Info : <paquet X non supporté> ; <image de base Y non épinglée> ; <action Z non épinglée sur un SHA>
```

Terminer par **ce qui n'a pas pu être vérifié**, en précisant quel échelon de la chaîne runner → hôte → WebFetch a été atteint et ce qui reste en attente (par exemple « recoupement du flux d'avis fait, mais un `composer audit` en direct sur tout l'historique reste dû »). Quand il y a des correctifs à livrer, orienter l'utilisateur vers `/max:review` puis `/max:pull-request` pour les faire atterrir sous forme de pull request.

## Limites

- **Ce n'est pas un outil offensif ni de pentest.** Ni exploitation, ni payload, ni sondage de cibles en production : audit du code et des dépendances uniquement.
- Ne pas livrer de vidages bruts d'avis : classer, dédoublonner et contextualiser. Un mur de sortie `npm audit` est l'entrée, pas le livrable.
- Ne pas affirmer qu'un contrôle est passé s'il n'a pas réellement tourné ; marquer les outils indisponibles « (indispo) ».
- Ne pas monter à l'aveugle tout l'arbre de dépendances pour faire taire un seul avis. Borner chaque changement.
- Les bugs applicatifs (injection, XSS dans du code maison) ne se signalent pas ici : c'est le travail de `/max:review` ; les noter comme hors-scope si on les repère.
