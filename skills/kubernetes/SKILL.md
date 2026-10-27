---
name: kubernetes
description: Guide le travail sur Kubernetes - manifestes YAML, Kustomize, charts Helm, probes, ressources, sécurité des pods, réseau, configuration et déploiement via GitHub Actions - avec un accent sur la reproductibilité, la sécurité et la simplicité. À utiliser quand l'utilisateur écrit, relit ou débogue des manifestes Kubernetes, un chart Helm, une configuration Kustomize, un déploiement sur un cluster, ou demande de l'aide sur Kubernetes, ou invoque /max:kubernetes.
---

# Kubernetes

Écrire, relire et déboguer des manifestes Kubernetes, du Kustomize ou des charts Helm, et la CI qui les déploie. Quatre objectifs, dans cet ordre : un déploiement **reproductible** (tout est versionné, rien n'est modifié à la main), **sûr** (privilèges minimaux, secrets protégés), **observable** (probes, ressources, logs) et **simple** (pas plus d'abstraction que nécessaire).

Pour construire l'image elle-même, voir `/max:docker`. Pour un audit de sécurité approfondi, voir `/max:security`.

## Règle d'or : lecture seule par défaut

Un cluster est un environnement partagé et souvent de production. Tant que l'utilisateur n'a pas dit autrement :

- Utiliser uniquement des commandes **en lecture** : `kubectl get`, `describe`, `logs`, `diff`, `events`, `auth can-i`, `kubectl apply --dry-run=server`.
- **Annoncer le contexte avant toute commande** : `kubectl config current-context` et le namespace visé. Ne jamais supposer qu'on est sur le bon cluster.
- Ne jamais lancer `apply`, `delete`, `patch`, `edit`, `scale`, `rollout restart`, `drain`, `cordon`, `exec` dans un pod de production, ni `helm install / upgrade / uninstall` sans accord explicite, après avoir montré le diff et le contexte.
- Préférer `kubectl diff -f` ou `helm diff upgrade` (si installé) pour montrer l'effet avant d'appliquer.

## Commencer par lire l'existant

Regarder comment le projet déploie déjà, et suivre ses conventions plutôt que d'en ajouter une de plus :

```bash
ls k8s kubernetes deploy manifests charts helm kustomization.y*ml Chart.yaml skaffold.y*ml 2>/dev/null
ls .github/workflows/*.y*ml 2>/dev/null
kubectl config current-context 2>/dev/null
```

- Identifier l'outil de packaging : manifestes bruts, **Kustomize** (bases et overlays), **Helm** (chart et `values-*.yaml`), ou un outil GitOps (Argo CD, Flux).
- Repérer les environnements (dev, staging, prod) et la façon dont ils diffèrent. Dire en une phrase ce qui existe et ce qui sera modifié avant de le faire.
- **Spécificités de la stack** - suivre la procédure commune `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`) ; pour chaque framework qui a une ressource, charger `stacks/<stack>/INDEX.md` pour la nature **deploy** (elle tire `core` + `deploy`) et l'appliquer en plus des règles générales ci-dessous. Sans ressource ou sans section `deploy`, rester générique et le dire ; ne jamais `Read` une ressource inexistante.

## Manifestes : ce qu'il faut toujours définir

**Identité et organisation**
- Une `apiVersion` à jour (`apps/v1`, `networking.k8s.io/v1`, `batch/v1`) ; pas d'API retirées.
- Labels standard `app.kubernetes.io/name`, `instance`, `version`, `component`, `part-of`, `managed-by` ; les `selector` d'un `Deployment` ne changent plus après création.
- Un `namespace` explicite ; ne pas tout déposer dans `default`.

**Image**
- Image épinglée sur un tag précis, idéalement avec son digest ; jamais `latest`. `imagePullPolicy` cohérent avec cela.
- Un registre privé se référence par `imagePullSecrets`, pas par un secret copié dans le manifeste.

