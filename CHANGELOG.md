## 0.4.0
* Remove Faraday dependency.

## 0.3.2
* Add a unique hash of the configuration options to the kubeconfig path.
* Update README with new environment syntax.
* Use `linode-block-storage-retain` storage class to prevent losing block storage volumes when PVCs are deleted.

## 0.3.1
* Avoid `instance_eval`ing a `nil` block during configuration.

## 0.3.0
* Accept `environment` instead of `definition` instances.

## 0.2.0
* Remove dependency on rails app.
* Refresh kubeconfig in more places.
  - Before setup
  - Before deploy

## 0.1.0
* Birthday!
