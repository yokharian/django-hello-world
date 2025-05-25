#!/bin/bash

echo "==== Deployment Configuration ===="

# Prompt user for input variables
read -p "Would you like to create a new Artifact Registry repository? (y/n): " CREATE_REPO
if [[ "$CREATE_REPO" == "y" ]]; then
    create_artifact_registry
else
    read -p "👉 Enter your existing Artifact Registry repository name: " REPOSITORY_NAME
fi

# Create new Artifact Registry
create_artifact_registry() {
    echo "🏗️ Creating new Artifact Registry repository..."
    cd terraform/modules/artifact_registry || {
        echo "❌ Error: Could not find Terraform Artifact Registry configuration"
        exit 1
    }

    # Initialize and apply Artifact Registry Terraform configuration
    terraform init || {
        echo "❌ Error: Terraform initialization failed"
        exit 1
    }

    read -p "👉 Enter the Google Cloud zone to create the artifact registry there (e.g., us-central1-a): " ZONE
    read -p "👉 Enter the Artifact Registry repository name: " REPOSITORY_NAME

    terraform apply -auto-approve \
        -var="project_id=$PROJECT_ID" \
        -var="zone=$ZONE" \
        -var="repository_name=$REPOSITORY_NAME" || {
        echo "❌ Error: Failed to create Artifact Registry"
        exit 1
    }

    cd ../../.. || exit 1
    echo "✅ Artifact Registry repository created successfully!"
}

# default values
DEFAULT_IMAGE_NAME="django_app_image"
DEFAULT_REPO_NAME="django_app_repo"

read -p "👉 Enter the Google Cloud region (e.g., us-central1): " REGION
read -p "👉 Enter your Google Cloud project ID: " PROJECT_ID
read -p "👉 Enter your 'artifact registry name' or leave it empty to use default: [$DEFAULT_REPO_NAME]: " IMAGE_REPO
read -p "👉 Enter your 'Docker image name' or leave it empty to use default: [$DEFAULT_IMAGE_NAME]: " IMAGE_NAME

# Use default if input is empty
IMAGE_REPO=${IMAGE_REPO:-$DEFAULT_REPO_NAME}
IMAGE_NAME=${IMAGE_NAME:-$DEFAULT_IMAGE_NAME}

# Show a summary of entered values
echo ""
echo "📦 Configuration Summary:"
echo "REGION:           $REGION"
echo "PROJECT_ID:       $PROJECT_ID"
echo "REPOSITORY_NAME:  $REPOSITORY_NAME"
echo "IMAGE_NAME:       $IMAGE_NAME"

read -p "Proceed with this configuration? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
  echo "🚫 Aborted by user."
  exit 1
fi







# Check required tools
check_dependencies() {
    echo "Checking required dependencies..."
    if ! command -v gcloud &> /dev/null; then
        echo "Error: Google Cloud SDK is not installed"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        echo "Error: Terraform is not installed"
        exit 1
    fi
}

# Configure Docker authentication
setup_docker_auth() {
    echo "Configuring Docker authentication for Artifact Registry..."
    gcloud auth configure-docker "${REGION}-docker.pkg.dev" || {
        echo "Error: Failed to configure Docker authentication"
        exit 1
    }
}

# Build and push Docker image
build_and_push_image() {
    echo "Building and pushing Docker image..."
    local timestamp=$(date +%s)
    local image_path="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_NAME}/${IMAGE_NAME}:${timestamp}"
    
    docker build -t "$image_path" ./django_app || {
        echo "Error: Docker build failed"
        exit 1
    }
    
    docker push "$image_path" || {
        echo "Error: Docker push failed"
        exit 1
    }
    
    echo "IMAGE_TAG=$image_path" >> $GITHUB_ENV
}

# Apply Terraform configuration
apply_terraform() {
    echo "Applying Terraform configuration..."
    cd terraform || {
        echo "Error: Could not change to Terraform directory"
        exit 1
    }
    
    terraform init || {
        echo "Error: Terraform initialization failed"
        exit 1
    }
    
    terraform apply -auto-approve -var="image_tag=$IMAGE_TAG" || {
        echo "Error: Terraform apply failed"
        exit 1
    }
}







# Main execution flow
main() {
    check_dependencies
    setup_docker_auth
    build_and_push_image
    apply_terraform
}

# Run the script
main
