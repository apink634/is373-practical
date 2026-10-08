# IS 373 Practical Test: QA and Production Deployment

- **Production:** https://anncarlos.me
- **QA:** https://qa.anncarlos.me

A simple containerized website deployed to my own DigitalOcean Droplet with GitHub Actions.

## How it works

| Branch | Environment | URL |
|---|---|---|
| `qa` | QA | https://qa.anncarlos.me |
| `main` | Production | https://anncarlos.me |

**Promotion rule:** every change is pushed to the `qa` branch first and checked on the QA site. When it looks right, I merge `qa` into `main` (pull request), which deploys it to production. QA and production run as separate containers with separate hostnames, so a QA change does not touch production until it is promoted.

**Repository layout**

- `site/` website source (static HTML)
- `Dockerfile` builds the nginx-based image
- `compose.yaml` deployment configuration (Traefik routing labels, per environment)
- `.github/workflows/deploy.yml` the CI/CD pipeline
- `scripts/test.sh` validation run by CI

## Test Evidence

> Fill each item in with real links, screenshots, and redacted output before submitting.

### Workflow runs, registry, and deployed version

- QA workflow run: _link_
- Production workflow run: _link_
- Image registry: https://hub.docker.com/r/apink634/is373-site
- Deployed image tag / commit (QA): _tag_
- Deployed image tag / commit (production): _tag_

### The visible change

_Screenshot of the change on QA, then the same change on production._

### SSH security

_Redacted output showing:_

1. _Key login as the new non-root user (`ssh deploy@...`)._
2. _Effective settings: `sudo sshd -T | grep -Ei "permitrootlogin|passwordauthentication|kbdinteractiveauthentication"`._
3. _Root login rejected, and password login rejected._

### How the pipeline works

CI runs on every push to the `qa` or `main` branch. First, `scripts/test.sh` checks the site files exist and contain the expected markers, builds the Docker image, starts it, and requests the page; if anything fails, the workflow stops and nothing is deployed. Next, the image is built with the environment name and commit SHA baked in and pushed to Docker Hub, tagged with the commit and the environment. Finally, the deploy job connects to the server over SSH with a dedicated deploy key, copies `compose.yaml`, and runs `docker compose pull` and `up -d` in a per-environment folder. Traefik, already running on the server, routes `qa.anncarlos.me` and `anncarlos.me` to their own containers and handles HTTPS certificates. The last step requests the live site and fails unless it is serving the commit that was just deployed.

All credentials (Docker Hub token, SSH key, server address) are stored in GitHub Actions secrets, not in this repository.