**Ressources et fiabilité**
- `resources.requests` et `limits` pour le CPU et la mémoire sur chaque conteneur : les requests servent au placement, les limits protègent le nœud. Éviter une limite CPU très serrée qui bride l'application.
- **Probes** : `readinessProbe` (le pod reçoit-il du trafic ?), `livenessProbe` (faut-il le redémarrer ?), et `startupProbe` pour un démarrage lent. Ne pas faire dépendre la liveness d'un service externe (base de données) : une panne externe redémarrerait tous les pods en boucle.
- `replicas` ≥ 2 pour un service qui doit rester disponible, avec un `PodDisruptionBudget` ; `topologySpreadConstraints` ou anti-affinité pour répartir les réplicas.
- Stratégie de déploiement : `RollingUpdate` avec `maxUnavailable` / `maxSurge` réglés ; `terminationGracePeriodSeconds` et un traitement du signal `SIGTERM` pour l'arrêt propre.
- `HorizontalPodAutoscaler` seulement si les `requests` sont réalistes.

## Sécurité des pods

Appliquer par défaut un `securityContext` restrictif, adapté à l'application :

```yaml
securityContext:               # au niveau du pod
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
containers:
  - name: app
    securityContext:           # au niveau du conteneur
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
```

- Pas de `privileged: true`, pas de `hostNetwork`, `hostPID`, `hostPath` sans raison documentée.
- Un `ServiceAccount` dédié par application, avec `automountServiceAccountToken: false` quand l'API Kubernetes n'est pas utilisée, et un `Role` aux droits minimaux (jamais `cluster-admin` pour une application).
- **Pod Security Standards** : viser le niveau `restricted` par namespace (labels `pod-security.kubernetes.io/enforce`).
- **NetworkPolicy** : refuser par défaut (`default-deny`) puis autoriser explicitement les flux nécessaires.
- Si `readOnlyRootFilesystem` casse l'application, monter un `emptyDir` sur les seuls répertoires inscriptibles (`/tmp`, cache) plutôt que d'abandonner la protection.

## Configuration et secrets

- `ConfigMap` pour la configuration non sensible, `Secret` pour le reste. Un `Secret` n'est qu'encodé en base64 : **ne jamais versionner de valeur réelle**.
- Chiffrer ou externaliser : Sealed Secrets, SOPS, External Secrets Operator, ou le gestionnaire de secrets du fournisseur. Choisir ce que le projet utilise déjà.
- Injecter par variables d'environnement (`valueFrom.secretKeyRef`) ou par volumes en lecture seule ; un changement de `ConfigMap` ne redémarre pas les pods tout seul (annotation avec le hash du contenu, ou `Reloader`).
- Jamais de secret en clair dans un manifeste, un `values.yaml`, un workflow ou un journal.

## Réseau et exposition

- `Service` de type `ClusterIP` par défaut ; exposer vers l'extérieur par un `Ingress` (ou `Gateway` / `HTTPRoute`) avec TLS (cert-manager), pas par des `NodePort` ni `LoadBalancer` multipliés.
- Les ports et leurs noms (`containerPort` nommé, `targetPort` par nom) sont cohérents entre Deployment, Service et probes.
- Ne publier ni base de données ni administration hors du cluster.

## Kustomize et Helm

**Kustomize** - une `base/` commune et des `overlays/<env>/` qui ne contiennent que les différences (patches, images, replicas, ressources). Pas de duplication de la base. `kubectl kustomize overlays/<env>` doit produire le YAML final avant tout `apply`.

**Helm** - un `values.yaml` avec des valeurs par défaut sûres, un fichier `values-<env>.yaml` par environnement, `helm lint` et `helm template` qui passent. Pas de logique complexe dans les gabarits ; documenter les valeurs. Épingler la version du chart en dépendance. Ne pas modifier une release à la main hors de Helm.

Choisir l'un des deux selon l'existant ; ne pas mélanger sans raison.

## Déploiement via GitHub Actions

