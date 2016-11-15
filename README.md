# gcloud-kubernetes-mattermost
Mattermost on Google Cloud's Container Engine

This is a basic set of resources to get Mattermost running on Google Container Engine with TLS.

#### Clone the repo:
```console
$ git clone https://github.com/admiralobvious/gcloud-kubernetes-mattermost.git && cd gcloud-kubernetes-mattermost
```

#### Set the username and password for the PostgreSQL database:
```console
$ kubectl create secret generic postgres-creds --from-literal=username=<yourusername> --from-literal=password=<yourpassword>
```

#### Edit any Mattermost config you want in `config.template.json` and then set the username and password for the PostgreSQL database by editing the following line:
```console
"postgres://<yourusername>:<yourpassword>@mattermost-pg:5432/mattermost?sslmode=disable&connect_timeout=10"
```

#### Create the ConfigMap:
```console
$ kubectl create configmap mattermost-config --from-file=./config.template.json
```

#### Create persistent disks for PostgreSQL and Mattermost assets:
```console
$ gcloud compute disks create "mattermost-postgres" --size "20GB" --zone "us-east1-d" --type "pd-ssd"
$ gcloud compute disks create "mattermost-assets" --size "20GB" --zone "us-east1-d" --type "pd-ssd"
```

#### Create the PostgreSQL deployment and service:
```console
$ kubectl create -f mattermost-pg-deployment.yaml
$ kubectl create -f mattermost-pg-service.yaml
```

#### Create the Mattermost deployment and service:
```console
$ kubectl create -f mattermost-app-deployment.yaml
$ kubectl create -f mattermost-app-service.yaml
```

#### TLS and domain name:

Add your own certificate and private key to this folder. Their default names are `server.crt` and `server.key`.
If you want to change their names, make sure you edit the `Dockerfile` and `Caddyfile`.

You will also want to edit the `Caddyfile` and replace `mm.example.com` with your own domain.

#### Build and push the reverse proxy container:
```console
$ docker build -t gcr.io/<project_id>/mattermost-lb
$ gcloud docker push gcr.io/<project_id>/mattermost-lb:latest
```

#### Create the reverse proxy deployment and the Load-Balancer service: 

```console
$ kubectl create -f mattermost-lb-deployment.yaml
$ kubectl create -f mattermost-lb-service.yaml
```

#### Grab the External IP to update your DNS:

```console
$ kubectl get svc
```

Why not use Ingress (HTTP L7) instead of Load-Balancer (Network L4)?
----------------------------------------------------------------
Ingress currently does not support load-balancing WebSockets which Mattermost requires.

Credits
-------
Based on: https://github.com/AcalephStorage/kubernetes-mattermost
