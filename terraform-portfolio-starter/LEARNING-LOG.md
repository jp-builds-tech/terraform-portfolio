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

5. Try `-var external_port=80`. Read the validation error.

- The validation error is as follows:
"external_port must be between 8000 and 8999."
- This is because validation has been defined in the external_port variable in variables.tf

6. Delete `terraform.tfstate` (copy it first), then run `plan`. What does Terraform now believe? What would `apply` do with the container that already exists? This is why state matters.

Terraform tries to create the resources because it now believes they don't exist. If the container is running, it will say the container is already in use, and fail.