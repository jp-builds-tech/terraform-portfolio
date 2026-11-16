# Architecture

Two projects, one repo. Both run entirely on a laptop, so they cost nothing.

## k8s-platform: a Kubernetes platform built only with Terraform

```mermaid
flowchart TB
  up["scripts/up.sh"] --> cluster
  subgraph cluster["cluster/ layer (kind provider)"]
    kind["kind cluster: 1 control-plane and 2 workers"]
  end
  cluster -->|"kubeconfig_path via terraform_remote_state"| platform
  subgraph platform["platform/ layer (kubernetes and helm providers)"]
    ns["Namespaces: traefik, dev, prod"]
    traefik["Traefik (helm_release)"]
    apps["modules/app x4: web and api in dev and prod"]
    ns --> traefik --> apps
  end
  apps --> kind
```

Why two layers: the Kubernetes and Helm providers need a cluster that already
exists, so cluster creation and in-cluster configuration are separate Terraform
roots with separate state. The platform layer reads the cluster layer's output
instead of hard-coding the kubeconfig path.

## CI: every change is checked before it reaches main

```mermaid
flowchart LR
  A["Branch and push"] --> B["Pull request"]
  B --> C["GitHub Actions"]
  C --> D["fmt and validate"]
  C --> E["tflint"]
  C --> F["terraform test"]
  C --> G["checkov"]
  D & E & F & G --> H{"All pass?"}
  H -->|"yes"| I["Merge to main"]
  H -->|"no"| J["Fix and push again"]
  J --> B
```

## aws-lab: remote state, locking and an AWS-style module (emulated)

```mermaid
flowchart TB
  subgraph docker["Docker: Moto AWS emulator on port 5000"]
    bucket["S3 bucket tf-state-lab (versioned, encrypted)"]
    locks["DynamoDB table tf-locks"]
    vpc["VPC, subnets, route table, security group"]
  end
  boot["bootstrap/ (local state)"] -->|"creates"| bucket
  boot -->|"creates"| locks
  net["network/ (calls modules/vpc)"] -->|"creates"| vpc
  net -->|"state stored in"| bucket
  net -.->|"lock"| locks
```

## Design decisions

- **Separate layers, separate state.** A cluster and the things running on it
  change at different speeds and need different providers.
- **`for_each` instead of `count`.** Items are tracked by key, so adding or removing
  one never shifts the others.
- **Environments are data, not code.** One app module serves dev and prod. Only
  the inputs differ (replicas, memory limit).
- **Guardrails in the module.** Input validation plus a precondition that stops prod
  from using a `:latest` image.
- **Pinned versions and committed lock files.** A rebuild next month installs the
  same thing.
- **Checks on every pull request.** Format, validate, lint, unit tests, security scan.
- **Moto instead of LocalStack or MinIO.** LocalStack now needs an account and MinIO
  is archived, so I used a free emulator with no sign-up.

## Known limits

- Everything is local. There is no live cloud account and no managed Kubernetes.
- The AWS code is tested against an emulator, not real AWS.
- CI reads and tests the code. It does not run `plan` or `apply`.
- The `aws-lab` security scan is a baseline. It lists findings that I would fix in
  a real account (access logging, KMS keys, flow logs, and so on) but did not fix here.
- Four `k8s-platform` checkov findings are skipped on purpose, with written reasons
  next to each one in the code.
