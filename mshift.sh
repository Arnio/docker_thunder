#!/bin/bash
ssh_rsa="/mnt/c/Users/akraso/Documents/akraso_sshkey/id_rsa"


#######################################################
if [ -n "$1" ]; then
  APP_NAME=$1
else
  APP_NAME="thunder"
fi

if [ -n "$2" ]; then
  JENKINS_NAME=$2
else
  JENKINS_NAME="jenkins-ci"
fi

if ! oc whoami 2>/dev/null; then
  echo "User not login"
exit
fi
########################################################

check_project="$(oc get project $JENKINS_NAME 2>/dev/null | grep Active  )"

if [ -z "$check_project" ]
then
  oc new-project $JENKINS_NAME
  JenkinsApply="yes"
else
  echo -n "Project " $JENKINS_NAME " exists. Continue? y-yes/n-no "
  read confirm

  if [ "$confirm" != "y" ]
  then
    echo "Input <script name> <app-name> <jenkins-name>"
    JenkinsApply="no"
  else
    JenkinsApply="yes"
  fi

fi

check_project="$(oc get project $APP_NAME 2>/dev/null | grep Active)"
if [ -z "$check_project" ]; then
  oc new-project $APP_NAME
  AppApply="yes"
else 
  echo -n "Project " $APP_NAME " exists. Continue? y-yes/n-no "
  read confirm
 
  if [ "$confirm" != "y" ]
  then
    echo "Input <script name> <app-name> <jenkins-name>"
    AppApply="no"
  else
    AppApply="yes"
  fi
fi
###################################################################

if [ $JenkinsApply == "yes" ]
then

check_key="$(oc get secret git-key -n $JENKINS_NAME 2>/dev/null | grep git-key)"

if [ -z "$check_key" ]
then
oc create secret generic git-key --from-file=filename=$ssh_rsa -n $JENKINS_NAME
oc label secret git-key credential.sync.jenkins.openshift.io=true -n $JENKINS_NAME  
fi
#oc process -f jenkins/settings_user.yaml | oc apply -f - -n openshift
oc process -f jenkins/jenkins.yaml -p APP_NAME=$APP_NAME -p JENKINS_NAME=$JENKINS_NAME | oc apply -f - -n $JENKINS_NAME
fi


if [ $AppApply == "yes" ]
then

oc process -f thunder/settings_app.yaml -p APP_NAME=$APP_NAME | oc apply -f - -n openshift
oc process -f thunder/thunder.yaml -p APP_NAME=$APP_NAME -p JENKINS_NAME=$JENKINS_NAME | oc apply -f - -n $APP_NAME

fi

if [ -n "$(oc get bc build-base-image -n $JENKINS_NAME 2>/dev/null | grep build-base-image)" ]
then
oc start-build build-base-image -n $JENKINS_NAME
echo "start-build build-base-image"
fi

if [ -n "$(oc get bc build-app-image -n $JENKINS_NAME 2>/dev/null | grep build-app-image)" ]
then
oc start-build build-app-image -n $JENKINS_NAME
echo "start-build build-app-image"
fi
