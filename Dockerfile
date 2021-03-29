# ARG IMAGE=store/intersystems/iris-community:2020.1.0.204.0
# ARG IMAGE=intersystemsdc/iris-community:2020.1.0.209.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.2.0.204.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.4.0.524.0-zpm
# ARG IMAGE=store/intersystems/iris-community-arm64:2020.3.0.221.0
FROM $IMAGE

USER root

WORKDIR /opt/irisbuild
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisbuild
USER ${ISC_PACKAGE_MGRUSER}

COPY  src src
COPY module.xml module.xml
COPY iris.script iris.script

RUN iris start IRIS \
	&& iris session IRIS < iris.script \
    && iris stop IRIS quietly


USER root
RUN chown -R irisuser:irisuser /opt
RUN chown -R irisuser:irisuser /usr/irissys/csp/forms
