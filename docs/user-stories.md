# User stories

Comment écrire des user stories pour ce dépôt, et la première série qui décrit le plugin tel qu'il existe.

## Écrire une user story

Une user story décrit un besoin du point de vue de la personne qui utilise le plugin, pas une tâche technique.

> **En tant que** [rôle], **je veux** [action], **afin de** [bénéfice].

- **Qui ?** Un rôle précis, pas « l'utilisateur » en général.
- **Quoi ?** Une action observable, sans imposer la solution.
- **Pourquoi ?** Le bénéfice. Sans lui, c'est une tâche.

Ajouter 2 à 5 critères d'acceptation vérifiables (Étant donné / Quand / Alors). Une bonne story est INVEST : indépendante, négociable, valuable, estimable, small, testable. Une story trop grosse est une épique : la découper.

## Rôles

| Rôle | Description |
| :--- | :---------- |
| Développeur | Écrit du code Symfony, Nuxt ou React avec le plugin. |
| Reviewer | Relit les PR des autres. |
| Responsable sécurité | Veille aux dépendances, à Docker et aux workflows. |
| Ops | Conteneurise et déploie (Docker, Kubernetes). |
| Mainteneur du plugin | Fait évoluer les skills, agents et stacks de ce dépôt. |
| Chef de projet | Pilote le backlog et la méthode agile. |

## Format dans GitHub

Une issue par story, label `user-story`, titre « En tant que… je veux… », critères en cases à cocher. `max:agile-planner` lit ces issues. L'identifiant (ex. `US-04`) sert de référence dans les PR.

## Épique 1 : Développer

### US-01 Développer une fonctionnalité dans ma techno
En tant que développeur, je veux lancer `/max:symfony`, `/max:nuxt` ou `/max:react`, afin d'implémenter en respectant les idiomes du projet.
- [ ] Le skill lit d'abord le code existant et propose l'approche avant d'implémenter.
- [ ] Sur un gros projet, `max:codebase-surveyor` résume la structure avant le changement.
- [ ] La fin du skill renvoie vers `/max:review`.

### US-02 Utiliser le plugin sur une stack inconnue
En tant que développeur, je veux que les skills génériques fonctionnent sans stack supportée, afin de ne pas être bloqué.
- [ ] `stacks/detect.sh` ne plante pas et ne modifie rien.
- [ ] Les valeurs par défaut s'appliquent et le skill l'annonce.

### US-03 Rédiger des commits sémantiques
En tant que développeur, je veux que `/max:commit` rédige `type(scope): emoji description`, afin d'avoir un historique lisible.
- [ ] Le type est choisi parmi la liste du skill.
- [ ] Le message décrit le changement réel du diff.

### US-04 Écrire et diagnostiquer des tests
En tant que développeur, je veux que `/max:test` écrive d'abord un test de non-régression pour un bug, afin de prouver la correction.
- [ ] Le test échoue avant le correctif et passe après.
- [ ] Un test instable est diagnostiqué, pas relancé jusqu'au vert.

## Épique 2 : Relire et publier

### US-05 Relire mon diff avant le merge
En tant que développeur, je veux un verdict classé par gravité avec des actions concrètes, afin de corriger avant la PR.
- [ ] Les constats couvrent correction, sécurité, performance, standards et tests.
- [ ] Sur un gros diff, les reviewers tournent en parallèle et en lecture seule.
- [ ] Le front est relu par `max:frontend-reviewer` seulement si le diff touche du front.

### US-06 Ouvrir une PR en Draft
En tant que développeur, je veux que `/max:pull-request` crée la branche, le commit, le push et la PR, afin de publier sans erreur de procédure.
- [ ] La branche part de `main` à jour et s'appelle `feat/<slug>` ou `fix/<slug>`.
- [ ] La PR est en Draft vers `main` et référence l'issue.
- [ ] Aucun push direct sur `main`.
- [ ] Le nettoyage local après merge est rappelé.

### US-07 Relire la PR de quelqu'un d'autre
En tant que reviewer, je veux que `/max:pr-review` prépare une note structurée, afin de décider approve ou request-changes.
- [ ] L'issue liée et les checks GitHub Actions sont chargés.
- [ ] La note est un brouillon par défaut.
- [ ] La review n'est postée qu'après accord explicite.

### US-08 Versionner à chaque PR
En tant que mainteneur du plugin, je veux que `/max:versioning` incrémente et aligne la version, afin que Claude Code propose la mise à jour.
- [ ] Le PATCH augmente de 0.0.1 par défaut.
- [ ] `plugin.json`, `marketplace.json` et le badge du README restent identiques.
- [ ] `tests/check.sh` est lancé et passe.

## Épique 3 : Sécurité et infrastructure

### US-09 Auditer dépendances, Docker et Actions
En tant que responsable sécurité, je veux que `/max:security` classe les constats selon le risque réellement exploitable, afin de traiter l'important d'abord.
- [ ] Les audits par domaine tournent en parallèle quand plusieurs domaines existent.
- [ ] Les correctifs sûrs sont appliqués ; les autres viennent avec une marche à suivre.

### US-10 Conteneuriser proprement
En tant qu'ops, je veux que `/max:docker` produise des images reproductibles et minimales, afin de réduire la surface d'attaque.
- [ ] Image de base épinglée, utilisateur non root, pas de secret dans l'image.

### US-11 Préparer un déploiement Kubernetes sans risque
En tant qu'ops, je veux que `/max:kubernetes` reste en lecture seule sur le cluster par défaut, afin d'éviter toute modification involontaire.
- [ ] Les manifestes ont probes, ressources et contexte de sécurité.
- [ ] Toute écriture sur le cluster demande une confirmation.

## Épique 4 : Faire évoluer le plugin

### US-12 Ajouter une techno sans toucher aux skills
En tant que mainteneur du plugin, je veux ajouter une stack via `detect.sh` et `stacks/<techno>/INDEX.md`, afin que tous les skills la prennent en charge.
- [ ] Aucun skill générique n'est modifié.
- [ ] Le `core` de la techno n'existe qu'une fois.

### US-13 Garder le dépôt cohérent
En tant que mainteneur du plugin, je veux que `tests/check.sh` tourne en CI, afin de détecter frontmatter invalide, références cassées et versions désalignées.
- [ ] Le check échoue sur une référence `max:<nom>` ou `stacks/<id>/INDEX.md` inexistante.
- [ ] Il tourne sur chaque PR.

## Épique 5 : Piloter le projet

### US-14 Choisir ma méthode agile
En tant que chef de projet, je veux que `max:agile-planner` choisisse Scrum ou Kanban d'après mes stories, afin d'organiser le travail.
- [ ] Il lit les stories dans Notion ou les issues GitHub.
- [ ] La décision est justifiée et marquée provisoire sous 5 stories.
- [ ] Il n'écrit que dans Notion, jamais dans le dépôt.

## Priorisation (MoSCoW)

| Priorité | Stories |
| :------- | :------ |
| Must | US-01, US-05, US-06, US-09, US-13 |
| Should | US-03, US-04, US-07, US-08, US-12 |
| Could | US-02, US-10, US-11, US-14 |
