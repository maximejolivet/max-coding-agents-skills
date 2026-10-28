# Core Web Vitals : seuils et checklist

Les Core Web Vitals sont les 3 métriques d'expérience utilisateur retenues par Google (Web Vitals) : chargement, interactivité, stabilité visuelle. Ce fichier donne les **seuils officiels** et une **checklist de points à vérifier** pour chacune. Les points de la checklist sont des bonnes pratiques courantes, pas des critères normatifs : pour le détail, se reporter à la documentation.

- Source : <https://web.dev/articles/vitals>
- Outils de mesure : PageSpeed Insights, Chrome DevTools (Performance, Lighthouse), Search Console (rapport Core Web Vitals), bibliothèque `web-vitals`.
- Données **terrain** (utilisateurs réels, CrUX) font foi ; les données **labo** (Lighthouse) servent à diagnostiquer. INP n'existe qu'en terrain (le labo utilise TBT comme approximation).

## Score

Une page réussit une métrique si son **75ᵉ centile** (mobile et desktop mesurés séparément) est dans la zone « bon ».

| Métrique | Mesure | Bon | À améliorer | Mauvais |
| :------- | :----- | :-- | :---------- | :------ |
| **LCP** (Largest Contentful Paint) | Chargement du plus gros élément visible | ≤ 2,5 s | ≤ 4 s | > 4 s |
| **INP** (Interaction to Next Paint) | Réactivité aux interactions | ≤ 200 ms | ≤ 500 ms | > 500 ms |
| **CLS** (Cumulative Layout Shift) | Décalages de mise en page | ≤ 0,1 | ≤ 0,25 | > 0,25 |

Statut de la page :

| Situation | Statut |
| :-------- | :----- |
| Les 3 métriques sont « bon » au 75ᵉ centile | Réussi |
| Au moins une métrique n'est pas « bon » | Non réussi |

Pour suivre la progression de la checklist ci-dessous, calculer un **taux de couverture** par métrique et global (même principe que le score RGAA, ce taux est indicatif) :

```text
taux = points cochés / (points cochés + points non cochés) × 100
```

Les points « NA » (sans objet pour la page) sont exclus du calcul. Le taux de couverture ne remplace pas la mesure : seuls les seuils du tableau décident de la réussite.

## 1. LCP : chargement

- [ ] **1.1** L'élément LCP (image, bloc de texte, vidéo poster) est-il identifié sur chaque type de page ?
- [ ] **1.2** Le temps de réponse serveur (TTFB) est-il bas (cible ≤ 800 ms) ?
- [ ] **1.3** Le HTML est-il mis en cache (CDN, cache de page) quand le contenu le permet ?
- [ ] **1.4** L'image LCP est-elle découvrable dans le HTML initial (pas injectée par JavaScript, pas en `background-image` CSS) ?
- [ ] **1.5** L'image LCP a-t-elle `fetchpriority="high"` et n'a-t-elle **pas** `loading="lazy"` ?
- [ ] **1.6** Les images sont-elles dans un format moderne (AVIF, WebP) et dimensionnées via `srcset` / `sizes` ?
- [ ] **1.7** Le CSS critique est-il réduit, et le CSS non critique différé ?
- [ ] **1.8** Les scripts non essentiels sont-ils en `defer` / `async`, sans bloquer le rendu ?
- [ ] **1.9** Les polices web sont-elles préchargées si nécessaire, avec `font-display: swap` (ou `optional`) ?
- [ ] **1.10** Les connexions vers les origines critiques sont-elles anticipées (`preconnect`, `dns-prefetch`) ?
- [ ] **1.11** Les redirections inutiles avant la page sont-elles supprimées ?
- [ ] **1.12** Les ressources sont-elles compressées (Brotli ou gzip) et servies en HTTP/2 ou HTTP/3 ?

## 2. INP : interactivité

- [ ] **2.1** Les interactions lentes sont-elles identifiées (DevTools, `web-vitals` attribution, rapport terrain) ?
- [ ] **2.2** Aucune tâche longue (> 50 ms) ne bloque le fil principal pendant ou juste après le chargement ?
- [ ] **2.3** Les longues tâches sont-elles découpées (`scheduler.yield()`, `setTimeout`, `requestIdleCallback`) ?
- [ ] **2.4** Le JavaScript livré est-il limité : code splitting, imports dynamiques, tree shaking, dépendances allégées ?
- [ ] **2.5** Les scripts tiers (analytics, publicité, chat, tag manager) sont-ils audités, différés ou chargés à la demande ?
- [ ] **2.6** Les gestionnaires d'événements font-ils peu de travail synchrone (calcul lourd déplacé vers un Web Worker) ?
- [ ] **2.7** Les écouteurs `scroll`, `touchmove` et `wheel` sont-ils `passive` et allégés (debounce, throttle) ?
- [ ] **2.8** Le coût de rendu après interaction est-il maîtrisé : DOM de taille raisonnable (cible < 1 500 nœuds), `content-visibility: auto` sur les zones hors écran ?
- [ ] **2.9** Les lectures et écritures du DOM sont-elles groupées pour éviter les reflows forcés ?
- [ ] **2.10** Un retour visuel immédiat suit-il chaque interaction (état actif, chargement), même si le travail se poursuit ensuite ?
- [ ] **2.11** Les rendus inutiles du framework sont-ils évités (mémoïsation, découpage des composants, listes virtualisées) ?

## 3. CLS : stabilité visuelle

- [ ] **3.1** Les décalages sont-ils localisés (DevTools Performance, Layout Shift Regions, attribution `web-vitals`) ?
- [ ] **3.2** Chaque image et vidéo a-t-elle `width` et `height` (ou `aspect-ratio` CSS) ?
- [ ] **3.3** Les iframes et embeds (vidéo, carte, réseaux sociaux) ont-ils un espace réservé de taille fixe ?
- [ ] **3.4** Les emplacements publicitaires et bannières ont-ils une hauteur réservée (`min-height`) ?
- [ ] **3.5** Les contenus injectés dynamiquement (bandeau cookies, notification, promotion) sont-ils insérés sans pousser le contenu existant (zone réservée, `position: fixed` / `sticky`) ?
- [ ] **3.6** Le contenu n'est-il pas inséré au-dessus du contenu déjà affiché, sauf en réponse à une action de l'utilisateur ?
- [ ] **3.7** Les polices web limitent-elles le décalage au changement de police (`font-display`, `size-adjust` et `ascent-override` sur la police de secours, préchargement) ?
- [ ] **3.8** Les animations utilisent-elles `transform` et `opacity` plutôt que des propriétés qui déclenchent la mise en page (`top`, `left`, `width`, `height`) ?
- [ ] **3.9** Les skeletons et états de chargement ont-ils les mêmes dimensions que le contenu final ?
- [ ] **3.10** La page reste-t-elle éligible au bfcache (pas de `unload`, pas de `Cache-Control: no-store` inutile) ?

## Pour aller plus loin

Métriques de diagnostic, hors Core Web Vitals, utiles pour comprendre une mauvaise valeur :

| Métrique | Rôle | Bon |
| :------- | :--- | :-- |
| **TTFB** (Time to First Byte) | Temps de réponse serveur, en amont du LCP | ≤ 800 ms |
| **FCP** (First Contentful Paint) | Premier contenu affiché | ≤ 1,8 s |
| **TBT** (Total Blocking Time) | Labo uniquement, proxy de l'INP | ≤ 200 ms |
