# Learning Log

## Day 0
- Tested terraform init, plan, apply, and destroy using a predefined template (lab-01-docker)
- Watched a quick guide on Terraform

## Day 1
- Recreated the previous day's lab by referencing terraform's documentation. 
- Main issues encountered were referencing the resources named using improper syntax, rectified by utilizing proper syntax.
- Most of the time was spent looking up proper syntax and formatting.
- Checked provider docs and chose a current version constraigt, noting that nginx:latest is a floating tag.

Experiments:

1. Change `external_port` with `-var external_port=8081`, then run `plan`. Is it an in-place update or a replacement? Why?

- This is not an in-place update because the configuration of the docker container has been changed. So Docker has to destroy the old container (on 8080) and create a new one (on 8081)

2. Change `nginx_tag` to another tag. What does `plan` want to do?

- The docker_image resource changes, and the container references that image, so it also has to be replaced.

3. Run `terraform apply`, then `docker rm -f lab01-web`, then `terraform plan`. What does Terraform think happened?

- This appears to be testing drift. The terraform plan would notice the difference and plan to create the container again.

4. Run `terraform state list` and `terraform state show docker_container.web`. Compare to `terraform.tfstate` in a text editor.

- Running terraform state show appears to be the human-friendly version of terraform.tfstate (JSON).
- Research indidcates that manually editing terraform.tfstate is a terrible idea.
gi
5. Try `-var external_port=80`. Read the validation error.

- The validation error is as follows:
"external_port must be between 8000 and 8999."
- This is because validation has been defined in the external_port variable in variables.tf

6. Delete `terraform.tfstate` (copy it first), then run `plan`. What does Terraform now believe? What would `apply` do with the container that already exists? This is why state matters.

- Terraform tries to create the resources because it now believes they don't exist. If the container is running, it will say the container is already in use, and fail.

## Day 2

- Created `count` and `foreach` loops
- As a test, removed the middle container in both loops. 
    - For the `count`, web-b took on port 8082 and web-c was gone from the config.
    - For the `for_each`, web-b was missing, and port 8082 was not used. web-c continued to use port 8083 as expected.
    - A recap: With count, an item's identity is its position in the list, so removing one shifts everything after it. For the for_each, an item's identity is its name, so removing one affects only that item.
    - `for_each` is typically used when resources have a meaningful identity, whereas `count` is useful when the resources are interchangeable. For example, if you have EC2 instances with different roles (API, database, container), using for_each lets Terraform track each instance by its role. Modifying the map won't cause Terraform to confuse one server with another.
- Tested interactive expressions through `terraform console`.
- Compared the different kinds of data types (simple, collections, and structured)

## Day 3

- Learned that drift occurs when the actual infrastructure differs from what Terraform expects based on its configuration and state.
    - When I manually deleted web-a using docker rm -f web-a, Terraform detected that the container was missing and planned to recreate it.
    - When I renamed web-b outside Terraform, Terraform detected the difference between the actual container name and the configured name.
    - The Docker provider requires replacement when the configured container name changes, so Terraform planned to replace the renamed container.
- Understood how you can force resource replacement using `terraform apply -replace`. Useful if a resource isn't working as expected but Terraform believe it's running.
- `terraform plan -refresh-only` previews changes to state so it reflects the infrastructure as it currently exists.
- `terraform apply -refresh-only` saves those refreshes observations to state without applying normal infrastructure changes.
- State exists so Terraform can determine which resources it already manages, detect changes, calculate plans, and know what to update, replace, or destroy.
- State is sensitive because it can contain passwords, tokens, connection details, and other confidential values, depending on the resources and providers I use. Marking a value as sensitive in Terraform controls how it is displayed, but does not automatically prevent it from being stored in state.

## Day 4

- Set up modules to simulate shared configurations across different environments (dev and prod)
- Changed a resource address without recreating any of the infrastructure using `moved`.
- If I wanted to move 200 hand-built resources under Terraform, I would need to:
    1. Inventory exisiting infrastructure.
    2. Prioritize low-risk, independent resources for the migration.
    3. Write the Terraform configuration to reflect exisiting infrastructure.
    4. Import these resources in small batches. Verify before each import.
    5. Review `terraform plan` and adjust the configuration until Terraform proposes nop unintended changes, especially no unexpected replacement or destruction.
    6. Back up state securely and restrict access. Keep it out of version control.
    7. Stop manual changes after import is complete.
    8. Introduce CI/CD and monitoring to prevent drift.

## Day 5

Kubernetes basics (kind cluster)

### What I did
- Created a 3-node practice cluster with kind (1 control plane, 2 workers):
  `kind create cluster --name practice --config kind-practice.yaml`.
- Checked it with `kubectl get nodes`. The workers showed `NotReady` at first and
  became `Ready` once the cluster's networking pods (kindnet, kube-proxy) started.
- Created a Deployment with 3 replicas; deleted a pod and watched it get replaced.
- Scaled the Deployment up and down with `kubectl scale`.
- Traced the chain Deployment -> ReplicaSet -> Pods and saw which nodes the pods landed on.
- Used `kubectl explain` and `-o yaml` to see the fields and what Kubernetes stored.
- Created `dev` and `prod` namespaces, deployed the same app to both, and
  switched the default namespace with `set-context`.

