# azure-automation

1. tag_rgs.sh can be used to automatically add a "creator" tag with the resource group creator's email .

usage: ./tag_rgs.sh subscription_id
example: ./tag_rgs.sh 12345678-abcd-abcd-abcd-23689be96924
because of a az cli issue https://github.com/Azure/azure-cli/issues/7420 , the subscription need to be id instead of name


This script use Azure managered identity for authentication/authorization, so you need to create a MI for the VM and grant it proper permission to those subscriptions need to be tagged.

I think following Azure permission in subscription level should be sufficient :
    "Microsoft.Authorization/*/read",
    "Microsoft.Insights/alertRules/*",
    "Microsoft.Insights/LogDefinitions/*",
    "Microsoft.Insights/eventtypes/*",
    "Microsoft.Insights/*",
    "Microsoft.Storage/storageAccounts/read",
    "Microsoft.Storage/storageAccounts/write",

If you don't want to create a azure customized role, subscription contributor should do.

The script will go through each resource groups in the subscription, then check its activity log to find the resource group creator in last 90 days ( Azure only keep activity log for 90 days ). If the resource group was created 90 days ago, then it will just be tagged as "creator: NO_RECORD" .

