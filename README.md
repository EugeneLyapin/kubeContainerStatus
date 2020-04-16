# kubeContainerStatus
kube container status

## Usage
Environment variables:

* `PROJECT_NAME` - the project name (labels[app]), required
* `NAMESPACE` - the namespace, default:default
* `TOKEN` - k8s token, default:none
* `AWS_CLUSTER` - AWS Cluster name, default:none
* `TIMEOUT` - the timeout in sec, default:180
* `DELAY` - the delay before check in sec, default:15
* `RUNNING_CYCLES` - the number of times to watch with DELAY if all containers running, default:`TIMEOUT/(DELAY*2)`

kubeContainerStatus uses `kubectl get pods -l app=myapp` so that you should set label app=myapp in kube spec.

Example:

```code
labels:
  app: myapp
```


Example:
```bash
PROJECT_NAME=myapp TIMEOUT=180 DELAY=20 perl -I. kubeContainerStatus.pl
```