Déployer depuis la CI plutôt qu'à la main, avec un accès au cluster le plus étroit possible :

- **Authentification sans clé de longue durée** : OIDC vers le fournisseur cloud (`id-token: write`) plutôt qu'un `kubeconfig` ou un jeton stocké en secret. Si un secret est inévitable, le limiter à un environnement GitHub protégé.
- **Environnements GitHub** (`environment: production`) avec approbation manuelle pour la production.
- **Permissions minimales** du workflow (`contents: read`), actions épinglées sur un SHA de commit complet (ne jamais inventer le SHA : `<sha de la release>` à remplir).
- Déploiement par PR et GitOps (Argo CD, Flux) quand le projet le pratique ; sinon, étapes `kubectl diff` puis `apply` avec attente de la fin du déploiement :

```yaml
- run: kubectl diff -f k8s/ || true          # montre l'effet ; le code de sortie 1 signale des différences
- run: kubectl apply -f k8s/
- run: kubectl rollout status deployment/<nom> --timeout=180s
```

- Pas d'interpolation de `${{ github.event.* }}` directement dans un `run:`.

## Déboguer

Procéder du plus général au plus précis, en lecture seule :

```bash
kubectl get pods -n <ns> -o wide
kubectl describe pod <pod> -n <ns>              # événements : image, probes, ressources, ordonnancement
kubectl logs <pod> -n <ns> [-c <conteneur>] [--previous]
kubectl get events -n <ns> --sort-by=.lastTimestamp
kubectl rollout status deployment/<nom> -n <ns>
kubectl auth can-i <verbe> <ressource> -n <ns> --as=system:serviceaccount:<ns>:<sa>
```

Causes fréquentes : `ImagePullBackOff` (tag ou secret de registre), `CrashLoopBackOff` (voir `logs --previous`), `Pending` (requests trop grandes, taints, volume), `OOMKilled` (limite mémoire), probes qui échouent, sélecteurs de Service qui ne correspondent à aucun label.

## Vérifier

Lancer ce qui peut l'être sans toucher au cluster, et rapporter ce qui a réellement tourné ; ne jamais affirmer qu'un contrôle est passé s'il n'a pas été exécuté. Les outils absents se notent « (indispo) » - ne rien installer pour l'occasion.

```bash
kubectl apply --dry-run=server -f <fichier>      # validation par l'API (nécessite un cluster) ; sinon --dry-run=client
kubectl kustomize overlays/<env>                 # le YAML final produit par Kustomize
helm lint <chart> && helm template <chart> -f values-<env>.yaml
kubeconform -strict <fichiers>                   # schéma des manifestes, si installé
kube-linter lint <dossier>                       # bonnes pratiques, si installé
trivy config <dossier>                           # mauvaises configurations, si installé
```

## Format de la réponse

- Ce qui a été modifié ou créé, fichier par fichier, avec le *pourquoi* des choix non évidents.
- Le contexte et le namespace visés, et les commandes de lecture lancées avec leur résultat.
- Ce qui a été vérifié et ce qui ne l'a pas été, les compromis assumés et les points laissés ouverts.

## Hors périmètre

- Ne jamais modifier un cluster (`apply`, `delete`, `patch`, `scale`, `rollout`, `helm upgrade / uninstall`) sans accord explicite, après avoir annoncé le contexte et montré le diff. Ne rien faire de tel sur un contexte de production sans le dire clairement.
- Ne jamais afficher, écrire ou committer la valeur d'un `Secret` ; ne pas lancer `kubectl get secret -o yaml` sans nécessité.
- Ne jamais contourner une protection (`--force`, `--grace-period=0`, désactiver une NetworkPolicy) pour « faire passer » un déploiement.
- Ne pas migrer toute l'infrastructure pour une demande ciblée : proposer, cadrer, laisser l'utilisateur décider.
- L'image se construit avec `/max:docker`, l'audit approfondi relève de `/max:security`, la revue du diff de `/max:review`.
