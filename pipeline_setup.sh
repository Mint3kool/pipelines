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

if [[ $* == *-k* ]]; then
    oc apply -f pipelines/pipeline-kaniko.yml
    oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kaniko/0.5/kaniko.yaml
else
    oc apply -f pipelines/pipeline.yml
fi

echo "make sure openshift pipelines operator is installed"
#oc apply -f operators/pipelines.yml
oc apply -f storage
oc apply -R -f secret/
oc apply -R -f pipelines/tasks
oc create -R -f pipelines/triggers

oc secrets link pipeline tshen-quay-robot-secret --for=pull,mount
