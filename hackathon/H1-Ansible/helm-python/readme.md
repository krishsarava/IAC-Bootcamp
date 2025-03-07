## Commands to deploy using helm 

1. check the synatx 
```
helm lint nginx-1-chart
```
* make sure to be out of the directory "nginx-1-chart"

2.  Render Templates To check how your Helm templates will render before applying them:
```
helm template my-release nginx-1-chart/
```

3.  Dry Run the Chart (helm install --dry-run)
```
helm install my-release nginx-1-chart/ --dry-run --debug
```
Note: make sure you are able to connect to the kube cluster 

4. Validate Against Kubernetes (kubectl apply --dry-run)
```
helm template my-release nginx-1-chart/ | kubectl apply --dry-run=client -f -
```
* This ensures that the Kubernetes API accepts the generated manifests.

5. Finally to deploy 
```
helm install my-release nginx-1-chart/
```

6.  Debugging with helm get manifest
```
helm get manifest my-release
```
