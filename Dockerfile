FROM python:3.7-alpine

# Override the *_VERSION variables during build time to manually set the versions pulled

ARG HELM_VERSION=3.0.0
ARG KUBECTL_VERSION=1.15.0

ENV HELM_REPO_HOST=https://helm.aquaveo.com

ENV K8S_USER=admin \
    K8S_PASS=none \
    K8S_NS=default \
    K8S_CLUSTER=staging-cluster

ADD requirements.txt /tmp/
RUN set -x \
 && apk add --update --no-cache curl gnupg1 ca-certificates \
 # Install Kubectl
 && curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl \
 && chmod +x /usr/bin/kubectl \
 # Install Helm
 && curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz |tar xvz \
 && mv linux-amd64/helm /usr/bin/helm  \
 && chmod +x /usr/bin/helm  \
 && rm -rf linux-amd64  \
 && rm -f /var/cache/apk/* \
 # Install python requirements
 && pip install -r /tmp/requirements.txt
# Setup Helm
RUN helm init \
 && helm repo add aquaveo $HELM_REPO_HOST \
 && mkdir -p /root/.helm
# Add Helper Utils
ADD utilities/* /usr/bin/
RUN chmod 775 /usr/bin/*

WORKDIR /apps
CMD ["helm","--help"]
