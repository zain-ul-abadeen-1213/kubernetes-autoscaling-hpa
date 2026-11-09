#!/usr/bin/env bash
# Generate CPU load against the app from inside the cluster.
# Stop with Ctrl+C: the pod is removed automatically (--rm).
SVC_IP="$(kubectl -n zaintech get svc zaintech-cpu -o jsonpath='{.spec.clusterIP}')"
echo "Sending load to http://$SVC_IP (ClusterIP of zaintech-cpu) ... Ctrl+C to stop."
# NOTE: load goes to the ClusterIP, not the DNS name. In this lab the
# busybox pod cannot resolve cluster DNS names at all ("wget: bad address"
# for both the short name and the *.svc.cluster.local FQDN), so the script
# resolves the ClusterIP through the Kubernetes API instead.
kubectl run -i --tty load-generator --rm --image=busybox:1.28 \
  --restart=Never -n zaintech -- /bin/sh -c \
  "while sleep 0.01; do wget -q -O- http://$SVC_IP > /dev/null; done"
