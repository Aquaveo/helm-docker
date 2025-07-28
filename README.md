Helm-Docker
===========

A simple docker image designed for uploading packaged charts to a helm repo host and deploying app from a CI/CD system.

This README file is for a pre-release version, and may not be accurate.

Helm version: *3.11.2*

Kubectl version: *1.26.3*

Versioning
----------
For the purposes of versioning, the public API is comprised of the helper utilities and the versions of `helm` and `kubectl`. 

**Therefore:**
- PATCH updates...
  - MAY update `helm` or `kubectl` by patch releases
  - MAY NOT change any arguments or outputs of helper utilities
- MINOR updates...
  - MAY add additional arguments or output to helper utilites
  - MAY add new helper utilities
  - MAY update `helm` or `kubectl` by minor or patch releases
  - MAY NOT change existing arguments *or outputs* of helper utilities
- MAJOR updates...
  - MAY remove existing helper utilities
  - MAY change existing arguments or outputs of helper utilities
  - MAY update `helm` or `kubectl` by any release

**Note:** Arguments include expected environmental variables. Outputs include exit codes.

Helper Utilities
----------------
### `check_helm_chart`
Checks to see if a helm chart has already been uploaded. If it has, it checks to make sure the local chart is the same as the remote chart. Optionally, it will upload the chart if it has not been already.

**Supports both ChartMuseum-style repositories and GitLab package repositories.**

```
Usage: check_helm_chart <path/to/chart> [--upload] [--repo-type {chartmuseum,gitlab}]

## Exit code legend
# -2: Unknown error
# -1: Missing arguments
#  0: Success (chart matches or chart is new/uploaded)
#  1: Chart doesn't match
```

#### Repository Types

##### ChartMuseum (default behavior)
```bash
# Using environment variables
export HELM_REPO_URL="https://your-chartmuseum.example.com"
export HELM_REPO_USERNAME="your-username"
export HELM_REPO_PASSWORD="your-password"
export HELM_REPO_CHANNEL="stable"

./check_helm_chart /path/to/your/chart --upload

# Using command line arguments
./check_helm_chart /path/to/your/chart \
  --repo-type chartmuseum \
  --url https://your-chartmuseum.example.com \
  --username your-username \
  --password your-password \
  --channel stable \
  --upload
```

##### GitLab Package Registry
```bash
# Using environment variables
export HELM_REPO_URL="https://gitlab.example.com"
export GITLAB_TOKEN="your-gitlab-token"
export GITLAB_PROJECT_ID="12345"
export HELM_REPO_CHANNEL="stable"

./check_helm_chart /path/to/your/chart --repo-type gitlab --upload

# Using command line arguments
./check_helm_chart /path/to/your/chart \
  --repo-type gitlab \
  --url https://gitlab.example.com \
  --token your-gitlab-token \
  --project-id 12345 \
  --channel stable \
  --upload
```

#### Arguments

- `--repo-type`: Choose between 'chartmuseum' (default) or 'gitlab'
- `--token`: GitLab access token (required for GitLab, can also use GITLAB_TOKEN env var)
- `--project-id`: GitLab project ID (required for GitLab, can also use GITLAB_PROJECT_ID env var)
- `--channel`: Channel/repository name (default: "stable")
- `--url`: Repository URL
- `--username`: Username for ChartMuseum authentication
- `--password`: Password for ChartMuseum authentication

#### Environment Variables

**ChartMuseum:**
- `HELM_REPO_URL`: URL of the Helm repository
- `HELM_REPO_USERNAME`: Username for authentication
- `HELM_REPO_PASSWORD`: Password for authentication
- `HELM_REPO_CHANNEL`: Channel/repository name (default: "stable")

**GitLab:**
- `HELM_REPO_URL`: GitLab instance URL (e.g., https://gitlab.example.com)
- `GITLAB_TOKEN`: Personal access token or project access token
- `GITLAB_PROJECT_ID`: Numeric project ID
- `HELM_REPO_CHANNEL`: Channel name (default: "stable")

#### GitLab Token Requirements

For GitLab package registry access, your token needs the following scopes:
- `read_api` (to download existing charts)
- `write_repository` (to upload new charts)

You can create a token at: `https://your-gitlab-instance.com/-/profile/personal_access_tokens`

#### Notes

- The script automatically detects chart name and version from `Chart.yaml` when using GitLab
- GitLab upload uses a different API endpoint structure than ChartMuseum
- Success codes differ between providers (GitLab: 200/201, ChartMuseum: 201)
- The script maintains backward compatibility with existing ChartMuseum workflows
 - `HELM_KEY_PASSPHRASE`: The passphrase to unlock the signing key

### `check_for_tag_in_project_registry`
Checks to see if a given tag exists in a docker registry. Fails with exit code 1 if it does not.

```
Usage: check_for_tag_in_project_registry [OPTIONS] TAG_NAME

Options:
  --api-url TEXT          Gitlab API Url (e.g.
                          https://example.com:3000/api/v4)  [required]
  --token TEXT            Gitlab API Token  [required]
  --project-id INTEGER    Gitlab Project ID  [required]
  --repository-name TEXT  Gitlab Registry Repository Name Type: Regex
                          [default: .*]
  --help                  Show this message and exit.
```

Most of the options may also be specified by environmental variables. Most follow the naming conventions for variables that are automatically defined in gitlab-CI:
- `--api_url`: `CI_API_V4_URL`
- `--token`: `GRC_TOKEN`
- `--project-id`: `CI_PROJECT_ID`
- `--repository-name`: `GITLAB_REPOSITORY_NAME`

### `helm-fresh-deploy`
Purge a helm deployment and redeploy it.

```
usage: helm-fresh-deploy [-h] [-f VALUES_FILE] [-n NAMESPACE] [--no-deps]
                         [--max-pvc-checks MAX_PVC_CHECKS]
                         name chart

positional arguments:
  name                  The name of the deployment to refresh.
  chart                 The chart to deploy

optional arguments:
  -h, --help            show this help message and exit
  -f VALUES_FILE, --values-file VALUES_FILE
                        The path to a yaml file to read values from.
  -n NAMESPACE, --namespace NAMESPACE
                        The deployment's namespace.
  --no-deps             Don't update dependencies.
  --max-pvc-checks MAX_PVC_CHECKS
                        Maximum number of times to check if all pvc's were
                        deleted
```
