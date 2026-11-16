---
name: kubernetes
description: "Écrit, relit et débogue des manifestes Kubernetes, des overlays Kustomize et des charts Helm - probes, ressources, sécurité des pods, secrets, réseau, déploiement par GitHub Actions - en lecture seule sur le cluster par défaut. À utiliser quand Maxime travaille sur des manifestes, un chart Helm, une configuration Kustomize ou un déploiement sur un cluster, ou invoque /max:kubernetes."
---

# Kubernetes

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. Lancer :

   ```bash
   kubectl config current-context 2>/dev/null
   ls k8s kubernetes deploy manifests charts helm kustomization.y*ml Chart.yaml 2>/dev/null
   ls .github/workflows/*.y*ml 2>/dev/null
   ```

3. Annoncer le contexte et le namespace visés avant toute commande `kubectl`.
4. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **deploy**.

## Étapes

1. Identifier l'outil du projet (manifestes bruts, Kustomize, Helm, GitOps) et ses environnements. Ne pas en introduire un second.
2. Dire en une phrase ce qui existe et ce qui va changer.
3. Écrire ou corriger les manifestes avec les groupes de l'annexe.
4. Produire le YAML final : `kubectl kustomize overlays/<env>` ou `helm template <chart> -f values-<env>.yaml`.
5. Vérifier sans toucher au cluster (annexe) et rapporter ce qui a réellement tourné.
6. Montrer l'effet avec `kubectl diff -f` ou `helm diff upgrade`, puis attendre l'accord avant toute écriture.
7. Rendre compte : fichiers touchés, contexte et namespace, commandes de lecture lancées, ce qui n'a pas été vérifié.

Pour déboguer : suivre le bloc « Déboguer » de l'annexe, du plus général au plus précis.

## Points d'arrêt

- Le contexte courant n'est pas celui attendu, ou vise la production : s'arrêter et le dire.
- Toute écriture sur le cluster (`apply`, `delete`, `patch`, `edit`, `scale`, `rollout restart`, `drain`, `helm install`, `upgrade`, `uninstall`) : montrer le diff et le contexte, attendre l'accord.
- `exec` dans un pod de production : attendre l'accord.
- `readOnlyRootFilesystem` casse l'application : monter un `emptyDir` sur les seuls répertoires inscriptibles, ne pas retirer la protection.
- Un secret doit être versionné : utiliser l'outil du projet (Sealed Secrets, SOPS, External Secrets), sinon s'arrêter.

## Ce qu'il ne fait pas

- Afficher, écrire ou committer la valeur d'un `Secret` ; `kubectl get secret -o yaml` sans nécessité.
- Contourner une protection : `--force`, `--grace-period=0`, NetworkPolicy coupée.
- Modifier une release à la main hors de Helm.
- Construire l'image : `/max:docker`. Auditer : `/max:security`.

## Annexe

### Manifestes

Identité et image :

- `apiVersion` à jour, `namespace` explicite, labels `app.kubernetes.io/*`. Le `selector` d'un Deployment ne change plus après création.
- Image épinglée sur un tag précis, avec son digest si possible. Jamais `latest`.
- Registre privé par `imagePullSecrets`.

Fiabilité :

- `resources.requests` et `limits` sur chaque conteneur ; pas de limite CPU trop serrée.
- `readinessProbe`, `livenessProbe`, `startupProbe` pour un démarrage lent. La liveness ne dépend d'aucun service externe.
- `replicas` à 2 au moins avec un `PodDisruptionBudget` pour un service qui doit rester disponible.
- `RollingUpdate` réglé, `terminationGracePeriodSeconds`, `SIGTERM` traité.
- `HorizontalPodAutoscaler` seulement si les `requests` sont réalistes.

Sécurité :

```yaml
securityContext:               # pod
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
containers:
  - name: app
    securityContext:           # conteneur
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
```

- Ni `privileged`, ni `hostNetwork`, `hostPID`, `hostPath` sans raison documentée.
- Un `ServiceAccount` par application, `automountServiceAccountToken: false` si l'API n'est pas utilisée, `Role` minimal.
- Pod Security Standards au niveau `restricted` par namespace.
- NetworkPolicy en refus par défaut, puis flux autorisés un à un.

Configuration et réseau :

- `ConfigMap` pour le non sensible, `Secret` pour le reste. Un `Secret` n'est qu'encodé en base64 : aucune valeur réelle versionnée.
- Un changement de `ConfigMap` ne redémarre pas les pods : annotation portant le hash, ou `Reloader`.
- `Service` en `ClusterIP` ; exposition par `Ingress` ou `Gateway` avec TLS.
- Noms de ports cohérents entre Deployment, Service et probes.

Packaging :

- Kustomize : une `base/`, des `overlays/<env>/` qui ne portent que les différences.
- Helm : `values.yaml` aux défauts sûrs, un `values-<env>.yaml` par environnement, version du chart épinglée.

### Déploiement par GitHub Actions

Règles de `/max:ci`, plus :

- OIDC vers le fournisseur cloud plutôt qu'un `kubeconfig` en secret.
- `environment: production` avec approbation manuelle.
- Sans GitOps : `kubectl diff`, `kubectl apply`, puis `kubectl rollout status deployment/<nom> --timeout=180s`.

### Vérifier

```bash
kubectl apply --dry-run=server -f <fichier>      # sinon --dry-run=client
kubectl kustomize overlays/<env>
helm lint <chart> && helm template <chart> -f values-<env>.yaml
kubeconform -strict <fichiers>                   # si installé
kube-linter lint <dossier>                       # si installé
trivy config <dossier>                           # si installé
```

### Déboguer

```bash
kubectl get pods -n <ns> -o wide
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns> [-c <conteneur>] [--previous]
kubectl get events -n <ns> --sort-by=.lastTimestamp
kubectl auth can-i <verbe> <ressource> -n <ns> --as=system:serviceaccount:<ns>:<sa>
```

| État | Piste |
| :-- | :-- |
| `ImagePullBackOff` | tag, secret de registre |
| `CrashLoopBackOff` | `logs --previous` |
| `Pending` | requests trop grandes, taints, volume |
| `OOMKilled` | limite mémoire |
| Service sans trafic | sélecteur qui ne correspond à aucun label, probe en échec |
