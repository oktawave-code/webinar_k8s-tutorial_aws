# install flux
export GITHUB_TOKEN=YOUR_TOKEN
flux check --pre
flux bootstrap github --owner=your_github_login --repository=your_infra_repository --path=clusters/k8s --personal --branch=main --components-extra=image-reflector-controller,image-automation-controller --read-write-key

# update kustomization.yaml, enable autologin to ECR
patches:
- target:
    version: v1
    group: apps
    kind: Deployment
    name: image-reflector-controller
    namespace: flux-system
  patch: |-
    - op: add
      path: /spec/template/spec/containers/0/args/-
      value: --aws-autologin-for-ecr

# reload initial flux configuration
flux reconcile kustomization flux-system --with-source

# configure flux
flux create image repository todo --image=xxx.dkr.ecr.us-east-2.amazonaws.com/imageapp --interval=1m --export > k8s/todo-registry.yaml
flux create image policy todo --image-ref=todo --select-numeric=asc --filter-regex='^[a-f0-9]+-(?P<ts>[0-9]+)' --filter-extract='$ts' --export > k8s/todo-policy.yaml
flux create image update flux-system \
--git-repo-ref=flux-system \
--git-repo-path="./clusters/k8s" \
--checkout-branch=main \
--push-branch=main \
--author-name=fluxcdbot \
--author-email=fluxcdbot@users.noreply.github.com \
--commit-template="{{range .Updated.Images}}{{println .}}{{end}}" \
--export > k8s/flux-system-automation.yaml

flux get image repository todo
