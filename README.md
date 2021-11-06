# k8s-nginx-cluster-sync

## Configuration and Dockerfile to run NGINX+ as an API Gateway, syncing memory zones for rate limiting

You can use this content to create an API gateway deployment and a dummy API endpoint deployment in Kubernetes with NGINX+.  If you already have an API runtime application then you can just modify the nginx-confd-cm.yaml ConfigMap to tailor it to your environment.  

The NGINX+ features used include `zone_sync` and `auth_jwt`.  `zone_sync` is a feature to synchronize all of the shared memory zones on each NGINX+ instance.  It has multiple uses but in this case is used for syncing rate limit data.  `auth_jwt` is used to validate a JWT token and authenticate the client.  Since JWT claims are converted to NGINX variables, the JWT claims can be used as a key for rate limiting so you get per-client rate limiting without having to rely on client IP, for example.  

Here is what the setup looks like:  
![alt text](artifacts/APIGW%20Architecture.jpeg)

## Dockerfile

I used an Ubuntu 20-based Docker file for my testing.  You can find instructions for creating an NGINX+ Docker image here: <https://github.com/armsultan/nginx-plus-dockerfiles>.  I used the Dockerfile from this repo "as is" but made changes to the default nginx.conf file to enable the stream module.  Stream is used to perform the zone synchronization.  The nginx.conf file I used is in the Docker directory.  

To create the NGINX+ Docker image you will need either a purchased or trial license from F5/NGINX.  Please only store the image in a **private** registry or you will be in violation of accepted T's & C's.  

In addition to the API Gateway deployment.  NGINX+ is also used to act as the API runtime in the "nginx-app" deployment.  All it does is return a 200 along with a brief "success" message. You will need to edit the deployment's image to point to your own, private NGINX+ docker image.

The zone service is a headless service that is used to create a dynamic list of pods for zone synchronization.  

Once the apigw deployment has been created, expose it with:

```
kubectl expose deploy -n nginx nginx-apigw --type=LoadBalancer
```

Note: This assumes you are deploying in a cloud environment.  
