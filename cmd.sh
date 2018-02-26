#!/usr/bin/env sh

set -e

### begin login
loginCmd='az login -u "$loginId" -p "$loginSecret"'

# handle opts
if [ "$loginTenantId" != " " ]; then
    loginCmd=$(printf "%s --tenant %s" "$loginCmd" "$loginTenantId")
fi

case "$loginType" in
    "user")
        echo "logging in as user"
        ;;
    "sp")
        echo "logging in as service principal"
        loginCmd=$(printf "%s --service-principal" "$loginCmd")
        ;;
esac
eval "$loginCmd" >/dev/null

echo "setting default subscription"
az account set --subscription "$subscriptionId"
### end login

# At time of writing; api, cli, & node sdk listConnectionStrings methods all were broken (returned empty result)
# Azure UI seems to take the below approach; so we do here too
accountEndpoint=$(az cosmosdb show \
    --name "$cosmosDbAccount" \
    --resource-group "$resourceGroup" \
    --query "documentEndpoint" \
    --output tsv)

accountKey=$(az cosmosdb list-keys \
    --name "$cosmosDbAccount" \
    --resource-group "$resourceGroup" \
    --query "${key}MasterKey" \
    --output tsv)

echo -n "AccountEndpoint=$accountEndpoint;AccountKey=$accountKey;" > /connectionString