### What I learned
- Kubernetes keeps desired state (e.g., "run 3 copies of this app") and controllers
  continuously make reality match it. Similar idea to Terraform, but continuous.
- A cluster is a set of nodes. The control plane is the brain (API server, etcd,
  scheduler, controller manager). Workers run the apps, via the kubelet on each node.
- kind runs each node as a Docker container, so the 3 "servers" are 3 containers
  in Docker Desktop (containers inside containers). The node names come from
  `--name`: `<name>-control-plane`, `<name>-worker`, `<name>-worker2`.
- `kubectl` reads `~/.kube/config`, which stores clusters and contexts. My
  context is `kind-practice`. Delete clusters with `kind delete cluster`, not by
  removing containers.
- Discovered the difference between running a pod imperatively (eg., `kubectl run web --image=nginx:1.27-alpine`) vs declaratively (eg., as seen in `lab-05-k8s-basics/pod.yaml`)
- Learned a bare pod isn't recreated after deletion.

Takeaway: Kubernetes continuously reconciles actual state toward desired state;
Deployments give me self-healing and scaling that bare pods don't.

## Day 6

Focused on Kubernetes, particularly ConfigMaps, Secrets, Services, and DNS

- Recreated the kind cluster with extra port mappings (host 8080/8443 -> node 80/443)
  and an `ingress-ready` label on the control-plane node (port mappings can only be
  set at cluster creation).
- ConfigMap: mounted as a file (index.html) and as an env var; edited the ConfigMap
  and saw the mounted file update, but the env var needed
  `kubectl rollout restart`.
- Secret: created with `kubectl create secret generic`, decoded it with `base64 -d`,
  injected it as an env var. Learned secrets are base64-encoded, not encrypted.
- Service: ClusterIP reached via `port-forward`, looked at endpoints, LoadBalancer
  stayed `<pending>` on kind because there's no cloud provider.
- DNS: from a busybox debug pod, resolved `app1` and `app1.default.svc.cluster.local`
- Break/fix, selector mismatch:
  - Symptom: Service had no endpoints, requests failed.
  - Diagnosis: `kubectl get endpoints` showed `<none>`; `describe svc` and
    `get pods --show-labels` showed the selector didn't match the pod labels.
  - Root cause: Service selector `app: app11` vs pod label `app: app1`.
  - Fix: corrected the selector.
- Ingress: installed Traefik with Helm, created an Ingress routing
  app1.localtest.me and app2.localtest.me to two services.

  ## Day 7

  Reliability: probes, limits, rollouts, autoscaling, break/fix

- Built a baseline deployment (3 replicas) with readiness and liveness probes
  and CPU/memory requests and limits
- Readiness controls whether a pod receives traffic (removed from endpoints
  when failing), controls restarts, requests drive scheduling. Limits are
  the ceiling (memory over limit = killed, CPU over limit = throttled)
- Rolling updates: updated the image, watched `rollout status`, checked
  `rollout history`, pushed a bad image tag and saw the rollout stall while old
  pods kept serving, recovered with `rollout undo`. maxSurge/maxUnavailable
  default to 25%.

### Break/fix write-ups
1. **Failing readiness probe**
   - Symptom: new pod `0/1 Running`, rollout stalled
   - Diagnosis: `describe pod` events: readiness probe failed with 404;
     `get endpoints` showed only old pods
   - Root cause: probe path `/nope` doesn't exist
   - Fix: restored the path / `rollout undo`
2. **Failing liveness probe**
   - Symptom: RESTARTS count climbing
   - Diagnosis: events: liveness probe failed, container will be restarted
   - Root cause: liveness probe path `/nope` returned 404, so Kubernetes kept
     restarting a healthy container
   - Fix: restored the probe path
3. **OOMKilled**
   - Symptom: pod bouncing between OOMKilled and CrashLoopBackOff
   - Diagnosis: `describe pod`: Last State Terminated, Reason OOMKilled, exit code 137
   - Root cause: the process tried to use 250 MB but the memory limit was 100 MiB
   - Fix: raised the limit (or lowered the memory the process uses)
4. **Pending**
   - Symptom: pod stuck in Pending
   - Diagnosis: events: `0/3 nodes are available: Insufficient cpu`
   - Root cause: requested 100 CPUs, and no node could satisfy it
   - Fix: deleted the pod and recreated it with a realistic request
5. **ImagePullBackOff**
   - Symptom: ErrImagePull, then ImagePullBackOff
   - Diagnosis: `describe pod` events: image tag not found
   - Root cause: the tag `nginx:doesnotexist` doesn't exist
   - Fix: deleted the pod and recreated it with a real tag
6. **CrashLoopBackOff**
   - Symptom: pod restarting repeatedly with growing delay
   - Diagnosis: `logs --previous` showed "starting"; `describe` showed exit code 1
   - Root cause: the container command exits with an error right after starting
   - Fix: corrected the command (or removed the `exit 1`)

In general, most failures are diagnosed with three commands: `kubectl get pods`,
`kubectl describe pod` (read the Events), and `kubectl logs --previous`.