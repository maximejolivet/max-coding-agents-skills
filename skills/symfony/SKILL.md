---
name: symfony
description: "Développe en Symfony (6.4, 7.x, 8.x) - services, contrôleurs, entités Doctrine, formulaires, sécurité, commandes, handlers Messenger, Twig - avec le déroulé de /max:dev et la stack fixée à Symfony. À utiliser quand Maxime implémente ou modifie du code Symfony, demande de l'aide sur Symfony, ou invoque /max:symfony."
argument-hint: "[issue, brief ou tâche]"
---

# Développer en Symfony

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lancer `sh "<max>/stacks/detect.sh"` : la ligne `framework	symfony` doit sortir.
2. Lire `<max>/references/regles.md`, une fois par session.
3. Lire `<max>/skills/dev/SKILL.md` : ses préalables, ses étapes, ses points d'arrêt et ses limites s'appliquent en entier. Ses chemins `<max>/…` partent de la même racine.
4. Lire `<max>/stacks/symfony/INDEX.md`, sections `core` et `dev`.

## Étapes

1. Suivre les étapes de `/max:dev`, sans refaire la détection.
2. Avant de choisir une API, la confronter au tableau « Ce qui varie » de la ressource.
3. Vérifier avec le bloc « Vérifier » de la section `dev`, par le runner.

## Points d'arrêt

- Le projet n'est pas un projet Symfony : le dire et passer à `/max:dev`.
- Une commande de la liste « Ne pas faire sans accord » de la ressource est nécessaire : attendre l'accord.

## Ce qu'il ne fait pas

- Rien de plus que `/max:dev`.
- Modifier le schéma autrement que par une migration relue.
