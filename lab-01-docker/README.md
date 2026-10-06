# Lab 01: First Terraform config (Docker)

Runs an nginx container with Terraform.

## Run it
```
cd lab-01-docker
terraform init       # downloads the docker provider
terraform fmt        # canonical formatting
terraform validate   # syntax and consistency check
terraform plan       # preview
terraform apply      # type "yes"
```
Open http://localhost:8080. Then:
```
terraform output
docker ps
terraform destroy
```

## Experiments (do these; this is the learning)
1. Change `external_port` with `-var external_port=8081`, then run `plan`. Is it an in-place update or a replacement? Why?
2. Change `nginx_tag` to another tag. What does `plan` want to do?
3. Run `terraform apply`, then `docker rm -f lab01-web`, then `terraform plan`. What does Terraform think happened?
4. Run `terraform state list` and `terraform state show docker_container.web`. Compare to `terraform.tfstate` in a text editor.
5. Try `-var external_port=80`. Read the validation error.
6. Delete `terraform.tfstate` (copy it first), then run `plan`. What does Terraform now believe? What would `apply` do with the container that already exists? This is why state matters.
7. Add a second container using `count = 3`, then `for_each`. Remove the middle one under each and compare the plans.

## Check yourself (answer out loud without notes)
- What are the three things `plan` compares?
- What is in state, and why is it not just a cache?
- What did `init` create, and what should be committed to Git?
- Why is `.terraform.lock.hcl` committed but `terraform.tfstate` is not?

Write the answers and anything that surprised you in LEARNING-LOG.md.
