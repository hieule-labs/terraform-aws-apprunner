#!/bin/bash
set -euo pipefail

source "./scripts/lib/common.sh"

aws_region="ap-northeast-1"
ecr_image="public.ecr.aws/aws-containers/hello-app-runner:latest"

read_aws_account_id
init_state_bucket

tf_working_dir="./src/ecr-public"

apply() {
  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" apply -auto-approve \
  -var="region=${aws_region}" \
  -var="ecr_image=${ecr_image}"
}

destroy() {
  terraform -chdir="${tf_working_dir}" init \
  -migrate-state \
  -backend-config="region=${aws_region}" \
  -backend-config="bucket=${tf_state_s3_bucket}" \
  && \
  terraform -chdir="${tf_working_dir}" destroy -auto-approve \
  -var="region=${aws_region}" \
  -var="ecr_image=${ecr_image}"
}

help() {
  printf "./scripts/1-ecr-public-example.sh <apply|destroy>\n"
}

case ${1-apply} in
  "destroy")
    destroy
  ;;

  "apply")
    apply
  ;;

  *)
    help
  ;;
esac