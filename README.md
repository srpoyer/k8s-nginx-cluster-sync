# k8s-nginx-cluster-sync
## Configuration and Dockerfile to run NGINX+ as an API Gateway, syncing memory zones for rate limiting

You can use this content to create an API gateway deployment in Kubernetes with NGINX+.  

The NGINX+ features used include `zone_sync` and `auth_jwt`.  `zone_sync` is a feature to synchronize all of the shared memory zones on each NGINX+ instance.  It has multiple uses but in this case is used for syncing rate limit data.  `auth_jwt` is used to validate a JWT token and authenticate the client.  Since JWT claims are converted to NGINX variables, the JWT claims can be used as a key for rate limiting so you get per-client rate limiting without having to rely on client IP, for example.  

Here is what the setup looks like:  
![alt text](artifacts/APIGW%20Architecture.jpeg)

In addition to the API Gateway deployment.  NGINX+ is also used to act as the API runtime in the "API Runtime" deployment.  All it does is return a 200 along with a brief "success" message.   

The zone service is a headless service that is used to create a dynamic list of pods for zone synchronization.  

Once the apigw deployment has been created, expose it with:

`kubectl expose deploy -n nginx nginx-apigw --type=LoadBalancer`

Note: This assumes you are deploying this in a cloud environment.  