---
name: a11y
description: Audite et corrige l'accessibilité d'une interface web selon le RGAA et les WCAG - sémantique, clavier et focus, contrastes, formulaires, alternatives textuelles, ARIA, outils automatiques puis vérification manuelle. Indépendant de la stack - charge stacks/<stack>/INDEX.md (dev). À utiliser quand l'utilisateur veut auditer ou corriger l'accessibilité, vérifier la conformité RGAA/WCAG, rendre un composant utilisable au clavier ou au lecteur d'écran, ou invoque /max:a11y.
---

# Accessibilité web (RGAA / WCAG)

Une interface utilisable par tous : clavier, lecteur d'écran, zoom, contrastes. Les outils automatiques détectent environ un tiers des problèmes : la vérification manuelle est obligatoire.

## Détecter la stack

Suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack, puis charger `stacks/<stack>/INDEX.md` pour la nature **dev** afin de connaître les composants, le gabarit et les bibliothèques d'interface. Sans ressource, s'en tenir aux conventions du projet. Ne jamais `Read` une ressource inexistante.

## Cadrer

- **Périmètre** : pages ou composants concernés, référentiel visé (RGAA 4.1, WCAG 2.2 niveau AA par défaut).
- Référence des critères : `${CLAUDE_SKILL_DIR}/../../references/rgaa-checklist.md`.

## Contrôles

1. **Sémantique** : titres hiérarchisés (`h1` unique, pas de saut), repères (`header`, `nav`, `main`, `footer`), listes et tableaux réels, `button` pour une action et `a` pour une navigation, `lang` sur `html`.
2. **Clavier et focus** : tout est atteignable et actionnable au clavier, ordre logique, focus **visible**, pas de piège, focus déplacé à l'ouverture d'une modale puis rendu à la fermeture, lien d'évitement.
3. **Alternatives** : `alt` pertinent (vide pour une image décorative), légendes, transcriptions pour l'audio et la vidéo.
4. **Formulaires** : `label` associé à chaque champ, erreurs annoncées et liées au champ, champs obligatoires indiqués autrement que par la couleur, autocomplétion appropriée.
5. **Couleurs et lisibilité** : contraste ≥ 4,5:1 (texte) et 3:1 (grand texte, composants), information jamais portée par la couleur seule, zoom à 200 % et reflux sans perte.
6. **ARIA** : seulement quand le HTML ne suffit pas ; rôles, états et propriétés cohérents ; un mauvais ARIA est pire que pas d'ARIA.
7. **Contenu dynamique** : zones `aria-live` pour les messages, états de chargement annoncés, respect de `prefers-reduced-motion`.

## Méthode

1. **Automatique** : `axe` / `pa11y` / Lighthouse si disponibles dans le projet (les lancer ; ne rien installer sans accord) et rapporter les nombres réels.
2. **Manuel** : parcours complet au clavier, zoom, lecteur d'écran sur les parcours clés, vérification des contrastes.
3. **Corriger** par ordre d'impact : bloquants (parcours impossible) d'abord, puis majeurs, puis mineurs ; refaire la vérification après chaque lot.

## Format de la réponse

1. Périmètre et référentiel.
2. Constats classés par gravité, chacun avec `fichier:ligne`, le critère RGAA/WCAG et le correctif.
3. Vérification réelle (outils lancés, résultats, parcours manuels faits).
4. Ce qui n'a pas pu être vérifié (lecteur d'écran, appareils) et le taux de conformité seulement s'il est réellement calculable.

## Hors périmètre

- Ne pas déclarer une conformité totale : un audit complet demande un auditeur et des tests utilisateurs.
- Ne pas masquer un problème avec un ARIA de façade ou une règle `eslint-disable` / `axe-disable`.
- Pas de dépendance installée sans accord ; la relecture relève de `/max:review`.
