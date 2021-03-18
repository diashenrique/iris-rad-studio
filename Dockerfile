# ARG IMAGE=store/intersystems/iris-community:2020.1.0.204.0
# ARG IMAGE=intersystemsdc/iris-community:2020.1.0.209.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.2.0.204.0-zpm
# ARG IMAGE=store/intersystems/iris-community-arm64:2020.3.0.221.0
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
COPY irissession.sh /
RUN chmod +x /irissession.sh

RUN mkdir -p /tmp/deps \
 && cd /tmp/deps \
 && wget -q https://pm.community.intersystems.com/packages/zpm/latest/installer -O zpm.xml

USER ${ISC_PACKAGE_MGRUSER}

COPY  Installer.cls .
COPY  src src
SHELL ["/irissession.sh"]

RUN \
  do $SYSTEM.OBJ.Load("Installer.cls", "ck") \
  set sc = ##class(App.Installer).setup() \
  do $system.OBJ.Load("/tmp/deps/zpm.xml", "ck") \
  zn "IRISAPP" \
  zpm "install restforms2" \
  zpm "install dsw" \
  do EnableDeepSee^%SYS.cspServer("/csp/irisapp/") \
  zpm "install csvgen" \
  do $System.OBJ.LoadDir("/opt/irisapp/src","ck",,1) \
  do ##class(Form.Util.Init).populateTestForms() \
  zn "%SYS" \
  write "Installing routinies for delegated authentication...",! \
  do $System.OBJ.Load("/opt/irisapp/src/IRISRADAUTHENTICATE.mac","ck",,1) \
  do $System.OBJ.Load("/opt/irisapp/src/ZAUTHENTICATE.mac","ck",,1) \
  set sc = ##Class(Security.System).Get("SYSTEM",.Properties) \
  zw sc \
  set Properties("AutheEnabled") = $ZB(Properties("AutheEnabled"),8192,7) \
  set sc = ##Class(Security.System).Modify("SYSTEM",.Properties) \
  write "Creating IRIS RAD rest application...",! \
  set webName = "/irisrad" \
  set webProperties("NameSpace") = "IRISAPP" \
  set webProperties("IsNameSpaceDefault") = 0 \
  set webProperties("AutheEnabled") = 8224 \
  set webProperties("CookiePath") = "/irisrad/" \
  set webProperties("MatchRoles") = ":%DB_%DEFAULT" \
  set webProperties("DispatchClass") = "dc.irisrad.rest.Main" \
  set sc = ##class(Security.Applications).Create(webName, .webProperties) \
  kill webProperties \
  write "Modify /csp/irisapp application path...",! \
  set webName = "/csp/irisapp" \
  set webProperties("Path") = "/opt/irisapp/src/csp/" \
  set sc = ##class(Security.Applications).Modify(webName, .webProperties) \
  write "Add Role for CSPSystem User...",! \
  set sc=##class(Security.Users).AddRoles("CSPSystem","%DB_%DEFAULT") 

# bringing the standard shell back
SHELL ["/bin/bash", "-c"]

USER root
RUN chown -R irisuser:irisuser /opt
RUN chown -R irisuser:irisuser /usr/irissys/csp/forms
