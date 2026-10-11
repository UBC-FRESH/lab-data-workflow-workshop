# DataLad + S3 special remote (Arbutus compatible)

This sets up **S3 as a git‑annex special remote** for file content, while the Git repo
lives on GitHub. This is the recommended pattern for reproducible data.

## Prereqs

- `datalad` and `git‑annex` installed
- `datalad-next` installed (`pip install datalad-next`)
- `AWS_*` env vars exported **or** credentials configured via `aws configure`

### 0) Switch to main git branch and create a new feature branch

```bash
# From the repo root
git status --porcelain

# If you see untracked files under demo_dataset/, move them aside (safest)
if [ -d demo_dataset ]; then
  mv demo_dataset "_demo_dataset_local_$(date +%Y%m%d%H%M%S)"
  echo "Moved demo_dataset/ aside; continuing…"
fi

# (Alternative 1) If you prefer to stash untracked stuff instead of moving:
# git stash push -u -m "pre-Workflow3: move to main"

# (Alternative 2) If you’re sure it’s disposable, delete untracked files:
# git clean -fd demo_dataset

# Now it’s safe to switch and start the new branch
git switch main
git pull --ff-only
git switch -c feature/git-datalad-s3-workflow

# sanity
git status
git branch -vv
```

### 1) Initialize DataLad repo as a subdataset and save (anologous to git commit)

First, we undo git tracking of the `demo_dataset` subdirectory (only applies to this branch) so we 
track it as a DataLad subdataset of the parent repo instead.

```bash
git rm -r --cached demo_dataset
git commit -m "Untrack demo_dataset in parent (retry for subdataset)"
```

Now that the `demo_dataset` is untracked, we can use the `datalad create` command to initialize it
as a DataLad dataset.

```bash
datalad create -d . --force -c text2git demo_dataset
```

Run a recursive `datalad save` command, which both initializes the `demo_data` subdataset and registers the subdataset in the parent repo.

```bash
datalad save -r -m "Initialize subdataset with existing content and register in parent"
```

## 2) Generate some fresh output and save the current state

```bash
cd demo_dataset
datalad run -m "process data v1" "python3 code/process_data.py --input data/input.csv --out outputs/processed.csv"
datalad status
```

## 3) Create S3 special remote

Replace placeholders with your values:

```bash
ORIGIN="origin"
REMOTE="arbutus-s3"
BUCKET="${S3_BUCKET_NAME}"         # export via setup/s3_config.sh
ENDPOINT="${S3_ENDPOINT_URL}"      # export via setup/s3_config.sh
REGION="${AWS_DEFAULT_REGION}"     # export via setup/s3_config.sh

REPO_NAME="${GITHUB_REPO_NAME_S3}"
GH_URL="https://github.com/${GH_OWNER}/${REPO_NAME}.git"

# Create an annex special remote using datalad-next (wraps git-annex initremote)
git annex initremote "$REMOTE" \
  type=S3 \
  encryption=none \
  bucket="$BUCKET" \
  host="${ENDPOINT}" \
  public=yes \
  publicurl="$ENDPOINT/$BUCKET" \
  host=object-arbutus.alliancecan.ca \
  protocol=https \
  requeststyle=path \
  autoenable=true

# Create a GitHub repo in the GitHub organization (or user account) you set in setup/s3_config.sh and wire it up as 'origin'
datalad create-sibling-github -d . \
  --github-organization "$ORG" \
  --name origin \
  --publish-depends "$REMOTE" \
  "$REPO_NAME"

# verify siblings
datalad siblings
```

> Notes:
> - Some endpoints require `host` without scheme. If init fails, try `host=${ENDPOINT#*://}` to drop `https://`.
> - You can also use `datalad create-sibling-s3` as a higher‑level wrapper when appropriate.

## 4) Push content to S3

```bash
# Ensure GitHub remote 'origin' exists for the Git history (code & metadata).
git remote -v

# push Git history to GitHub, annex files automatically pushed to S3 sibling due to publish-depends
datalad push --to "$ORIGIN"
cd ..
```

## 5) Add your new DataLad repo back into the workshop parent git repo as a git submodule

```bash
# set remote GitHub repo URL property on DataLad subdataset (the same one we just created) 
datalad subdatasets --set-property url $GH_URL demo_dataset
datalad save -m "Register subdataset GitHub URL for portable clones"

# push the parent repo change
datalad push --to origin
```

## 6) Test on a fresh clone

- Clone your forked repo from GitHub (*not* from S3).
- Run a recursive datalad get command to pull everything down from the cloud (will know to download from the Arbutus S3 bucket if we configured the DataLad special remote correctly). 
- Inside the parent repo root directory, fetch file content on demand:

```bash
datalad get -n -r .
```

If content is available in S3, this will retrieve it via the special remote.

## Troubleshooting

- If initremote complains about `host`, try removing the scheme or specifying `export AWS_S3_ENDPOINT` alternatives supported by git-annex.
- Ensure credentials are visible to the process (`env | grep AWS`).
- If large files accidentally landed in Git, move them to annex (`git annex add` then `git rm --cached`).
