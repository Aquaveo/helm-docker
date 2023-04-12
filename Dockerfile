FROM google/cloud-sdk:426.0.0-alpine

# Override the *_VERSION variables during build time to manually set the versions pulled

ARG HELM_VERSION=3.11.2
ARG KUBECTL_VERSION=1.26.3
ARG GCLOUD_VERSION=426.0.0

# Need to set your HELM_REPO_HOST
# ENV HELM_REPO_HOST=https://helm...

ADD requirements.txt /tmp/
RUN set -x \
 && apk add --update --no-cache curl ca-certificates py-pip \
 # Install Kubectl
 && curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl \
 && chmod +x /usr/bin/kubectl \
 # Install Helm
 && curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xvz \
 && mv linux-amd64/helm /usr/bin/helm  \
 && chmod +x /usr/bin/helm  \
 # Cleanup
 && rm -f /var/cache/apk/* \
 # Install python requirements
 && pip install -r /tmp/requirements.txt

# Add MyCA to trust list
# Setup Kubectl
# Setup Helm

# Add Helper Utils
ADD utilities/* /usr/bin/
RUN chmod -R 775 /usr/bin

WORKDIR /apps
CMD ["helm","--help"]
