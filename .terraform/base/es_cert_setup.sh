#This code must be run on creation of cluster to generate certificates for use with elasticsearch


ELASTICSEARCH_IMAGE="docker.elastic.co/elasticsearch/elasticsearch:8.5.1"

docker pull $ELASTICSEARCH_IMAGE

docker rm -f elastic-helm-charts-certs || true
rm -f elastic-certificates.p12 elastic-certificate.pem elastic-certificate.crt elastic-stack-ca.p12 || true
docker run --name elastic-helm-charts-certs -i -w /tmp \
    $ELASTICSEARCH_IMAGE \
    /bin/sh -c " \
        elasticsearch-certutil ca --out /tmp/elastic-stack-ca.p12 --pass '' && \
        elasticsearch-certutil cert --name elasticsearch-master --ip 35.189.39.191 --dns elasticsearch-master --ca /tmp/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /tmp/elastic-certificates.p12" && \
docker cp elastic-helm-charts-certs:/tmp/elastic-certificates.p12 ./ && \
docker rm -f elastic-helm-charts-certs && \
openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -out elastic-certificate.pem && \
openssl x509 -outform der -in elastic-certificate.pem -out elastic-certificate.crt && \
kubectl create secret generic elastic-certificates --from-file=elastic-certificates.p12 || true && \
kubectl create secret generic elastic-certificate-pem --from-file=elastic-certificate.pem || true && \
kubectl create secret generic elastic-certificate-crt --from-file=elastic-certificate.crt || true
#rm -f elastic-certificates.p12 elastic-certificate.pem elastic-certificate.crt elastic-stack-ca.p12