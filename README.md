# kubeContainerStatus

An automation script used to verify a deployment update.

## Scenario
### Step 1: Update the version of the app

To list your deployments use the get deployments command:
```bash
kubectl get deployments
```
To list the running Pods use the get pods command:
```bash
kubectl get pods
```
To view the current image version of the app, run a describe command against the Pods (look at the Image field):
```bash
kubectl describe pods
```
To update the image of the application to version 2, use the set image command, followed by the deployment name and the new image version:
```bash
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2
```
The command notified the Deployment to use a different image for your app and initiated a rolling update. Check the status of the new Pods, and view the old one terminating with the get pods command:
```bash
kubectl get pods -l app=kubernetes-bootcamp
```
### Step 2: Verify an update
Use get deployments to see the status of the deployment:
```bash
kubectl get deployments -l app=kubernetes-bootcamp
```
And something is wrong… We do not have the desired number of Pods available. List the Pods again:
```bash
kubectl get pods -l app=kubernetes-bootcamp -o yaml
```
A describe command on the Pods should give more insights:
```bash
kubectl describe pods -l app=kubernetes-bootcamp
```
There is no image called v2 in the repository. We should roll back to our previously working version.

`kubeContainerStatus` is an automation script to verify a deployment update.

It checks deployment status periodicaly analyzing container statuses and historical data from previous check cycles.

Based on this data `kubeContainerStatus` returns exitcode=0 if:
* All containers are running (`ContainerStateRunning` state) within N cycles;

`kubeContainerStatus` returns exitcode=1 if:
* One or more containers have `ContainerStateWaiting` state and reason regarded as `Error` (see below);
* One or more containers have `ContainerStateTerminated` state;
* Execution time > TIMEOUT (optional, default:300) due to `UNSTABLE` or `ContainerStateWaiting` states;

`kubeContainerStatus` sets state=UNSTABLE if:
* one or more containers have `restartCount` changed since last check;

## Container states and reasons:
```code
Error:
  waiting:
  - ErrImagePull
  - CrashLoopBackOff
  - ImagePullBackOff
  - CreateContainerConfigError
  - InvalidImageName
  - CreateContainerError

  terminated:
  - OOMKilled
  - Error
  - Completed
  - ContainerCannotRun
  - DeadlineExceeded 

Pending:
  waiting:
  - ContainerCreating

Running:
  running: []
```

## Environment variables:

* `PROJECT_NAME` - the project name, required
* `NAMESPACE` - the namespace, default:default
* `TOKEN` - k8s token, default:none
* `AWS_CLUSTER` - AWS Cluster name, default:none
* `TIMEOUT` - the timeout in sec, default:300
* `DELAY` - the delay before check in sec, default:30
* `RUNNING_CYCLES` - the number N of times to watch with DELAY if all containers running, default:7

`kubeContainerStatus` uses `kubectl get pods -l app=kubernetes-bootcamp` so that you should set label app=kubernetes-bootcamp in kube spec.

Example:
```code
labels:
  app: kubernetes-bootcamp
```

## Usage
```bash
PROJECT_NAME=kubernetes-bootcamp TIMEOUT=180 DELAY=20 RUNNING_CYCLES=5 perl -I. kubeContainerStatus.pl
```
## Links
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#containerstate-v1-core
