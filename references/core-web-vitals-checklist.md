# Core Web Vitals : seuils et points de contrôle

Google retient trois métriques pour juger l'expérience d'une page : la vitesse d'affichage (LCP), la réactivité (INP) et la stabilité visuelle (CLS). Ce fichier fournit les **seuils officiels** puis, pour chaque métrique, une liste de **points à contrôler**. Ces points sont des pratiques courantes, pas des exigences normatives ; la documentation fait foi.

- Source : <https://web.dev/articles/vitals>
- Mesurer avec : PageSpeed Insights, Chrome DevTools (Performance, Lighthouse), Search Console (rapport Core Web Vitals), bibliothèque `web-vitals`.
- Les données **terrain** (vrais utilisateurs, CrUX) tranchent ; les données **labo** (Lighthouse) aident à comprendre. L'INP n'existe qu'en terrain : en labo, on lit le TBT à la place.

## Seuils

Une métrique est réussie quand son **75ᵉ centile** tombe dans la zone « bon », mobile et desktop évalués séparément.

| Métrique | Ce qu'elle mesure | Bon | À améliorer | Mauvais |
| :------- | :---------------- | :-- | :---------- | :------ |
| **LCP** (Largest Contentful Paint) | Temps d'affichage du plus gros élément visible | ≤ 2,5 s | ≤ 4 s | > 4 s |
| **INP** (Interaction to Next Paint) | Délai de réponse aux interactions | ≤ 200 ms | ≤ 500 ms | > 500 ms |
| **CLS** (Cumulative Layout Shift) | Décalages inattendus de la mise en page | ≤ 0,1 | ≤ 0,25 | > 0,25 |

| Cas | Statut de la page |
| :-- | :---------------- |
| Les trois métriques sont « bon » au 75ᵉ centile | Réussi |
| Au moins une métrique sort de « bon » | Non réussi |

### Suivre l'avancement de la liste

Pour chiffrer la progression, calculer un taux de couverture par métrique, puis global :

```text
taux = points cochés / (points cochés + points non cochés) × 100
```

Les points « NA » (sans objet pour la page) ne comptent pas. Ce taux est un repère : seuls les seuils ci-dessus décident de la réussite.

## 1. LCP : vitesse d'affichage

- [ ] **1.1** L'élément LCP (image, bloc de texte, poster de vidéo) est-il connu pour chaque type de page ?
- [ ] **1.2** Le serveur répond-il vite (TTFB cible ≤ 800 ms) ?
- [ ] **1.3** Le HTML est-il mis en cache (CDN, cache de page) lorsque le contenu s'y prête ?
- [ ] **1.4** L'image LCP figure-t-elle dans le HTML initial, sans injection par JavaScript ni `background-image` CSS ?
- [ ] **1.5** L'image LCP porte-t-elle `fetchpriority="high"` et **pas** `loading="lazy"` ?
- [ ] **1.6** Les images sont-elles en AVIF ou WebP, avec des tailles adaptées par `srcset` / `sizes` ?
- [ ] **1.7** Le CSS critique est-il minimal et le reste différé ?
- [ ] **1.8** Les scripts secondaires sont-ils en `defer` / `async` et ne bloquent-ils pas le rendu ?
- [ ] **1.9** Les polices web sont-elles préchargées au besoin, avec `font-display: swap` (ou `optional`) ?
- [ ] **1.10** Les connexions aux origines critiques sont-elles préparées (`preconnect`, `dns-prefetch`) ?
- [ ] **1.11** Les redirections inutiles avant la page ont-elles disparu ?
- [ ] **1.12** Les ressources sont-elles compressées (Brotli ou gzip) et servies en HTTP/2 ou HTTP/3 ?

## 2. INP : réactivité

- [ ] **2.1** Les interactions lentes sont-elles repérées (DevTools, attribution `web-vitals`, données terrain) ?
- [ ] **2.2** Aucune tâche de plus de 50 ms ne monopolise le fil principal pendant ou juste après le chargement ?
- [ ] **2.3** Les tâches longues sont-elles fractionnées (`scheduler.yield()`, `setTimeout`, `requestIdleCallback`) ?
- [ ] **2.4** Le JavaScript envoyé est-il réduit : découpage du code, imports dynamiques, tree shaking, dépendances légères ?
- [ ] **2.5** Les scripts tiers (analytics, publicité, chat, gestionnaire de balises) sont-ils audités, différés ou chargés à la demande ?
- [ ] **2.6** Les gestionnaires d'événements restent-ils légers, le calcul lourd partant dans un Web Worker ?
- [ ] **2.7** Les écouteurs `scroll`, `touchmove` et `wheel` sont-ils `passive` et allégés (debounce, throttle) ?
- [ ] **2.8** Le coût de rendu après une interaction est-il contenu : DOM raisonnable (cible < 1 500 nœuds), `content-visibility: auto` hors écran ?
- [ ] **2.9** Les lectures et écritures du DOM sont-elles regroupées pour éviter les reflows forcés ?
- [ ] **2.10** Chaque interaction donne-t-elle un retour visuel immédiat (état actif, chargement), même si le travail continue ensuite ?
- [ ] **2.11** Les rendus superflus du framework sont-ils évités (mémoïsation, composants découpés, listes virtualisées) ?

## 3. CLS : stabilité visuelle

- [ ] **3.1** Les décalages sont-ils localisés (DevTools Performance, Layout Shift Regions, attribution `web-vitals`) ?
- [ ] **3.2** Chaque image et vidéo déclare-t-elle `width` et `height` (ou `aspect-ratio`) ?
- [ ] **3.3** Les iframes et embeds (vidéo, carte, réseaux sociaux) ont-ils un emplacement de taille fixe ?
- [ ] **3.4** Les zones publicitaires et bannières ont-elles une hauteur réservée (`min-height`) ?
- [ ] **3.5** Les éléments injectés après coup (bandeau cookies, notification, promotion) s'insèrent-ils sans repousser le contenu (zone réservée, `position: fixed` / `sticky`) ?
- [ ] **3.6** Rien n'est-il inséré au-dessus du contenu déjà visible, sauf en réaction à une action de l'utilisateur ?
- [ ] **3.7** Le changement de police est-il peu visible (`font-display`, `size-adjust` et `ascent-override` sur la police de secours, préchargement) ?
- [ ] **3.8** Les animations reposent-elles sur `transform` et `opacity` plutôt que sur `top`, `left`, `width` ou `height` ?
- [ ] **3.9** Les squelettes et états de chargement ont-ils les dimensions du contenu final ?
- [ ] **3.10** La page reste-t-elle éligible au bfcache (pas de `unload`, pas de `Cache-Control: no-store` inutile) ?

## Pour creuser

Ces métriques ne font pas partie des Core Web Vitals mais aident à expliquer une mauvaise valeur :

| Métrique | Utilité | Bon |
| :------- | :------ | :-- |
| **TTFB** (Time to First Byte) | Temps de réponse du serveur, en amont du LCP | ≤ 800 ms |
| **FCP** (First Contentful Paint) | Moment du premier contenu affiché | ≤ 1,8 s |
| **TBT** (Total Blocking Time) | Labo uniquement, approximation de l'INP | ≤ 200 ms |
