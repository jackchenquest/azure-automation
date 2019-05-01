#!/bin/bash

if [ $# != 1 ]; then
        echo "usage: $0 subscription_id";
        echo "example: $0 12345678-abcd-abcd-abcd-23689be96924";
        echo "because of a az cli issue https://github.com/Azure/azure-cli/issues/7420 , the subscription need to be id instead of name";
        exit
fi


sub=$1

az login --identity >/dev/null

checksub=`az account list | grep -i $sub`
if [ "$checksub" == "" ]; then
	echo  "doesn't have permission to $sub"
	exit
fi
az account set --subscription  $sub

echo "subscription : $sub"
BASEDIR=$(dirname $0)

DATADIR="$BASEDIR/data"
if [ ! -d $DATADIR ]; then mkdir -p $DATADIR; fi

RGFILE="$DATADIR/$sub.rg.txt"
if [ ! -f $RGFILE ]; then echo -n > $RGFILE; fi

az group list -o table --query "[].{name:name}" | tail -n +3 | while read rg; do
	search=`grep "^$rg:" $RGFILE`
	if [ "$search" != "" ]; then
		echo "$rg is already processed."
		continue;
	fi

	#### need to add max-event to a big number, otherwise it only retrieve latest 50 events, then filter, so it could miss the record.
	creator=`az monitor activity-log list --offset 90d --max-events 3000 -g $rg --query "[?authorization.action=='Microsoft.Resources/subscriptions/resourceGroups/write' && subStatus.value == 'Created' ].{creator:caller}" -o json | grep creator | gawk -F"\"" '{print $4}'`
	if [ "$creator" != "" ]; then 
		az group update -g $rg --tags "creator=$creator" >/dev/null
	else
		existing_tag=`az group show -g $rg --query "tags.creator" | sed -e 's/"//g' `
		if [ "$existing_tag" == "" ]; then
			creator="NO_RECORD"; 
			az group update -g $rg --tags "creator=$creator"  >/dev/null
		fi
	fi
	
	### double confirm the tag is set.
	existing_tag=`az group show -g $rg --query "tags.creator" | sed -e 's/"//g' `
	if [ "$existing_tag" != "" ]; then
		echo "setup creator tag: $rg:$existing_tag"
		echo "$rg:$existing_tag" >> $RGFILE
	fi

done


az logout
echo

exit




