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
check "app responds on NodePort 30081" \
  "curl -sf http://localhost:30081 | grep -q 'Zain Tech Automation Solutions'"

echo
echo "Passed: $pass  Failed: $fail"
[ "$fail" -eq 0 ]
