#!/usr/bin/env bash
# Generate CPU load against the app from inside the cluster.
# Stop with Ctrl+C: the pod is removed automatically (--rm).
echo "Sending load to http://zaintech-cpu.zaintech.svc ... Ctrl+C to stop."
kubectl run -i --tty load-generator --rm --image=busybox:1.28 \
  --restart=Never -n zaintech -- /bin/sh -c \
  "while sleep 0.01; do wget -q -O- http://zaintech-cpu.zaintech.svc.cluster.local > /dev/null; done"
