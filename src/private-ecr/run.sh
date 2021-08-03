#!/bin/bash
set -euo pipefail

source "./../../scripts/lib/common.sh"

aws_region="ap-northeast-1"

read_aws_account_id
init_state_bucket

function init_ecr_env() {
  source ".ecr.env"
  tf_working_dir="./terraform/ecr"
}

function init_apprunner_env() {
  source ".apprunner.env"
  tf_working_dir="./terraform/apprunner"
}

function apply_ecr() {
  init_ecr_env

  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" apply -auto-approve \
  -var="region=${aws_region}" \
  -var="creat_github_iam=${creat_github_iam}" \
  -var="ecr_repo_name=${ecr_repo_name}"

  ecr_repo_url=$(terraform -chdir="${tf_working_dir}" output -raw ecr_repo_url)
  echo "region=${aws_region}
ecr_repo_url=\"${ecr_repo_url}\"" > ".apprunner.env"

  printf "\n"
  printf "After pushing first container image to ECR, run 'run.sh apply_app_runner' to deploy to AppRunner.\n\n"
}

function apply_app_runner() {
  init_apprunner_env

  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" apply -auto-approve \
  -var="region=${aws_region}" \
  -var="ecr_repo_url=${ecr_repo_url}"
}

function destroy_app_runner() {
  echo  ""
}

function destroy_ecr() {
  source ".ecr.env"
  tf_working_dir="./terraform/ecr"

  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" destroy -auto-approve \
  -var="region=${aws_region}" \
  -var="creat_github_iam=${creat_github_iam}" \
  -var="ecr_repo_name=${ecr_repo_name}"
}


function apply() {
  echo  ""
}

function destroy() {
  echo  ""
}

function show_iam() {
  source ".ecr.env"
  tf_working_dir="./terraform/ecr"

  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" output -json
}

help() {
  printf "./scripts/1-ecr-public-example.sh <command>:\n"
  printf "-\n"
  printf "<command> values:\n"
  printf "  apply:              Apply terraform\n"
  printf "  destroy:            Apply terraform\n"
  printf "  apply_ecr:          Apply terraform\n"
  printf "  apply_app_runner:   Apply terraform\n"
  printf "  destroy_ecr:        Apply terraform\n"
  printf "  destroy_app_runner: Apply terraform\n"
}

case ${1-apply} in
  "destroy")
    destroy
  ;;

  "apply")
    apply_ecr
  ;;

  "apply_ecr")
    apply_ecr
  ;;

  "apply_app_runner")
    apply_app_runner
  ;;

  "show_iam")
    show_iam
  ;;

  *)
    help
  ;;
esac