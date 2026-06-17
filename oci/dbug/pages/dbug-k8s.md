# dbug-k8s

> Kubernetes debugging patterns with kubectl debug, k9s, and calicoctl.

- Attach to an existing pod's network namespace:

`kubectl debug -it {{pod}} --image codo/dbug --target {{container}} -- fish`

- Debug a node directly:

`kubectl debug -it node/{{node}} --image codo/dbug -- fish`

- Run a standalone debug pod:

`kubectl run dbug --rm -it --image codo/dbug -- fish`

- Run a debug pod in a specific namespace:

`kubectl run dbug --rm -it -n {{namespace}} --image codo/dbug -- fish`

- Launch k9s cluster TUI:

`k9s`

- Check Calico node status:

`calicoctl node status`

- View Calico IP pool configuration:

`calicoctl get ippool -o wide`

- Inspect Calico network policies:

`calicoctl get networkpolicy -o yaml -A`
