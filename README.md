# kubeContainerStatus
kube container status

## Usage
Environment variables:

* `PROJECT_NAME` - project name (labels[app]), required
* `NAMESPACE` - namespace, default:default
* `TOKEN` - k8s token, default:none
* `AWS_CLUSTER` - AWS Cluster name, default:none
* `TIMEOUT` - timeout in sec, default:180
* `DELAY` - delay before check in sec, default:15

Example:
```bash
PROJECT_NAME=myapp perl -I. kubeContainerStatus.pl
```
