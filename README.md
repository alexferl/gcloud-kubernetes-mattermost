# gcloud-kubernetes-mattermost
This is a basic set of resources to get [Mattermost](https://www.mattermost.org/) 4.3.x+ running on [Google Container Engine](https://cloud.google.com/container-engine/) with TLS. This guide assumes you already have a working Container Engine cluster setup.

1. Clone the repo:
```console
$ git clone https://github.com/admiralobvious/gcloud-kubernetes-mattermost.git && cd gcloud-kubernetes-mattermost
```
2. Set the username and password for the PostgreSQL database:
```console
$ kubectl create secret generic postgres-creds --from-literal=username=<yourusername> --from-literal=password=<yourpassword>
```
3. Edit any Mattermost config you want in `config.template.json` and then set the username and password for the PostgreSQL database by editing the following line:
```console
"postgres://<yourusername>:<yourpassword>@mattermost-pg:5432/mattermost?sslmode=disable&connect_timeout=10"
```
4. Create the ConfigMap:
```console
$ kubectl create configmap mattermost-config --from-file=./config.template.json
```
5. Create persistent disks for PostgreSQL and Mattermost assets:
```console
$ gcloud compute disks create "mattermost-postgres" --size "20GB" --type "pd-ssd"
$ gcloud compute disks create "mattermost-assets" --size "20GB" --type "pd-ssd"
```
6. Create the PostgreSQL deployment and service:
```console
$ kubectl create -f mattermost-pg-deployment.yaml
$ kubectl create -f mattermost-pg-service.yaml
```
7. Create the Mattermost deployment and service:
```console
$ kubectl create -f mattermost-app-deployment.yaml
$ kubectl create -f mattermost-app-service.yaml
```
8. TLS and domain name:

Add your own certificate and private key to this folder. Their default names are `server.crt` and `server.key`.
If you want to change their names, make sure you edit the `Dockerfile` and `Caddyfile`.

You will also want to edit the `Caddyfile` and replace `mm.example.com` with your own domain.

Alternatively, Caddy supports [Automatic HTTPS](https://caddyserver.com/docs/automatic-https) with [Let's Encrypt](https://letsencrypt.org/) so you may use that instead. If you do, make sure you remove the certificate and key from the `Dockerfile` and `Caddyfile` and add the appropriate config to the `Caddyfile` for Automatic HTTPS.

9. Build and push the [Caddy](https://caddyserver.com/) reverse proxy container:
```console
$ docker build -t gcr.io/<project_id>/mattermost-lb .
$ gcloud docker push gcr.io/<project_id>/mattermost-lb:latest
```
10. Create the reverse proxy deployment and the load-balancer service (make sure you change the `<project_id>` in the deployment file: 
```console
$ kubectl create -f mattermost-lb-deployment.yaml
$ kubectl create -f mattermost-lb-service.yaml
```
11. Grab the External IP to update your DNS:
```console
$ kubectl get svc
```

Why not use Ingress (HTTP L7) instead of Load-Balancer (Network L4)?
----------------------------------------------------------------
The GCLB Ingress currently does not support (and probably never will) load-balancing WebSockets which Mattermost requires.

Credits
-------
Based on: https://github.com/AcalephStorage/kubernetes-mattermost
