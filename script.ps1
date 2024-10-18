# PowerShell Script for Template Version Control

# Define template directory
$TEMPLATE_DIR = "prompts"

# Create a new version of the template
function Create-Version {
    param($templateName, $version)

    # Ensure template file exists
    if (-not (Test-Path "$TEMPLATE_DIR\$templateName")) {
        Write-Host "Template $templateName does not exist in $TEMPLATE_DIR"
        exit 1
    }

    # Add changes to git and create a new tag
    git add "$TEMPLATE_DIR\$templateName"
    git commit -m "Created $templateName version $version"
    git tag "$templateName-$version"
    Write-Host "Version $version for template $templateName created."
}

# Detect the latest version of the template
function Get-LatestVersion {
    param($templateName)

    # Extract all tags for the template and find the latest version number
    $latest_tag = git tag -l "$templateName-*" | Sort-Object -Descending | Select-Object -First 1
    if (-not $latest_tag) {
        Write-Host "No version found for $templateName"
        exit 1
    }

    # Extract the version part (e.g., v1, v2) from the tag
    $latest_version = $latest_tag -replace "$templateName-",""

    return $latest_version
}

# Update the latest version of the template
function Update-Version {
    param($templateName)

    # Get the latest version automatically
    $latest_version = Get-LatestVersion $templateName

    # Add changes and move the tag to the new commit
    git add "$TEMPLATE_DIR\$templateName"
    git commit -m "Updated $templateName version $latest_version"
    git tag -f "$templateName-$latest_version"  # Force update the existing tag
    Write-Host "Version $latest_version for template $templateName updated."
}

# Switch to a specific version of the template
function Switch-Version {
    param($templateName, $version)

    $tag = "$templateName-$version"

    # Check if the tag exists
    if (git rev-parse $tag 2>$null) {
        git checkout $tag -- "$TEMPLATE_DIR\$templateName"
        Write-Host "Switched $templateName to version $version."
    } else {
        Write-Host "Version $version for template $templateName does not exist."
    }
}

# List available versions for the template
function List-Versions {
    param($templateName)
    git tag -l "$templateName-*"
}

# Delete a specific version of the template
function Delete-Version {
    param($templateName, $version)

    $tag = "$templateName-$version"

    # Check if the tag exists
    if (git rev-parse $tag 2>$null) {
        git tag -d $tag
        Write-Host "Version $version for template $templateName deleted."
    } else {
        Write-Host "Version $version for template $templateName does not exist."
    }
}

# Main script logic
switch ($args[0]) {
    "create" { Create-Version $args[1] $args[2] }
    "update" { Update-Version $args[1] }
    "switch" { Switch-Version $args[1] $args[2] }
    "list"   { List-Versions $args[1] }
    "delete" { Delete-Version $args[1] $args[2] }
    default  { Write-Host "Usage: .\script.ps1 {create|update|switch|list|delete} <templateName> [version]" }
}