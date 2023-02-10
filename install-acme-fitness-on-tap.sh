#!/bin/bash

set -e
set -u
set -o pipefail

# base everything relative to the directory of this script file
script_dir="$(cd $(dirname "$BASH_SOURCE[0]") && pwd)"
generated_dir="${script_dir}/generated"
mkdir -p "${generated_dir}"

values_file_default="${script_dir}/profile/values.yaml"
values_file=${VALUES_FILE:-$values_file_default}

# TODO validate values file is properly populated with environment variables and jq

# generate App SSO Auth server yaml
echo "generate App SSO Auth Server yaml"
ytt -f templates/appSSOInstance.yaml -f "${values_file}" --ignore-unknown-comments > "${generated_dir}/appsso-Instance.yaml"

# generate Redis yaml
echo "generate Redis yaml"
ytt -f templates/redis.yaml -f "${values_file}" --ignore-unknown-comments > ${generated_dir}/generated-redis.yaml

# generate Spring Cloud Gateway Instance [ scg packagerepo must be installed as as pre-requisite ]
echo "generate Spring Cloud Gateway Instance"
ytt -f templates/scgInstance.yaml -f "${values_file}" --ignore-unknown-comments > ${generated_dir}/generated-scgInstance.yaml

# generate workload deployments
echo "generate workload deployments"
ytt -f templates/workloads.yaml -f "${values_file}" --ignore-unknown-comments > ${generated_dir}/generated-workloads.yaml

# generate httpProxy for ingress
echo "generate httpProxy for ingress"
ytt -f templates/ingress.yaml -f "${values_file}" --ignore-unknown-comments > ${generated_dir}/generated-ingress.yaml

# generate client registration yaml
echo "generate client registration yaml"
ytt -f templates/clientRegistrationResourceClaim.yaml -f "${values_file}" --ignore-unknown-comments > ${generated_dir}/clientreg-instance.yaml

# generate Spring Cloud Gateway Routes
echo "generate Spring Cloud Gateway Routes"
ytt -f templates/scgRoutes.yaml -f "${values_file}" --ignore-unknown-comments > ${generated_dir}/generated-scgRoutes.yaml

# kapp deployment of acme-shopping has an issue with kapp labeling, using kubectl apply instead
#export INSTALL_NAMESPACE=acme
#kapp deploy \
#  --app acme-fitness-deploy \
#  --file generated -n $INSTALL_NAMESPACE \
#  --yes

kubectl apply -f generated


