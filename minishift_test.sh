#!/bin/bash

results_dir="results"
# Logging colors
LIGHT_GREEN='\033[1;32m'
GREEN='\033[0;32m'
CLEAR='\033[0m'

echo -e "${CLEAR}${LIGHT_GREEN}Starting up minishift...${CLEAR}"
minishift start
oc login -u system:admin

echo -e "${CLEAR}${LIGHT_GREEN}Setting up prerequisites...${CLEAR}"
export RBAC_ENABLED=$(kubectl api-versions | grep "rbac.authorization.k8s.io/v1" -c)
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:heptio-sonobuoy:sonobuoy-serviceaccount

echo -e "${CLEAR}${LIGHT_GREEN}Defining test fixture (cluster settings)...${CLEAR}"
oc create -f <(echo -e "
{
    \"kind\": \"OAuthClient\",
    \"apiVersion\": \"v1\",
    \"metadata\": {
    \"name\": \"openshift-io\"
    },
    \"secret\": \"1234\",
    \"grantMethod\": \"prompt\",
    \"redirectURIs\": [
        \"https://sso.openshift.io\"
    ]
}")

echo -e "${CLEAR}${LIGHT_GREEN}Executes sonobuoy tests...${CLEAR}"
kubectl apply -f osio.yaml

echo -e "${CLEAR}${LIGHT_GREEN}Waits until execution is finished...${CLEAR}"
until kubectl get pods --all-namespaces | grep sonobuoy |  tr -s '[:space:]' | cut -d' ' -f4 | grep -m 1 'Running'; do : ; done
grep -q 'no-exit was specified, sonobuoy is now blocking' <(kubectl logs -f sonobuoy --namespace=heptio-sonobuoy)

echo -e "${CLEAR}${LIGHT_GREEN}Export results to ${PWD}/${results_dir}...${CLEAR}"
kubectl cp heptio-sonobuoy/sonobuoy:/tmp/sonobuoy ./${results_dir} --namespace=heptio-sonobuoy

minishift stop
echo -e "${CLEAR}${GREEN}Done!${CLEAR}"