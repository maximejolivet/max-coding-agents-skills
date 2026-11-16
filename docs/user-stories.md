# User stories

Ce document explique comment formuler un besoin sous forme de story, puis recense les quatorze stories qui décrivent le plugin actuel.

## Écrire une bonne story

Une story raconte ce que veut accomplir une personne, pas la tâche technique à coder.

> **En tant que** [rôle], **je veux** [action], **afin de** [bénéfice].

Trois questions à se poser :

- **Qui ?** Un rôle précis plutôt qu'« un utilisateur ».
- **Quoi ?** Un geste observable, qui n'impose pas la solution.
- **Pourquoi ?** Le bénéfice ; sans lui, il s'agit d'une tâche.

Accompagne chaque story de deux à cinq critères d'acceptation testables. Vérifie le critère **INVEST** : indépendante, négociable, apportant de la valeur, estimable, petite, testable. Trop grosse, elle devient une épique à découper.

## Rôles

| Rôle | Il fait quoi avec Max |
| :--- | :-------------------- |
| Développeur | Écrit du code Symfony, Nuxt ou React. |
| Reviewer | Relit les PR des collègues. |
| Responsable sécurité | Surveille dépendances, Docker et workflows. |
| Ops | Conteneurise et déploie. |
| Mainteneur du plugin | Fait vivre skills, agents et stacks. |
| Chef de projet | Tient le backlog et choisit la méthode agile. |

## Dans GitHub

Une issue par story, avec le label `user-story`. Le titre reprend « En tant que… je veux… », les critères deviennent des cases à cocher. L'identifiant (`US-04`…) peut être cité dans les PR. `max:agile-planner` sait lire ces issues.

---

## Épique 1 · Développer

**US-01 · Développer dans ma techno.** En tant que développeur, je veux lancer `/max:symfony`, `/max:nuxt` ou `/max:react`, afin de coder dans le style du projet.
- [ ] Le skill lit le code existant et propose l'approche avant d'écrire.
- [ ] Sur un gros projet, `max:codebase-surveyor` résume d'abord la structure.
- [ ] Il se termine en renvoyant vers `/max:review`.

**US-02 · Travailler sur une stack inconnue.** En tant que développeur, je veux que les skills transverses fonctionnent sans stack prise en charge, afin de ne pas être bloqué.
- [ ] `stacks/detect.sh` ne plante pas et ne modifie rien.
- [ ] Les valeurs par défaut s'appliquent et le skill le signale.

**US-03 · Commits lisibles.** En tant que développeur, je veux que `/max:commit` rédige `type(scope): emoji description`, afin d'obtenir un historique clair.
- [ ] Le type vient de la liste du skill.
- [ ] Le message reflète ce que fait réellement le diff.

**US-04 · Tests fiables.** En tant que développeur, je veux que `/max:test` écrive un test de non-régression avant de corriger un bug, afin de prouver le correctif.
- [ ] Le test est rouge avant la correction, vert après.
- [ ] Un test instable est expliqué, pas relancé jusqu'à passer.

## Épique 2 · Relire et publier

**US-05 · Relire mon propre diff.** En tant que développeur, je veux un verdict classé par gravité avec des actions concrètes, afin de corriger avant la PR.
- [ ] Les constats portent sur correction, sécurité, performance, standards et tests.
- [ ] Sur un gros diff, les relecteurs travaillent en parallèle, en lecture seule.
- [ ] `max:frontend-reviewer` n'intervient que si le diff touche du front.

**US-06 · Ouvrir une PR en Draft.** En tant que développeur, je veux que `/max:pull-request` s'occupe de la branche, du commit, du push et de la PR, afin de publier sans erreur de procédure.
- [ ] La branche, `feat/<slug>` ou `fix/<slug>`, part de `main` à jour.
- [ ] La PR est en Draft vers `main` et cite l'issue.
- [ ] Aucun push direct sur `main`.
- [ ] Le nettoyage après merge est rappelé.

**US-07 · Relire la PR d'un autre.** En tant que reviewer, je veux que `/max:pr-review` prépare une note structurée, afin de trancher entre approuver et demander des changements.
- [ ] L'issue liée et les checks Actions sont chargés.
- [ ] La note reste un brouillon par défaut.
- [ ] Rien n'est posté sans accord explicite.

**US-08 · Versionner chaque PR.** En tant que mainteneur du plugin, je veux que `/max:versioning` incrémente et aligne la version, afin que Claude Code propose la mise à jour.
- [ ] Le PATCH monte de 0.0.1 par défaut.
- [ ] `plugin.json`, `marketplace.json` et le badge du README restent identiques.
- [ ] `tests/check.sh` est exécuté et passe.

## Épique 3 · Sécurité et infrastructure

**US-09 · Auditer l'ensemble.** En tant que responsable sécurité, je veux que `/max:security` classe selon le risque réellement exploitable, afin de traiter l'important d'abord.
- [ ] Les audits par domaine tournent en parallèle quand plusieurs domaines existent.
- [ ] Les correctifs sûrs sont appliqués ; les autres arrivent avec une marche à suivre.

**US-10 · Images propres.** En tant qu'ops, je veux que `/max:docker` produise des images reproductibles et minimales, afin de réduire la surface d'attaque.
- [ ] Image de base épinglée, utilisateur non root, aucun secret embarqué.

**US-11 · Kubernetes sans surprise.** En tant qu'ops, je veux que `/max:kubernetes` reste en lecture seule sur le cluster, afin d'éviter toute modification involontaire.
- [ ] Les manifestes déclarent probes, ressources et contexte de sécurité.
- [ ] Toute écriture sur le cluster demande confirmation.

## Épique 4 · Faire évoluer le plugin

**US-12 · Ajouter une techno.** En tant que mainteneur du plugin, je veux ajouter une stack via `detect.sh` et `stacks/<techno>/INDEX.md`, afin que tous les skills la gèrent.
- [ ] Aucun skill transverse n'est modifié.
- [ ] Le `core` de la techno n'existe qu'une fois.

**US-13 · Garder le dépôt cohérent.** En tant que mainteneur du plugin, je veux que `tests/check.sh` tourne en CI, afin d'attraper frontmatter invalide, références cassées et versions désalignées.
- [ ] Une référence `max:<nom>` ou `stacks/<id>/INDEX.md` inexistante fait échouer le contrôle.
- [ ] Il s'exécute sur chaque PR.

## Épique 5 · Piloter le projet

**US-14 · Choisir sa méthode agile.** En tant que chef de projet, je veux que `max:agile-planner` choisisse Scrum ou Kanban d'après mes stories, afin d'organiser le travail.
- [ ] Il lit les stories dans Notion ou dans les issues GitHub.
- [ ] Le choix est argumenté, et signalé provisoire sous 5 stories.
- [ ] Il n'écrit que dans Notion, jamais dans le dépôt.

---

## Priorités (MoSCoW)

| Niveau | Stories |
| :----- | :------ |
| Must | US-01, US-05, US-06, US-09, US-13 |
| Should | US-03, US-04, US-07, US-08, US-12 |
| Could | US-02, US-10, US-11, US-14 |
