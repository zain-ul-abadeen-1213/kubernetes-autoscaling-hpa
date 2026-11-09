#!/usr/bin/env bash
# Verify the autoscaling setup end to end (components, not the load test).
pass=0; fail=0
check() { if eval "$2" >/dev/null 2>&1; then echo "PASS: $1"; pass=$((pass+1)); else echo "FAIL: $1"; fail=$((fail+1)); fi }

check "metrics-server answers (kubectl top nodes)" \
  "kubectl top nodes"
check "HPA exists in namespace zaintech" \
  "kubectl -n zaintech get hpa zaintech-cpu"
check "HPA shows a numeric CPU target (not <unknown>)" \
  "kubectl -n zaintech get hpa zaintech-cpu --no-headers | grep -v unknown"
check "deployment zaintech-cpu is available" \
  "kubectl -n zaintech get deployment zaintech-cpu -o jsonpath='{.status.availableReplicas}' | grep -E '^[1-9]'"
# The app check goes through a temporary port-forward: a kind cluster only
# maps the ports declared when it was created, so NodePort on localhost is
# not guaranteed. Port-forward always works.
kubectl -n zaintech port-forward svc/zaintech-cpu 30082:80 >/dev/null 2>&1 &
PF_PID=$!
sleep 4
if curl -sf http://localhost:30082 | grep -q 'Zain Tech Automation Solutions'; then
  echo "PASS: app responds (via port-forward)"; pass=$((pass+1))
else
  echo "FAIL: app responds (via port-forward)"; fail=$((fail+1))
fi
kill $PF_PID 2>/dev/null

echo
echo "Passed: $pass  Failed: $fail"
[ "$fail" -eq 0 ]
