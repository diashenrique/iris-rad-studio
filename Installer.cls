Include %occInclude

Class App.Installer
{

XData setup
{
<Manifest>
  <Default Name="NAMESPACE" Value="IRISAPP"/>
  <Default Name="DBNAME" Value="IRISAPP"/>
  <Default Name="APPPATH" Dir="/opt/irisapp" />
  <Default Name="SOURCESPATH" Dir="${APPPATH}/src" />
  <Default Name="CSPURL" Value="/csp/irisapp" /> 
  <Default Name="RESOURCE" Value="%DB_${DBNAME}" /> 
  <Default Name="RESTPATH" Value="/csp/irisapp/api" /> 
  <Default Name="REST_UNAUTH_APPNAME" Value="/irisrad/unauth" /> 

  <Resource Name="${RESOURCE}" Description="Resource for Message Viewer application" Permission="RW"/>

  <!-- <Role Name="IRIS_RAD_UNAUTH" Description="Privileges for unauthenticated users in IRIS RAD" Resources="${RESOURCE}" RolesGranted=""></Role> -->
  <Role Name="IRIS_RAD_UNAUTH" Description="Privileges for unauthenticated users in IRIS RAD" Resources="%DB_IRISAPP" RolesGranted=""></Role>

  <Namespace Name="${NAMESPACE}" Code="${DBNAME}" Data="${DBNAME}" Create="yes" Ensemble="0">
    <Configuration>
      <Database Name="${DBNAME}" Dir="${APPPATH}/data" Create="yes" Resource="${RESOURCE}" MountAtStartup="true"/>
    </Configuration>
    <CSPApplication Url="${CSPURL}" Directory="${APPPATH}/csp/" ServeFiles="1" Recurse="1" Grant="%DB_${NAMESPACE},%SQL" AuthenticationMethods="8192" />
    <Import File="${SOURCESPATH}/cls" Recurse="1"/>
  </Namespace>

  <Invoke Class="App.Installer" Method="InstallZPM">
    <Arg Value="restforms2"/>
    <Arg Value="${NAMESPACE}"/>
  </Invoke>

  <Invoke Class="App.Installer" Method="InstallZPM">
    <Arg Value="dsw"/>
    <Arg Value="${NAMESPACE}"/>
  </Invoke>

  <Invoke Class="App.Installer" Method="InstallZPM">
    <Arg Value="csvgen"/>
    <Arg Value="${NAMESPACE}"/>
  </Invoke>

  <Invoke Class="App.Installer" Method="createRESTApp">
    <Arg Value="${RESTPATH}"/>
    <Arg Value="${NAMESPACE}"/>
  </Invoke>

  <!-- create a web application for forms api -->
  <Invoke Class="App.Installer" Method="createRESTApp">
    <Arg Value="${REST_UNAUTH_APPNAME}"/>
    <Arg Value="${NAMESPACE}"/>
    <Arg Value="dc.irisrad.rest.UnAuth"/>
    <Arg Value=":IRIS_RAD_UNAUTH"/>
    <Arg Value="64"/>
  </Invoke>

  <Invoke Class="App.Installer" Method="EnableCSPApp">
    <Arg Value="/csp/irisapp/"/>
    <Arg Value="${NAMESPACE}"/>
  </Invoke>

  <Namespace Name="${NAMESPACE}">
    <Import File="${SOURCESPATH}" Flags="ck" Recurse="1" IgnoreErrors="1">
    </Import>

    <Invoke Class="Form.Util.Init" Method="populateTestForms">
    </Invoke>

    <Log Text="Installing RAD superuser" Level="0"></Log>
    <Invoke Class="dc.irisrad.data.RADUser" Method="CreateSuperUser">
    </Invoke>
  </Namespace>
  
  <Log Text="Installing routinies for delegated authentication..." Level="0"></Log>
  <Invoke Class="App.Installer" Method="EnableDelegatedAuth">
  </Invoke>
  <Import File="${SOURCESPATH}/IRISRADAUTHENTICATE.mac" Flags="ck">
  </Import>
  <Import File="${SOURCESPATH}/ZAUTHENTICATE.mac" Flags="ck">
  </Import>

  <Log Text="Creating IRIS RAD rest application..." Level="0"></Log>
  <Invoke Class="App.Installer" Method="createRESTApp">
    <Arg Value="/irisrad"/>
    <Arg Value="${NAMESPACE}"/>
    <Arg Value="dc.irisrad.rest.Main"/>
    <Arg Value=":%DB_%DEFAULT"/>
    <Arg Value="8192"/>
  </Invoke>

  <Log Text="Modify /csp/irisapp application path..." Level="0"></Log>
  <Invoke Class="App.Installer" Method="FixAppCSPPath">
  </Invoke>

  <Log Text="Add Role for CSPSystem User..." Level="0"></Log>
  <Invoke Class="Security.Users" Method="AddRoles">
    <Arg Value="CSPSystem"/>
    <Arg Value="%DB_%DEFAULT"/>
  </Invoke>

  <Log Text="Add Role for unauthenticated access..." Level="0"></Log>
  <Invoke Class="App.Installer" Method="GrantRolesForUnauthAcess">
    <Arg Value="${NAMESPACE}"/>
  </Invoke>
</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

ClassMethod SetAppProperties(pApp As %String, pPath As %String) As %Status
{
  New $Namespace
  Set $Namespace = "%SYS"

  Set tSC = ##class(Security.Applications).Get(pApp, .webProperties)

  If $$$ISERR(tSC) {
    Quit tSC
  }

  Set webProperties("Path") = pPath
  Set webProperties("Resource") = "" 
  Set webProperties("AutheEnabled") = 32 
  Set webProperties("AutoCompile") = 1 
  Set webProperties("ServeFiles") = 1 
  Set webProperties("iKnowEnabled") = 1 
  Set webProperties("DeepSeeEnabled") = 1 

  Set tSC = ##class(Security.Applications).Modify(pApp, .webProperties)

  Quit tSC
}

ClassMethod CompileCSP(pApp As %String, pNamespace As %String) As %Status
{
  New $Namespace
  Set $Namespace = pNamespace

  Set list(pApp_"/*.csp") = "" 
  Do $System.OBJ.CompileList(.list,"ck")

  Quit $$$OK
}

/*
ClassMethod createRESTApp(appName As %String, pNamespace As %String) As %Status
{
  #dim sc As %Status = $$$OK

  New $Namespace
  Set $Namespace = "%SYS"

  If '##class(Security.Applications).Exists(appName) {
    Set props("AutheEnabled") = $$$AutheUnauthenticated
    Set props("NameSpace") = pNamespace
    Set props("IsNameSpaceDefault") = $$$NO
    Set props("DispatchClass") = "diashenrique.REST.Dispatch"
    Set props("MatchRoles")=":%All"
    Set sc = ##class(Security.Applications).Create(appName, .props)
  }
  Quit sc
}
*/
ClassMethod CreateFavorite() As %Status
{
  New $Namespace
  Set $Namespace = "IRISAPP"

  Set status = ##class(diashenrique.util.Favorite).%AddFavorite("AnalyticsPortal","/csp/irisapp/analytics.csp")
  
  Quit status
}

ClassMethod createRESTApp(pAppName As %String, pNamespace As %String, pDispatchClass As %String, pRoles As %String, pAutheEnabled As %Integer = 8192) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"
    #; Set props("AutheEnabled") = 8224
    Set props("AutheEnabled") = pAutheEnabled
    Set props("NameSpace") = pNamespace
    Set props("IsNameSpaceDefault") = $$$NO
    Set props("DispatchClass") = pDispatchClass
    Set props("MatchRoles") = pRoles
    If '##class(Security.Applications).Exists(pAppName) {
      Set sc = ##class(Security.Applications).Create(pAppName, .props)
    }
    Set app = ##class(Security.Applications).%OpenId(pAppName)
    Do app.MatchRoles.Clear()
    Do app.MatchRoles.Insert(props("MatchRoles"))
    Set sc = app.%Save()
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Set $NAMESPACE = originalNS
  Return sc
}

