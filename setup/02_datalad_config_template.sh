#!/usr/bin/env bash
# Copy this to datalad_config.sh and fill in, edit to add missing AWS access key ID and secret access key, 
# and then `source setup/datalad_config.sh`.
# Do NOT commit it--root .gitignore configured to ignore that filename so should be safe[ish] from commit).

export AWS_ACCESS_KEY_ID="YOUR_KEY_ID"                                  # from output of `openstack ec2 credentials create`, or provided by Arbutus project admininstrator
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"                          # from output of `openstack ec2 credentials create`, or provided by Arbutus project admininstrator
export AWS_DEFAULT_REGION="ca-west-1"                                   # do not modify this unless you are sure that you know what you are doing
export S3_ENDPOINT_URL="https://object-arbutus.alliancecan.ca"  # do not modify this unless you are sure that you know what you are doing
export S3_BUCKET_NAME="UNIQUE_BUCKET_NAME"                              # bucket name must be unique within endpoint namespace
# export GITHUB_ORGANIZATION="YOUR_GITHUB_ORGANIZATION"                 # do not set this if you forked into your personal GitHub account
export GITHUB_REPO_NAME_LOCAL="UNIQUE_REPO_NAME"                        # repo name must be unique within the GitHub organization namespace
export GITHUB_REPO_NAME_S3="UNIQUE_REPO_NAME"                           # repo name must be unique within the GitHub organization namespace
export GITHUB_REPO_NAME_GIN="UNIQUE_REPO_NAME"                          # repo name must be unique within the GitHub organization namespace
export DATALAD_GITHUB_TOKEN="YOUR_GITHUB_PAT"                           # GitHub account > Settings > Developer Settings > Personal Access Tokens
export DATALAD_GIN_PAT="YOUR_GIN_PAT"                                   # GIN account > Settings > Applications
export GIN_USERNAME="YOUR_GIN_USERNAME"                                 # Your GIN user name

# For awscli and libraries honoring AWS_* variables:
export AWS_EC2_METADATA_DISABLED=true

echo "[*] Exported AWS env vars for this shell."
echo "    Reminder: do not commit this file."
