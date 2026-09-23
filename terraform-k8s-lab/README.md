# Terraform: Full automated deployment guide

This folder provisions a single EC2 instance that boots and provisions itself to host a local `kind` cluster and run this application. The instance will automatically install Docker, kubectl, kubelet (on Debian/Ubuntu), kind, and the AWS CLI via `install-all.sh` injected as `user_data`.

This README explains the end-to-end flow you should follow to deploy the app with zero manual provisioning on the server.

## Prerequisites (local laptop)

- An AWS account and permissions to create VPCs, subnets, and EC2 instances.
- `terraform` (>= 1.6) installed locally.
- `aws` CLI configured locally (for Terraform remote calls) or environment credentials.
- A Docker Hub account (for CI image pushes).
- A GitHub repository fork of this project.
- An existing SSH keypair in the target AWS region (create in the console or with `aws ec2 create-key-pair`).

## Quick deploy (one-shot)

1. Fork and clone this repo locally.
2. Ensure your `aws` CLI is configured with credentials that Terraform will use.
3. Edit `env/dev/variables.tf` if you want to change defaults (region, instance_type, key_name).
4. From the repo root:

```bash
# Terraform — Step-by-step deployment

This folder provisions a single EC2 instance that self-installs Docker, kubectl, kubelet, kind, and the AWS CLI. The instance is intended to host a local `kind` cluster and run the SkillPulse app.

Quick overview
- Terraform creates VPC, subnet, security group, and an EC2 instance.
- `install-all.sh` is injected as `user_data` and runs on first boot to prepare the node.
- CI builds images and pushes to Docker Hub. CD can SSH into the EC2 to deploy.

Prerequisites (local)
- AWS credentials configured (`aws` CLI).
- `terraform` >= 1.6 installed.
- Docker Hub account for CI image pushes.
- Your private PEM file for the keypair named in `env/dev/variables.tf` (default `eks8_key`).

Step 1 — Prepare repository secrets
1. Open your fork on GitHub → Settings → Secrets and variables → Actions.
2. Add these secrets (values kept private):
   - `DOCKERHUB_USERNAME` (your Docker Hub username)
   - `DOCKERHUB_TOKEN` (Docker Hub personal access token)
   - `EC2_SSH_KEY` — paste the full PEM contents (including `-----BEGIN`/`-----END` and newlines)
   - `EC2_USER` — SSH user for the instance (example: `ubuntu`)
3. Add repository variable `DEPLOY_ENABLED = true` to enable CI pushes and CD.

Step 2 — Secure SSH access
1. Find your public IP (on your laptop):
   ```bash
   curl -s https://checkip.amazonaws.com
   ```
2. Restrict SSH by passing `ssh_cidr` when applying, e.g.:
   ```bash
   terraform apply -var="ssh_cidr=1.2.3.4/32" -auto-approve
   ```

Step 3 — Create resources with Terraform
1. From the repo root:
   ```bash
   cd terraform-k8s-lab/env/dev
   terraform init
   terraform apply -auto-approve
   ```
2. After apply completes, get the instance public IP and set `EC2_HOST` as a GitHub secret. Example:
   ```bash
   aws ec2 describe-instances --filters "Name=tag:Name,Values=k8s-master" --query "Reservations[].Instances[].PublicIpAddress" --output text
   ```

Step 4 — Verify the instance
1. Check the installer logs on the instance (if you SSH manually):
   ```bash
   sudo cat /var/log/install-all.log
   ```
2. Confirm `docker`, `kubectl`, and `kind` are installed:
   ```bash
   docker --version
   kubectl version --client --short
   kind version
   ```

Step 5 — CI/CD workflow
- Push to `main`: `.github/workflows/ci.yml` builds backend+frontend and pushes images to Docker Hub (requires `DOCKERHUB_*` and `DEPLOY_ENABLED`).
- On CI success, `.github/workflows/cd-k8s.yml` pins `k8s` manifests to the SHA and commits back to `main`.
- `.github/workflows/cd.yml` SSHes into the EC2 and runs the repo's deploy commands (no changes required if `EC2_SSH_KEY`, `EC2_HOST`, and `EC2_USER` are set).

Optional: fully automate deploy on EC2
- To have Actions run the full `make up` on the EC2 (create kind + load images + apply), update `.github/workflows/cd.yml` to run `make up` instead of `docker compose up`.

Troubleshooting
- If CI isn't pushing: verify `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, and `DEPLOY_ENABLED`.
- If SSH from Actions fails: ensure `EC2_SSH_KEY` contains the PEM text, `EC2_HOST` is correct, and `ssh_cidr` allows your IP.
- If provisioning fails: check `/var/log/cloud-init-output.log` and `/var/log/install-all.log`.

