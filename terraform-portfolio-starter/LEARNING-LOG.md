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