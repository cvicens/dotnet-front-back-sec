#!/bin/sh

export FRONTEND_PROJECT=dotnet-frontend
export BACKEND_PROJECT=dotnet-backend

oc apply -f deploy-frontend.yaml
oc apply -f deploy-backend.yaml

oc delete networkpolicy allow-from-all-namespaces -n ${FRONTEND_PROJECT}
oc delete networkpolicy allow-from-ingress-namespace -n ${FRONTEND_PROJECT}
oc delete networkpolicy allow-from-all-namespaces -n ${BACKEND_PROJECT}
oc delete networkpolicy allow-from-ingress-namespace -n ${BACKEND_PROJECT}

oc apply -f deploy-networkpolicies.yaml