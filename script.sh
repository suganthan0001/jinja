#!/bin/bash
 
# Define template directory
TEMPLATE_DIR="prompts"
 
# Create a new version of the template
create_version() {
    templateName=$1
    version=$2
 
    # Ensure template file exists
    if [[ ! -f "$TEMPLATE_DIR/$templateName" ]]; then
        echo "Template $templateName does not exist in $TEMPLATE_DIR"
        exit 1
    fi
 
    # Add changes to git and create a new tag
    git add "$TEMPLATE_DIR/$templateName"
    git commit -m "Created $templateName version $version"
    git tag "$templateName-$version"
    echo "Version $version for template $templateName created."
}
 
# Detect the latest version of the template
get_latest_version() {
    templateName=$1
 
    # Extract all tags for the template and find the latest version number
    latest_tag=$(git tag -l "$templateName-*" | sort -V | tail -n 1)
    if [[ -z "$latest_tag" ]]; then
        echo "No version found for $templateName"
        exit 1
    fi
 
    # Extract the version part (e.g., v1, v2) from the tag
    latest_version=$(echo "$latest_tag" | sed -E "s/$templateName-//")
 
    echo "$latest_version"
}
 
# Update the latest version of the template
update_version() {
    templateName=$1
 
    # Get the latest version automatically
    latest_version=$(get_latest_version "$templateName")
 
    # Add changes and move the tag to the new commit
    git add "$TEMPLATE_DIR/$templateName"
    git commit -m "Updated $templateName version $latest_version"
    git tag -f "$templateName-$latest_version"  # Force update the existing tag
    echo "Version $latest_version for template $templateName updated."
}
 
# Switch to a specific version of the template
switch_version() {
    templateName=$1
    version=$2
 
    tag="$templateName-$version"
 
    # Check if the tag exists
    if git rev-parse "$tag" >/dev/null 2>&1; then
        git checkout "$tag" -- "$TEMPLATE_DIR/$templateName"
        echo "Switched $templateName to version $version."
    else
        echo "Version $version for template $templateName does not exist."
    fi
}
 
# List available versions for the template
list_versions() {
    templateName=$1
    git tag -l "$templateName-*"
}
 
# Delete a specific version of the template
delete_version() {
    templateName=$1
    version=$2
 
    tag="$templateName-$version"
 
    # Check if the tag exists
    if git rev-parse "$tag" >/dev/null 2>&1; then
        git tag -d "$tag"
        echo "Version $version for template $templateName deleted."
    else
        echo "Version $version for template $templateName does not exist."
    fi
}
 
# Main script logic
case $1 in
    create)
        create_version "$2" "$3"
        ;;
    update)
        update_version "$2"
        ;;
    switch)
        switch_version "$2" "$3"
        ;;
    list)
        list_versions "$2"
        ;;
    delete)
        delete_version "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {create|update|switch|list|delete} <templateName> [version]"
        ;;
esac