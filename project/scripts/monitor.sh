#!/usr/bin/env bash
watch -n 1 'echo "=== MEMORY ==="; free -h; echo ""; echo "=== CPU ==="; top -bn1 | head -5; echo ""; echo "=== DISK ==="; df -h /'
