#!/bin/bash
set -euo pipefail

source "./scripts/lib/common.sh"

aws_region="ap-northeast-1"
github_connection_arn="arn:aws:apprunner:ap-northeast-1:685501949732:connection/github/c06d5437ad304d35933f992449318b10"
github_code_repo_url="https://github.com/hieule-labs/hello-app-runner"

read_aws_account_id
init_state_bucket

printf "%s" "${tf_state_s3_bucket}"

tf_working_dir="./src/code"
terraform -chdir="${tf_working_dir}" init \
-migrate-state \
-backend-config="region=${aws_region}" \
-backend-config="bucket=${tf_state_s3_bucket}" \
&& \
terraform -chdir="${tf_working_dir}" apply -auto-approve \
-var="region=${aws_region}" \
-var="github_connection_arn=${github_connection_arn}" \
-var="github_code_repo_url=${github_code_repo_url}" \
