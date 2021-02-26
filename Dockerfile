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
  zpm "install restforms2-ui" \
  zpm "install dsw" \
  do EnableDeepSee^%SYS.cspServer("/csp/irisapp/") \
  zpm "install csvgen" \
  do $System.OBJ.LoadDir("/opt/irisapp/src","ck",,1) \
  do ##class(Form.Util.Init).populateTestForms() \
  zn "%SYS" \
  write "Modify forms application security...",! \
  set webName = "/forms" \
  set webProperties("AutheEnabled") = 16416 \
  set webProperties("CookiePath") = "/forms/" \
  set webProperties("MatchRoles") = ":%DB_%DEFAULT" \
  set webProperties("DispatchClass") = "dc.irisrad.rest.Main" \
  set sc = ##class(Security.Applications).Modify(webName, .webProperties) \
  # if sc<1 write $SYSTEM.OBJ.DisplayError(sc) \
  write "Add Role for CSPSystem User...",! \
  set sc=##class(Security.Users).AddRoles("CSPSystem","%DB_%DEFAULT") \ 
  zpm "load /opt/irisapp/ -v" 

# bringing the standard shell back
SHELL ["/bin/bash", "-c"]