/// Grant access to all tables which must be accessed by unauthorized users
ClassMethod GrantTablesRoleUnAuth(pNamespace As %String = "%SYS", ByRef pRoleInfoArray) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    ZNspace pNamespace

    For i=1:1:pRoleInfoArray {
      Set stmt = ##class(%SQL.Statement).%New()
      // GRANT * ON Data.Countries TO %DB_TEST3_APP
      Set sql = "GRANT "_$LG(pRoleInfoArray(i), 1)_" ON "_$LG(pRoleInfoArray(i), 2)_" TO "_$LG(pRoleInfoArray(i), 3)
      zw sql
      $$$TOE(st, stmt.%Prepare(sql))
      Set rs = stmt.%Execute()
      Do rs.%Next()
      Throw:((rs.%SQLCODE '= 0) && (rs.%SQLCODE '= 100)) ##class(%Exception.SQL).CreateFromSQLCODE(rs.%SQLCODE, %msg)
      Kill rs
      Kill stmt
    }
  }
  Catch ex {
    Set sc = ex.AsStatus()
  }
  ZNspace originalNS
  Return sc
}

ClassMethod InstallZPM(pPackageName As %String, pNamespace As %String = "") As %Status
{
  zw pPackageName,pNamespace
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    If (pNamespace '= "") {
      New $NAMESPACE
      Set $NAMESPACE = pNamespace
    }
    ZPm "install "_pPackageName
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  zw sc
  Set $NAMESPACE = originalNS
  Return sc
}

ClassMethod EnableCSPApp(pCSPApp As %String, pNamespace As %String = "") As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    If (pNamespace '= "") {
      New $NAMESPACE
      Set $NAMESPACE = pNamespace
    }
  Do EnableDeepSee^%SYS.cspServer(pCSPApp)
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Set $NAMESPACE = originalNS
  Return sc
}

ClassMethod EnableDelegatedAuth() As %Status
{
  Set sc = $$$OK
  set sc = ##Class(Security.System).Get("SYSTEM",.Properties)
  zw sc
  set Properties("AutheEnabled") = $ZB(Properties("AutheEnabled"), 8192, 7)
  set sc = ##Class(Security.System).Modify("SYSTEM",.Properties)
  Return sc
}

ClassMethod FixAppCSPPath() As %Status
{
  Set sc = $$$OK
  set webName = "/csp/irisapp"
  set webProperties("Path") = "/opt/irisapp/src/csp/"
  set sc = ##class(Security.Applications).Modify(webName, .webProperties)
  Return sc
}

ClassMethod GrantRolesForUnauthAcess(pNamespace As %String) As %Status
{
  Set sc = $$$OK
  Kill roleInfoArray
  Set roleInfoArray($I(roleInfoArray)) = $LB("SELECT,INSERT", "dc_irisrad_default.UserForm", "IRIS_RAD_UNAUTH")
  Set roleInfoArray($I(roleInfoArray)) = $LB("SELECT,INSERT", "dc_irisrad_data.RADUser", "IRIS_RAD_UNAUTH")
  Set sc = ##class(App.Installer).GrantTablesRoleUnAuth(pNamespace, .roleInfoArray)
  Return sc
}

}
