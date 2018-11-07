# azure-automation<br />
<br />
1. tag_rgs.sh can be used to automatically add a "creator" tag with the resource group creator's email .<br />
<br />
usage: ./tag_rgs.sh subscription_id<br />
example: ./tag_rgs.sh 12345678-abcd-abcd-abcd-23689be96924<br />
because of a az cli issue https://github.com/Azure/azure-cli/issues/7420 , the subscription need to be id instead of name<br />
<br />
<br />
This script use Azure managered identity for authentication/authorization, so you need to create a MI for the VM and grant it proper permission to those subscriptions need to be tagged.<br />
<br />
I think following Azure permission in subscription level should be sufficient :<br />
    "Microsoft.Authorization/*/read",<br />
    "Microsoft.Insights/alertRules/*",<br />
    "Microsoft.Insights/LogDefinitions/*",<br />
    "Microsoft.Insights/eventtypes/*",<br />
    "Microsoft.Insights/*",<br />
    "Microsoft.Storage/storageAccounts/read",<br />
    "Microsoft.Storage/storageAccounts/write",<br />
<br />
If you don't want to create a azure customized role, subscription contributor should do.<br />
<br />
The script will go through each resource groups in the subscription, then check its activity log to find the resource group creator in last 90 days ( Azure only keep activity log for 90 days ). If the resource group was created 90 days ago, then it will just be tagged as "creator: NO_RECORD" .<br />
<br />
