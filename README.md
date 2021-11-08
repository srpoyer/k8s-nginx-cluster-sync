# k8s-nginx-cluster-sync

## Configuration and guidance on building an NGINX+ Dockerfile for an API Gateway deployment in Kubernetes, syncing memory zones for cluster wide rate limiting based on JWT claims

You can use this content to create an API gateway deployment and a dummy API endpoint deployment in Kubernetes with NGINX+.  If you already have an API runtime application then you can just modify the nginx-confd-cm.yaml ConfigMap to tailor it to your environment.  

The NGINX+ features used include `zone_sync` and `auth_jwt`.  `zone_sync` is a feature to synchronize all of the shared memory zones on each NGINX+ instance.  It has multiple uses but in this case is used for syncing rate limit data.  `auth_jwt` is used to validate a JWT token and authenticate the client.  Since JWT claims are converted to NGINX variables, the JWT claims can be used as a key for rate limiting so you get per-client rate limiting without having to rely on client IP, for example.  

Here is what the setup looks like:  

![diagram](artifacts/APIGW%20Architecture.jpeg)

NGINX+ is deployed as an API Gateway deployment.  That deployment is exposed with a LoadBalancer service.  The zone service is a headless service used to create a dynamic list of pods for zone synchronization.  There are three configmaps for this deployment.  The "confd" configmap configures the http level loadbalancer, JWT authentication and client rate limiting.  The "streamd" config map configures the zone synchronization and the "conf" configmap contains the JWK for validating the JWT.  

In addition to the API Gateway deployment, NGINX+ is also acting as the API runtime in the "nginx-app" deployment.  All it does is return a 200 along with a brief "success" message. 

For both deployments you will need to edit the deployment's image to point to your own, private NGINX+ docker image.

Once the apigw deployment has been created, expose it with:

```bash
kubectl expose deploy -n nginx nginx-apigw --type=LoadBalancer
```

Note: This assumes you are deploying in a cloud environment or have some kind of load balancer fronting your cluster. 

## Dockerfile

I used an Ubuntu 20-based Docker image for my testing.  You can find instructions for creating an NGINX+ Docker image here: <https://github.com/armsultan/nginx-plus-dockerfiles>.  I used the Dockerfile from this repo "as is" but made changes to the default nginx.conf file to enable the stream module.  Stream is used to perform the zone synchronization.  The nginx.conf file I used is located in the Docker directory.  

To create the NGINX+ Docker image you will need either a purchased or trial license from F5/NGINX.  Please only upload the image to a **private** registry or you will be in violation of accepted T's & C's.  

## Testing

After creating the apigw deployment and creating the zone-svc, check the logs of one of the pods.  You should see entries with the string "connected to peer", indicating that this NGINX instance is sharing zone information with other pods in the cluster.  

There are two scripts in the testing directory.  
- load-jwt.sh
- load-auth.sh

load-jwt.sh runs 60 requests to your test environment.  In my testing this takes about 3 seconds and I see 7 successful requests on average with the remaining requests returning 503's.  The 503's occur when the client exceeds the configured 2 requests per second limit.  The script passes a sample jwt as a bearer token in the Authorization header, also found in the testing directory in the file test.jwt.

load-auth.sh is similar to the jwt script except that it uses a header called "auth" as the rate limiting key.  

For the scripts to work, set the content of the cloudlb.txt file to the entrypoint FQDN to your cluster.  