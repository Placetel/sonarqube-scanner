FROM golang:1.21-alpine@sha256:2414035b086e3c42b99654c8b26e6f5b1b1598080d65fd03c7f499552ff4dc94 as build
RUN apk add --no-cache --update git
RUN mkdir -p /go/src/github.com/diegopereiraeng/harness-cie-sonarqube-scanner
WORKDIR /go/src/github.com/diegopereiraeng/harness-cie-sonarqube-scanner 
COPY *.go ./
COPY *.mod ./

RUN go env GOCACHE 

RUN go get github.com/sirupsen/logrus
RUN go get github.com/pelletier/go-toml/cmd/tomll
RUN go get github.com/urfave/cli
RUN go get github.com/joho/godotenv
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o harness-sonar

FROM amazoncorretto:17.0.8-alpine3.18@sha256:3f318f7f7d19226931e2137785bda1312d2ed4536e98482f78d173ab364fb185

ARG SONAR_VERSION=5.0.1.3006
ARG SONAR_SCANNER_CLI=sonar-scanner-cli-${SONAR_VERSION}
ARG SONAR_SCANNER=sonar-scanner-${SONAR_VERSION}

# RUN apt-get update \
#     && apt-get install -y nodejs curl \
#     && apt-get clean

RUN apk --no-cache --update add nodejs curl unzip git

COPY --from=build /go/src/github.com/diegopereiraeng/harness-cie-sonarqube-scanner/harness-sonar /bin/
WORKDIR /bin

RUN curl https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/${SONAR_SCANNER_CLI}.zip -so /bin/${SONAR_SCANNER_CLI}.zip
RUN unzip ${SONAR_SCANNER_CLI}.zip \
    && rm ${SONAR_SCANNER_CLI}.zip 

ENV PATH $PATH:/bin/${SONAR_SCANNER}/bin

ENTRYPOINT /bin/harness-sonar
