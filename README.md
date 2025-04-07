# EKS Karpenter demo

The configuration in this directory creates an AWS EKS cluster with [Karpenter](https://karpenter.sh/) provisioned for managing worker nodes autoscaling. 
Karpenter controller is provisioned on top of an EKS Managed Node Group (named `system`).

## Requirements

- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Modules

The configuration uses two terraform modules to create the EKS cluster:
- [vpc](modules/vpc/README.md): creates the networking infrastructure for the EKS cluster
- [eks](modules/eks/README.md): creates the EKS cluster with Karpenter node autoscaler

## Usage

To provision the provided EKS configuration you need to execute:

```bash
$ terragurnt -working-dir=./live run-all plan
$ terragrunt -working-dir=-/live run-all apply
```

The modules will be deployed with the default configuration. To set up our own configuration, provide your own variables file by renaming the `terraform.tfvars.example` to `terraform.tfvars` and execute the previous `terraform` commands which will read the configuration from the variables file.


## Connecting to the EKS cluster

Once the cluster is up and running, you can connect to the EKS cluster API server by running the following command:

```bash
$ aws eks --region <aws_region> update-kubeconfig --name <cluster_name>
```

This will create a `~/.kube/config` file that stores the information and authentication details, and context configuration for interacting with the kubernetes cluster.

## Check the managed EKS nodes
We can check the managed nodes running in the cluster with the `kubectl` command:

```bash
$ kubectl get nodes
```

```text
NAME                          STATUS   ROLES    AGE   VERSION               REGISTERED
ip-10-1-2-77.ec2.internal     Ready    <none>   8m15s   v1.32.0-eks-2e66e76
ip-10-1-40-237.ec2.internal   Ready    <none>   8m14s   v1.32.0-eks-2e66e76
```

## Deploy a workload in graviton (arm64) nodes

```bash
$ kubectl apply --server-side -f ./modules/eks/k8s/workloads/workload_graviton.yaml
$ kubectl get deployment workload-graviton --watch
```

After a while, a new karpenter node is created to allocate the pods of the workload:

```bash
$ kubectl get nodes -L karpenter.sh/registered -L kubernetes.io/arch
```

```text
NAME                          STATUS   ROLES    AGE   VERSION               REGISTERED   ARCH
ip-10-1-1-187.ec2.internal    Ready    <none>   45m   v1.32.0-eks-2e66e76   true         arm64
ip-10-1-2-77.ec2.internal     Ready    <none>   52m   v1.32.0-eks-2e66e76                amd64
ip-10-1-40-237.ec2.internal   Ready    <none>   52m   v1.32.0-eks-2e66e76                amd64
```

The pods are scheduled in an `arm64` karpenter node based on the node selection `kubernetes.io/arch: arm64` specified in the deployment specification.
```yaml
nodeSelector:
  kubernetes.io/arch: arm64
```

Validate if the Amazon EKS Addons Pods are running in the Managed Node Group and the `workload-graviton` application Pods are running on Karpenter provisioned Nodes.

```bash
$ kubectl get pods -A -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

```text
NAME                                 NODE
workload-graviton-66c8df4c5f-5tbxn   ip-10-1-1-187.ec2.internal
workload-graviton-66c8df4c5f-rcjlf   ip-10-1-1-187.ec2.internal
karpenter-54699cc6d7-4cbgp           ip-10-1-40-237.ec2.internal
karpenter-54699cc6d7-ld8t6           ip-10-1-2-77.ec2.internal
aws-node-crtln                       ip-10-1-1-187.ec2.internal
aws-node-pnfsw                       ip-10-1-40-237.ec2.internal
aws-node-vj8p4                       ip-10-1-2-77.ec2.internal
coredns-55d797b4f9-6d29r             ip-10-1-2-77.ec2.internal
coredns-55d797b4f9-lfzdm             ip-10-1-40-237.ec2.internal
eks-pod-identity-agent-ndjjh         ip-10-1-1-187.ec2.internal
eks-pod-identity-agent-rhd7x         ip-10-1-2-77.ec2.internal
eks-pod-identity-agent-sxzm6         ip-10-1-40-237.ec2.internal
kube-proxy-tcbq8                     ip-10-1-1-187.ec2.internal
kube-proxy-wnnfz                     ip-10-1-40-237.ec2.internal
kube-proxy-ww6kc                     ip-10-1-2-77.ec2.internal
```

## Deploy a workload in x86 nodes

```bash
$ kubectl apply --server-side -f ./modules/eks/k8s/workloads/workload_x86.yaml
$ kubectl get deployment workload-x86 --watch
```

After a while, a new karpenter node is created to allocate the pods of the workload:

```bash
$ kubectl get nodes -L karpenter.sh/registered -L kubernetes.io/arch
```

```text
NAME                          STATUS   ROLES    AGE     VERSION               REGISTERED   ARCH
ip-10-1-2-77.ec2.internal     Ready    <none>   113m    v1.32.0-eks-2e66e76                amd64
ip-10-1-30-208.ec2.internal   Ready    <none>   2m50s   v1.32.0-eks-2e66e76   true         amd64
ip-10-1-40-237.ec2.internal   Ready    <none>   113m    v1.32.0-eks-2e66e76                amd64
```

The pods are scheduled in an `amd64` karpenter node based on the node selection `kubernetes.io/arch: amd64` specified in the deployment specification.
```yaml
nodeSelector:
  kubernetes.io/arch: amd64
```

Validate if the Amazon EKS Addons Pods are running in the Managed Node Group and the `workload-graviton` application Pods are running on Karpenter provisioned Nodes.

```bash
$ kubectl get pods -A -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

```text
NAME                            NODE
workload-x86-578c59cf4f-mlkt2   ip-10-1-24-125.ec2.internal
workload-x86-578c59cf4f-w6dmj   ip-10-1-24-125.ec2.internal
karpenter-54699cc6d7-4cbgp      ip-10-1-40-237.ec2.internal
karpenter-54699cc6d7-ld8t6      ip-10-1-2-77.ec2.internal
aws-node-pnfsw                  ip-10-1-40-237.ec2.internal
aws-node-r7vd2                  ip-10-1-24-125.ec2.internal
aws-node-vj8p4                  ip-10-1-2-77.ec2.internal
coredns-55d797b4f9-6d29r        ip-10-1-2-77.ec2.internal
coredns-55d797b4f9-lfzdm        ip-10-1-40-237.ec2.internal
eks-pod-identity-agent-l6dr5    ip-10-1-24-125.ec2.internal
eks-pod-identity-agent-rhd7x    ip-10-1-2-77.ec2.internal
eks-pod-identity-agent-sxzm6    ip-10-1-40-237.ec2.internal
kube-proxy-nffcj                ip-10-1-24-125.ec2.internal
kube-proxy-wnnfz                ip-10-1-40-237.ec2.internal
kube-proxy-ww6kc                ip-10-1-2-77.ec2.internal
```

## Watch Karpenter's controller logs

Watch the karpenter's controller logs with:

```bash
$ kubectl logs -f -n <karpenter_namespace> -l app.kubernetes.io/name=karpenter -c controller
```

### Tear Down & Clean-Up

Because Karpenter manages the state of node resources outside of Terraform, Karpenter created resources will need to be de-provisioned first before removing the remaining resources with Terraform.

1. Remove the example deployment created above and any nodes created by Karpenter

```bash
$ kubectl delete deployment workload-graviton
```

2. Remove the resources created by Terraform

```bash
$ terragrunt -working-dir=-/live run-all destroy -auto-approve
```
