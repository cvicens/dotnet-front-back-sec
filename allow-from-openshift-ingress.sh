#!/bin/sh
export CLIENT_PROJECT=np-client
export POLICY_NAME=allow-from-openshift-ingress
export TARGET_PROJECT=np-${POLICY_NAME}

oc new-project ${CLIENT_PROJECT}
oc new-project ${TARGET_PROJECT}

oc delete networkpolicy allow-from-all-namespaces -n ${TARGET_PROJECT}
oc delete networkpolicy allow-from-ingress-namespace -n ${TARGET_PROJECT}

oc new-app -n ${TARGET_PROJECT} \
  redhat-openjdk18-openshift:1.4~https://github.com/cvicens/wine \
  --context-dir=pairing --name pairing

kubectl wait --timeout=180s --for=condition=Available deployment/pairing -n ${TARGET_PROJECT}

oc expose svc/pairing -n ${TARGET_PROJECT}

# curl in different project
kubectl delete pod curl -n ${CLIENT_PROJECT}
kubectl run curl --image=radial/busyboxplus:curl --restart=Never -n ${CLIENT_PROJECT} -- sleep 3600
kubectl wait --for=condition=Ready pod/curl -n ${CLIENT_PROJECT}

# curl in the same project
kubectl delete pod curl -n ${TARGET_PROJECT}
kubectl run curl --image=radial/busyboxplus:curl --restart=Never -n ${TARGET_PROJECT} -- sleep 3600
kubectl wait --for=condition=Ready pod/curl -n ${TARGET_PROJECT}

printf "\nSleeping 30 secs check it's all GOOD\n\n"
sleep 30

echo "========== BEFORE APPLYING POLICY ${POLICY_NAME}"
echo "========== curl from ${CLIENT_PROJECT} ==> ${TARGET_PROJECT}"
kubectl exec curl -n ${CLIENT_PROJECT} -- curl --max-time 2 -s http://pairing.${TARGET_PROJECT}:8080/pairing?foodType=FISH && echo ""

echo "========== curl from ${TARGET_PROJECT} ==> ${TARGET_PROJECT}"
kubectl exec curl -n ${TARGET_PROJECT} -- curl --max-time 2 -s http://pairing.${TARGET_PROJECT}:8080/pairing?foodType=FISH && echo ""

echo "========== curl from INTERNET ==> ${TARGET_PROJECT}"
export TARGET_HOST=$(oc get route pairing -o jsonpath='{.status.ingress[0].host}' -n ${TARGET_PROJECT})
curl http://${TARGET_HOST}/pairing?foodType=FISH && echo ""

printf "\nSleeping 5 secs before applying the policy\n\n"
sleep 5
echo "========== APPLYING POLICY ${POLICY_NAME}"
cat <<EOF | oc apply -n ${TARGET_PROJECT} -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-openshift-ingress
spec:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          network.openshift.io/policy-group: ingress
  podSelector: {}
  policyTypes:
  - Ingress
EOF

printf "\n\n========== AFTER APPLYING POLICY ${POLICY_NAME}\n"

echo "========== curl from ${CLIENT_PROJECT} ==> ${TARGET_PROJECT}"
kubectl exec curl -n ${CLIENT_PROJECT} -- curl --max-time 2 -s http://pairing.${TARGET_PROJECT}:8080/pairing?foodType=FISH && echo ""

echo "========== curl from ${TARGET_PROJECT} ==> ${TARGET_PROJECT}"
kubectl exec curl -n ${TARGET_PROJECT} -- curl --max-time 2 -s http://pairing.${TARGET_PROJECT}:8080/pairing?foodType=FISH && echo ""

echo "========== curl from INTERNET ==> ${TARGET_PROJECT}"
curl http://${TARGET_HOST}/pairing?foodType=FISH && echo ""

oc delete project ${CLIENT_PROJECT}
oc delete project ${TARGET_PROJECT}

unset POLICY_NAME TARGET_PROJECT CLIENT_PROJECT