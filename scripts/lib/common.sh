read_aws_account_id () {
  aws_account=$(aws sts get-caller-identity | jq -r '.Account' | tr -d '\n')
}

init_state_bucket () {
  tf_state_s3_bucket=$(echo "terraform-state-${aws_region}-${aws_account}" | awk '{print tolower($0)}')
  export tf_state_s3_bucket
  echo "Terraform state S3 bucket: ${tf_state_s3_bucket}"
  ## Note: us-east-1 does not require a `location-constraint`:
  aws s3api create-bucket --bucket "${tf_state_s3_bucket}" --region "${aws_region}" --create-bucket-configuration \
      LocationConstraint="${aws_region}" 2>/dev/null || true
  aws s3api put-bucket-versioning --bucket "${tf_state_s3_bucket}" --region "${aws_region}" --versioning-configuration Status=Enabled 2>/dev/null || true
}