Security reminder
- Never commit PEMs or tokens to the repo or README. Rotate any credential that was exposed.

Commands reference (copiable)
```bash
# Apply terraform
cd terraform-k8s-lab/env/dev
terraform init
terraform apply -auto-approve

# Get instance public IP (by tag)
aws ec2 describe-instances --filters "Name=tag:Name,Values=k8s-master" --query "Reservations[].Instances[].PublicIpAddress" --output text

# Test SSH locally
ssh -i /path/to/eks8_key.pem ubuntu@<EC2_PUBLIC_IP>

# Use Makefile to create/load/apply on the instance (if running on the instance)
make up
```

If you want, I can also update `.github/workflows/cd.yml` to run `make up` on the EC2 for a fully hands-off deploy. 
- `CD (kind)` (.github/workflows/cd-k8s.yml): pins the Kubernetes manifests in `k8s/` to the CI SHA and commits back to `main`. The actual `kubectl apply` is intended to be run on the EC2 (or your laptop) after pulling this change.

## Recommended fully automated flow (no manual server steps)

1. Run Terraform as shown in Quick deploy to create the EC2. The instance will self-provision via `install-all.sh`.
2. Push a commit to `main`. `CI` will build images and push them to Docker Hub.
3. `CD (kind)` will update the `k8s` manifests to pin images to the new SHA and push that commit.
4. The EC2 (already provisioned) can run `make apply` or `make up` to load images and apply manifests. To fully automate step 4, update `.github/workflows/cd.yml` to SSH and run `make up` on the EC2 instead of `docker compose up`.

## Commands you'll use on the EC2 (if you SSH manually)

```bash
# Check installer logs
sudo cat /var/log/install-all.log

# Clone or update the repo
git clone https://github.com/<you>/<repo>.git ~/skillpulse || true
cd ~/skillpulse
git pull origin main

# Use the project's Makefile to create/load/apply
make up        # builds (if Docker present), creates kind, loads images, applies k8s manifests
make apply     # just apply manifests + wait for rollouts
make restart   # rebuild + reload + rollout restart
```

## Notes on credentials and security

- Recommended: attach an IAM Instance Profile (role) to the EC2 with the minimal permissions the instance needs (e.g., S3 or ECR access). This avoids storing AWS keys on the instance.
- If you must provide keys, use AWS Systems Manager Parameter Store or GitHub Secrets, then retrieve them securely from the EC2 at runtime instead of embedding them into `user_data`.

## Troubleshooting

- If CI doesn't push images: verify `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` are set and `DEPLOY_ENABLED` is `true`.
- If the EC2 didn't provision correctly: view `/var/log/cloud-init-output.log` and `/var/log/install-all.log` on the instance.
- If `make up` fails on the EC2: ensure Docker is running (`sudo systemctl status docker`) and that the `kind` binary was installed successfully (`kind version`).

## Optional next steps I can implement for you

- Attach an IAM role / instance profile in the `ec2` Terraform module and grant ECR/SSM/S3 permissions.
- Update `.github/workflows/cd.yml` to SSH into the EC2 and run `make up` (fully automates deploy to the EC2-hosted kind cluster).
- Add a sample `terraform.tfvars` or variable prompt helper for `env/dev`.

If you want, I will update the `cd.yml` to run `make up` on the EC2 so deployments are completely hands-off.
