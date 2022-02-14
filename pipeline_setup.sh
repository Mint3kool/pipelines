OCHOST=$1

if ! [[ -n "${OCHOST}" ]]; then
  echo "Set openshift host as first param"
  exit
fi

echo "${OCHOST}"
LOGGEDIN=$(oc project | grep "$OCHOST" >/dev/null; echo $?)
if [[ "$LOGGEDIN" == "0" ]]; then
    echo "Sweet.  Already logged in."
else
    echo "Either not logged in or logged into the wrong ocp cluster"
    exit 1
fi

MYPROJ=$(oc projects | grep tay-test >/dev/null; echo $?)
if [[ "$MYPROJ" == "0" ]]; then
    echo "tay-test already exists"
    oc project tay-test
else
    oc new-project tay-test
fi

oc apply -f operators/pipelines.yml
oc apply -f storage
oc apply -f secret
oc apply -f pipelines
oc apply -f pipelines/tasks

