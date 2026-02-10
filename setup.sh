#!/bin/bash
set -e

# Set variable values (match your Azure subscription - fix Y prefix typos from original .cmd)
subscription_id="3e5ff226-7b86-4538-8eb7-e1638adc99ab"
resource_group="rg_eastus_47039_1_177070931474"
location="eastus"
expiry_date="2025-01-01T00:00:00Z"

# Get random numbers to create unique resource names
unique_id="${RANDOM}${RANDOM}"
storage_account_name="ai102form${unique_id}"

# Create a storage account in your Azure resource group
echo "Creating storage..."
az storage account create --name "$storage_account_name" --subscription "$subscription_id" --resource-group "$resource_group" --location "$location" --sku Standard_LRS --encryption-services blob --default-action Allow --output none --allow-blob-public-access true

echo "Uploading files..."
# Get storage key
AZURE_STORAGE_KEY=$(az storage account keys list --subscription "$subscription_id" --resource-group "$resource_group" --account-name "$storage_account_name" --query "[?keyName=='key1'].value" -o tsv)

# Create container
az storage container create --account-name "$storage_account_name" --name sampleforms --auth-mode key --account-key "$AZURE_STORAGE_KEY" --output none

# Upload files from sample-forms folder to the container
az storage blob upload-batch -d sampleforms -s ./sample-forms --account-name "$storage_account_name" --auth-mode key --account-key "$AZURE_STORAGE_KEY" --output none

# Get a Shared Access Signature for the blobs in sampleforms
SAS_TOKEN=$(az storage container generate-sas --account-name "$storage_account_name" --name sampleforms --expiry "$expiry_date" --permissions rwl -o tsv)
URI="https://${storage_account_name}.blob.core.windows.net/sampleforms?${SAS_TOKEN}"

# Print the generated Shared Access Signature URI
echo "-------------------------------------"
echo "SAS URI: $URI"
