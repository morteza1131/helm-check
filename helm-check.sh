#!/bin/bash
#set -x
if [[ -z $1 || -z $2 ]];then
    echo "Please enter Namespace and Releasename: $0 NAMESPACE RELEASE_NAME"
    exit 1
fi

NAMESPACE=$1
RELEASE=$2
ROLLBACK_NEEDED_STATUSES=('unknown' 'pending-install' 'pending-upgrade' 'pending-rollback')
LAST_STATUS=$(helm -n $NAMESPACE status $RELEASE | grep -i status | cut -d ' ' -f 2)
LAST_REVISION=$(helm -n $NAMESPACE status $RELEASE | grep -i revision | cut -d ' ' -f 2)
HEALTHY_STATUS=('deployed' 'superseded')

check_last_success() {
    STATUS=$LAST_STATUS
    REVISION=$LAST_REVISION
    while true;do
        STATUS=$(helm -n $NAMESPACE history $RELEASE | grep $REVISION | awk '{print $7}')
        for status in "${HEALTHY_STATUS[@]}";do
            if [[ $STATUS == $status ]];then
                break 2
            fi
        done
        REVISION=$(expr $REVISION - 1)
    done
    LAST_SUCCESS_REVISION=$REVISION
    if [[ $LAST_SUCCESS_REVISION ==  $LAST_REVISION ]];then
        echo "Last Release deploy status is: $status , no need to rollback"
        exit 0
    fi
    return $LAST_SUCCESS_REVISION
}

## Check if no need to rollback and exit 0:
if [[ $LAST_STATUS == failed ]];then
    echo "Last Release deploy status is: $LAST_STATUS , no need to rollback"
    exit 0
fi

## Check needing rollback:
check_last_success
LAST_SUCCESS_REVISION=$?
for status in "${ROLLBACK_NEEDED_STATUSES[@]}";do
    if [[ $LAST_STATUS == $status ]] ;then
        echo "Last release deploy status is: $LAST_STATUS , Rollingback to $LAST_SUCCESS_REVISION revision"
        helm -n $NAMESPACE rollback $RELEASE $LAST_SUCCESS_REVISION
    fi
done
