#!/bin/sh
# This script replaces placeholders in config.js with actual environment variables

set -e

CONFIG_FILE="/usr/share/nginx/html/config.js"

echo "🔧 Initializing runtime configuration..."

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found at $CONFIG_FILE"
    exit 1
fi

# Replace placeholders with actual environment variable values in config file
# Use | as delimiter to avoid issues with URLs containing /
# -i: in place substitution, g: global (all values)
sed -i "s|VITE_BACKEND_URL_PLACEHOLDER|${VITE_BACKEND_URL}|g" "$CONFIG_FILE"
sed -i "s|VITE_BACKEND_HOST_PLACEHOLDER|${VITE_BACKEND_HOST}|g" "$CONFIG_FILE"
sed -i "s|VITE_AUTH0_DOMAIN_PLACEHOLDER|${VITE_AUTH0_DOMAIN}|g" "$CONFIG_FILE"
sed -i "s|VITE_AUTH0_CLIENT_ID_PLACEHOLDER|${VITE_AUTH0_CLIENT_ID}|g" "$CONFIG_FILE"

echo "Runtime configuration initialized successfully"
echo "BACKEND_URL:     ${VITE_BACKEND_URL}"
echo "BACKEND_HOST:    ${VITE_BACKEND_HOST}"
echo "AUTH0_DOMAIN:    ${VITE_AUTH0_DOMAIN}"
echo "AUTH0_CLIENT_ID: ${VITE_AUTH0_CLIENT_ID}"
