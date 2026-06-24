# dbug-k8s

> Kubernetes debugging patterns running the dbug image via kubectl debug/run.

- Attach to an existing pod's network namespace:

`kubectl debug -it {{pod}} --image codo/dbug --target {{container}} -- fish`

- Debug a node directly:

`kubectl debug -it node/{{node}} --image codo/dbug -- fish`

- Run a standalone debug pod:

`kubectl run dbug --rm -it --image codo/dbug -- fish`

- Run a debug pod in a specific namespace:

`kubectl run dbug --rm -it -n {{namespace}} --image codo/dbug -- fish`
