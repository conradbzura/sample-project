#!/bin/bash

USAGE="Usage: $0 [KEYCHAIN=dev SECRET=pypi-token] | [TOKEN]"

# Evaluate arguments
case $# in
    0)
        # Attempt to retrieve token from default keychain
        if command -v ks &> /dev/null; then
            if ks -k dev ls | grep -q "pypi-token"; then
                KEYCHAIN="dev"
                SECRET="pypi-token"
                TOKEN=$(ks -k $KEYCHAIN show $SECRET)
                echo "Publishing with token from keychain..."
            fi
        fi
        ;;
    1)
        # Use the specified token
        echo "Publishing with provided token..."
        TOKEN=$1
        ;;
    2)
        # Attempt to retrieve token from the specified keychain
        echo "Publishing with token from keychain..."
        KEYCHAIN=$1
        SECRET=$2
        TOKEN=$(ks -k $KEYCHAIN show $SECRET)
        ;;
    *)
        # Improper usage
        echo $USAGE
        exit 1
        ;;
esac

# Publish the package
if [ -n "$TOKEN" ]; then
    uv publish --username "__token__" --password "$TOKEN"
else
    echo "Publishing without token..."
    uv publish
    echo "Token: No token provided"
fi
