---
name: a11y
description: Audite et corrige l'accessibilité d'une interface web selon le RGAA et les WCAG - sémantique, clavier et focus, contrastes, formulaires, alternatives textuelles, ARIA, outils automatiques puis vérification manuelle. Indépendant de la stack - charge stacks/<stack>/INDEX.md (dev). À utiliser quand l'utilisateur veut auditer ou corriger l'accessibilité, vérifier la conformité RGAA/WCAG, rendre un composant utilisable au clavier ou au lecteur d'écran, ou invoque /max:a11y.
---

# Accessibilité web (RGAA / WCAG)

Rendre une interface utilisable par tous : au clavier, au lecteur d'écran, en zoom, avec des contrastes suffisants. Les outils automatiques ne trouvent qu'environ un tiers des défauts : le contrôle manuel n'est pas optionnel.

## Stack

Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack, puis lire `stacks/<stack>/INDEX.md` pour la nature **dev** : composants, gabarits et bibliothèques d'interface. Sans ressource, suivre les conventions du projet. Ne jamais `Read` une ressource inexistante.

## Cadrage

- **Périmètre** : pages ou composants visés, référentiel retenu (RGAA 4.1, WCAG 2.2 niveau AA par défaut).
- Critères de référence : `${CLAUDE_SKILL_DIR}/../../references/rgaa-checklist.md`.

## Points de contrôle

1. **Sémantique** : titres hiérarchisés (un seul `h1`, pas de saut de niveau), repères (`header`, `nav`, `main`, `footer`), vraies listes et vrais tableaux, `button` pour une action et `a` pour une navigation, `lang` sur `html`.
2. **Clavier et focus** : tout est atteignable et actionnable au clavier, dans un ordre logique, avec un focus **visible**, sans piège ; à l'ouverture d'une modale le focus y entre, à la fermeture il revient ; lien d'évitement présent.
3. **Alternatives** : `alt` pertinent (vide pour une image décorative), légendes, transcriptions pour audio et vidéo.
4. **Formulaires** : un `label` lié à chaque champ, erreurs annoncées et rattachées au champ, champs obligatoires signalés autrement que par la couleur, autocomplétion adaptée.
5. **Couleurs et lisibilité** : contraste ≥ 4,5:1 (texte) et 3:1 (grand texte, composants), information jamais portée par la seule couleur, zoom à 200 % et reflux sans perte.
6. **ARIA** : seulement quand le HTML natif ne suffit pas ; rôles, états et propriétés cohérents ; un ARIA fautif nuit plus qu'une absence d'ARIA.
7. **Contenu dynamique** : zones `aria-live` pour les messages, états de chargement annoncés, respect de `prefers-reduced-motion`.

## Méthode

1. **Automatique** : `axe`, `pa11y` ou Lighthouse s'ils sont présents dans le projet (les lancer ; rien n'est installé sans accord), et rapporter les chiffres réels.
2. **Manuel** : parcours complet au clavier, zoom, lecteur d'écran sur les parcours clés, mesure des contrastes.
3. **Corriger** par ordre d'impact (bloquants, puis majeurs, puis mineurs) et refaire la vérification après chaque lot.

## Forme de la réponse

1. Périmètre et référentiel.
2. Constats par gravité, chacun avec `fichier:ligne`, le critère RGAA/WCAG et le correctif.
3. Vérification réelle : outils lancés, résultats, parcours manuels effectués.
4. Ce qui n'a pu être vérifié (lecteur d'écran, appareils), et un taux de conformité uniquement s'il est réellement calculable.

## Limites

- Aucune conformité totale ne se déclare : un audit complet suppose un auditeur et des tests utilisateurs.
- Ne pas masquer un défaut par un ARIA de façade ou une règle `eslint-disable` / `axe-disable`.
- Aucune dépendance installée sans accord ; la relecture relève de `/max:review`.
