#!/usr/bin/env bash
# Setup: metrics-server (kind patch) + CPU app + HPA on the zaintech cluster.
set -e
cd "$(dirname "$0")/.."

echo "== 1/5 Cluster check =="
kubectl config use-context kind-zaintech
kubectl get nodes

echo "== 2/5 metrics-server =="
if kubectl -n kube-system get deployment metrics-server >/dev/null 2>&1; then
  echo "metrics-server already installed"
else
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  # kind needs this flag, otherwise the kubelet TLS check fails
  kubectl -n kube-system patch deployment metrics-server --type=json \
    -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s

echo "== waiting until 'kubectl top' answers (can take ~60s) =="
for i in $(seq 1 30); do
  if kubectl top nodes >/dev/null 2>&1; then echo "metrics API OK"; break; fi
  sleep 5
done
kubectl top nodes

echo "== 3/5 Build CPU app image and load it into kind =="
docker build -t zaintech-cpu-app:v1 app/
kind load docker-image zaintech-cpu-app:v1 --name zaintech

echo "== 4/5 Apply manifests =="
kubectl apply -f manifests/
kubectl -n zaintech rollout status deployment/zaintech-cpu --timeout=180s

echo "== 5/5 Status =="
kubectl -n zaintech get pods,svc,hpa
echo
echo "App in browser: kubectl -n zaintech port-forward svc/zaintech-cpu 30081:80  ->  http://localhost:30081"
echo "Next: terminal 1 -> kubectl -n zaintech get hpa --watch"
echo "      terminal 2 -> bash scripts/generate-load.sh"
