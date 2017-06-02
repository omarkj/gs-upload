#!/bin/sh

echo "Starting run.sh"

gcloud_install_dir="$WERCKER_STEP_ROOT/google-cloud-sdk/bin"
gcloud="$gcloud_install_dir/gcloud"

gcloud_key="$WERCKER_GSUPLOAD_KEY"
file="$WERCKER_GSUPLOAD_FILE"
target="$WERCKER_GSUPLOAD_TARGET"
project="$WERCKER_GSUPLOAD_PROJECT"

version() {
    info "Running gcloud version:"
    $gcloud --version
}

gcloud_authenticate() {
    if [ ! -n "$gcloud_key" ]; then
        echo "GCloud token must be provided."
        exit 1
    fi
    keyfile=$(mktemp)
    echo "$gcloud_key" > "$keyfile"
    echo "Activating service account"
    if ! $gcloud auth activate-service-account --key-file "$keyfile"; then
        echo "Unable to authenticate with Google Cloud..."
        exit 1
    fi
}

upload() {
    token="$($gcloud auth print-access-token)"
    curl --upload-file $file -H "Authorization: Bearer $token" "$target"
}

main() {
    version
    gcloud_authenticate
    upload
}

main;