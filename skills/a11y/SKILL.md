---
name: a11y
description: "Audite et corrige l'accessibilité d'une interface web selon le RGAA et les WCAG - sémantique, clavier et focus, alternatives, formulaires, contrastes, ARIA, contenu dynamique - par les outils automatiques puis une vérification manuelle. À utiliser quand Maxime veut auditer ou corriger l'accessibilité, vérifier la conformité RGAA ou WCAG, rendre un composant utilisable au clavier ou au lecteur d'écran, ou invoque /max:a11y."
argument-hint: "[page ou composant]"
---

# Accessibilité

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **dev**.
3. Fixer le périmètre (pages, composants) et le référentiel : RGAA 4.1 et WCAG 2.2 niveau AA par défaut.
4. Lire `${CLAUDE_SKILL_DIR}/../../references/rgaa-checklist.md` pour les critères.

## Étapes

1. Lancer les outils présents dans le projet (`axe`, `pa11y`, Lighthouse) et relever les nombres réels. Ils trouvent environ un tiers des défauts.
2. Vérifier à la main : parcours complet au clavier, zoom à 200 %, lecteur d'écran sur les parcours clés, contrastes.
3. Passer les sept familles de contrôles de l'annexe.
4. Classer les constats par gravité, chacun avec `fichier:ligne`, le critère RGAA ou WCAG et le correctif.
5. Corriger par ordre d'impact (parcours impossible d'abord) et refaire la vérification après chaque lot.
6. Rendre compte : outils lancés et résultats, parcours manuels faits, ce qui n'a pas pu être vérifié.

## Points d'arrêt

- Aucun outil automatique dans le projet : le dire, ne rien installer, poursuivre à la main.
- Pas de lecteur d'écran ni d'appareil de test disponible : le noter non vérifié.
- Un taux de conformité est demandé : ne le donner que s'il est réellement calculable.

## Ce qu'il ne fait pas

- Déclarer une conformité totale : elle demande un auditeur et des tests utilisateurs.
- Masquer un défaut par un ARIA de façade, `eslint-disable` ou `axe-disable`.
- Refondre l'interface au-delà des correctifs d'accessibilité.

## Annexe : contrôles

| Famille | À vérifier |
| :-- | :-- |
| Sémantique | Un seul `h1`, aucun saut de niveau ; `header`, `nav`, `main`, `footer` ; vraies listes et vrais tableaux ; `button` pour une action, `a` pour une navigation ; `lang` sur `html` |
| Clavier et focus | Tout est atteignable et actionnable ; ordre logique ; focus visible ; aucun piège ; focus placé dans une modale à l'ouverture, rendu à la fermeture ; lien d'évitement |
| Alternatives | `alt` pertinent, vide pour une image décorative ; légendes ; transcriptions |
| Formulaires | `label` lié à chaque champ ; erreur annoncée et rattachée au champ ; champ obligatoire signalé autrement que par la couleur ; autocomplétion |
| Couleurs | Contraste d'au moins 4,5:1 pour le texte, 3:1 pour le grand texte et les composants ; aucune information portée par la seule couleur ; reflux sans perte à 200 % |
| ARIA | Seulement quand le HTML ne suffit pas ; rôles, états et propriétés cohérents |
| Contenu dynamique | Zones `aria-live` ; chargement annoncé ; `prefers-reduced-motion` respecté |
