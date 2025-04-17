#!/bin/bash

USAGE="Usage: $0 [-s|--source=dist] [KEYCHAIN=dev SECRET=pypi-token | TOKEN]"
SOURCE="dist"

# Evaluate arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source)
            SOURCE="$2"
            shift 2
            ;;
        *)
            case $# in
                0)
                    # Attempt to retrieve token from default keychain
                    if command -v ks &> /dev/null; then
                        if ks -k $KEYCHAIN ls | grep -q "\bpypi-token\b"; then
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
            ;;
    esac
done

# Publish the package
if [ -n "$TOKEN" ]; then
    uv publish --username "__token__" --password "$TOKEN" "$SOURCE"
else
    echo "Warning: Publishing without token..."
    uv publish "$SOURCE"
fi
