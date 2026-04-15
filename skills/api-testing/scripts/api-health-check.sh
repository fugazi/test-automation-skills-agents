#!/bin/bash
# API Health Check — validates that API endpoints respond correctly
# Usage: ./api-health-check.sh [base_url]

BASE_URL="${1:-http://localhost:3000/api}"
FAILURES=0

check_endpoint() {
  local method=$1
  local path=$2
  local expected_status=$3

  status=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" "${BASE_URL}${path}")

  if [ "$status" = "$expected_status" ]; then
    echo "PASS $method $path -> $status"
  else
    echo "FAIL $method $path -> $status (expected $expected_status)"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "API Health Check: $BASE_URL"
echo "---"

check_endpoint "GET" "/health" "200"
check_endpoint "GET" "/users" "200"
check_endpoint "GET" "/users/99999" "404"
check_endpoint "POST" "/users" "400"
check_endpoint "GET" "/admin" "401"

echo "---"
if [ $FAILURES -eq 0 ]; then
  echo "All checks passed"
  exit 0
else
  echo "$FAILURES check(s) failed"
  exit 1
fi
