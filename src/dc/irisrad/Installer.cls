Include %occInclude

Class dc.irisrad.Installer
{

/// Default system namespace
Parameter DefaulSystemNS = "IRISAPP";

XData setup
{
<Manifest>
  <!-- create resources for app database -->
  <Resource Name="%DB_${DBNAME}" Description="Resource for application ${APPNAME}" Permission="RW"/>

  <!-- create app namespace -->
  <Namespace Name="${NAMESPACE}" Code="${DBNAME}" Data="${DBNAME}" Create="yes" Ensemble="0">
    <!-- create app database -->
    <Configuration>
      <Database Name="${DBNAME}" Dir="${DBPATH}/data" Create="yes" Resource="${RESOURCE}" MountAtStartup="true"/>
    </Configuration>

    <!-- import installer into new namespace -->
    <Import File="${FORMSCLASSPATH}/dc/irisrad/Installer.cls" Flags="c">
    </Import>
    
    <!-- create a directory for new app web application -->
    <Invoke Class="dc.irisrad.Installer" Method="CreateDirectory">
      <Arg Value="${NAMESPACE_CSPAPPPATH}"/>
    </Invoke>
    
    <!-- create a web application for the namespace -->
    <CSPApplication Url="/csp/${APPNAME}" Directory="${NAMESPACE_CSPAPPPATH}" ServeFiles="1" Recurse="1" Grant="%DB_${NAMESPACE},%SQL" AuthenticationMethods="32" />

    <!-- enable the web application for the namespace -->
    <Invoke Class="dc.irisrad.Installer" Method="EnableCSPApp">
      <Arg Value="/csp/${APPNAME}"/>
    </Invoke>

    <!-- installRESTForms2 as we use it for base CRUD operations -->
    <Invoke Class="dc.irisrad.Installer" Method="InstallZPM">
      <Arg Value="restforms2"/>
    </Invoke>

    <!-- import forms api classes -->
    <Import File="${FORMSCLASSPATH}" Flags="c">
    </Import>
    <Import File="${FORMSCLASSPATH}/cls" Flags="c" Recurse="1">
    </Import>
    <Import File="${FORMSCLASSPATH}/dc/irisrad" Flags="c" Recurse="1">
    </Import>
    <Import File="${FORMSCLASSPATH}/Form" Flags="c" Recurse="1">
    </Import>

    <!-- as we use deletagion authentication, guarantee it is enabled and properly setup -->
    <If Condition='(${FORCEROUTINES}) &amp;&amp; (##class(dc.irisrad.Installer).RoutineExists("ZAUTHENTICATE.mac", "%SYS"))'>
      <Log Text="ZAUTHENTICATE.mac replaced; a routine ZAUTHENTICATE_old.mac will be created." Level="0"/>
    </If>
    <Invoke Class="dc.irisrad.Installer" Method="InstallDelegation">
      <Arg Value="${FORMSCLASSPATH}"/>
      <Arg Value="${FORCEROUTINES}"/>
    </Invoke>
    
    <!-- create a directory for new app web application -->
    <Invoke Class="dc.irisrad.Installer" Method="CreateDirectory">
      <Arg Value="${CSPAPPPATH}"/>
    </Invoke>
    
    <!-- create a web application for the new app -->
    <!-- <CSPApplication Url="${NEW_APP_URL}" Directory="${CSPAPPPATH}" ServeFiles="1" Recurse="1" Grant="%DB_${NAMESPACE},%SQL" AuthenticationMethods="8224" /> -->
    <CSPApplication Url="${NEW_APP_URL}" Directory="${CSPAPPPATH}" ServeFiles="1" Recurse="1" Grant="%DB_${NAMESPACE},%SQL" AuthenticationMethods="8192" />

    <!-- enable the web application for the new app -->
    <Invoke Class="dc.irisrad.Installer" Method="EnableCSPApp">
      <Arg Value="${NEW_APP_URL}"/>
    </Invoke>

    <!-- create a web application for forms api -->
    <Invoke Class="dc.irisrad.Installer" Method="createRESTApp">
      <Arg Value="${RESTAPPNAME}"/>
      <Arg Value="${NAMESPACE}"/>
      <Arg Value="dc.irisrad.rest.Main"/>
    </Invoke>

    <!-- remove forms not used -->
    <Invoke Class="dc.irisrad.Installer" Method="RemoveForms">
      <Arg Value="Form.Test.Company"/>
      <Arg Value="Form.Test.Person"/>
      <Arg Value="Form.Test.Simple"/>
    </Invoke>

    <!-- install forms of the new app -->
    <Import File="${NEW_APP_FORMS_PATH}" Flags="c">
    </Import>
  </Namespace>

  <!-- copy static assets into new app -->
  <CopyDir Src="${SRC_PATH}" Target="${CSPAPPPATH}">
  </CopyDir>

  <!-- change the REST endpoint of static assets copied -->
  <Invoke Class="dc.irisrad.Installer" Method="SetRESTApp">
    <Arg Value="${CSPAPPPATH}"/>
    <Arg Value="${RESTAPPNAME}"/>
  </Invoke>
</Manifest>
}

ClassMethod DeployApp(pAppName As %String, pAppDesc As %String, pFormsCSV As %String, pForceRoutines As %Boolean = 0) As %Status
{
  // zn "%sys" do $SYSTEM.OBJ.Load("/opt/irisapp/src/dc/irisrad/Installer.cls","c") do ##class(dc.irisrad.Installer).DeployApp("test", "Test app", "User.forms.grocery.GroceryListForm,User.forms.grocery.GroceryProductForm", 1)
  Set sc = $$$OK

  Set newFormsPath = "/tmp/"_pAppName
  $$$TOE(sc, ..ExportForms(..#DefaulSystemNS, pAppName, newFormsPath, pFormsCSV))

  Set pVars("APPNAME") = pAppName
  Set pVars("APP_DESC") = pAppDesc
  Set pVars("SRC_PATH") = "/opt/irisapp/src/csp"
  Set pVars("NEW_APP_URL") = "/csp/"_pVars("APPNAME")_"-app"
  Set pVars("NEW_APP_FORMS_PATH") = newFormsPath
  Set pVars("APPPATH") = "/opt/"_$ZCONVERT(pVars("APPNAME"), "L")_"-app"
  Set pVars("NAMESPACE_CSPAPPPATH") = "/opt/"_$ZCONVERT(pVars("APPNAME"), "L")_"/csp"
  Set pVars("FORMSCLASSPATH") = "/opt/irisapp/src"
  Set pVars("CSPAPPPATH") = pVars("APPPATH")_"/csp/"
  Set pVars("DBPATH") = "/usr/irissys/mgr/"_$ZCONVERT(pVars("APPNAME"), "U")_"_APP"
  Set pVars("DBNAME") = $ZCONVERT(pVars("APPNAME"), "U")_"_APP"
  Set pVars("NAMESPACE") = $ZCONVERT(pVars("APPNAME"), "U")_"_APP"
  Set pVars("RESOURCE") = "%DB_"_pVars("DBNAME")
  Set pVars("RESTAPPNAME") = "/"_pVars("APPNAME")_"-app/forms"
  Set pVars("FORCEROUTINES") = pForceRoutines
  Set sc = ##class(dc.irisrad.Installer).setup(.pVars)

  Do ..RegisterApp(.pVars)

  Return sc
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

ClassMethod RoutineExists(pRoutineName As %String, pNamespace As %String) As %Boolean
{
  Set rs = ##class(%ResultSet).%New()
  Set rs.ClassName = "%Library.Routine"
  Set rs.QueryName = "RoutineList"
  $$$TOE(sc, rs.Prepare())
  $$$TOE(sc, rs.Execute(pRoutineName, "", "", pNamespace))
  Set exists = rs.Next()
  Return exists
}

ClassMethod InstallDelegation(pSoruceDir As %String, pForceRoutines As %Boolean = 0) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"
  
    // check if ZENAUTHENTICATE and IRISRADAUTHENTICATE are properly installed

    If (..RoutineExists("ZAUTHENTICATE.mac", "%SYS")) {
      If ('pForceRoutines) {
        Throw ##class(%Exception.General).%New("ZAUTHENTICATE already installed, you need to edit it manually or force it overwrite by pForceRoutines parameter.")
      }
      // backup current ZAUTHENTICATE.mac
      Do $SYSTEM.OBJ.Export("ZAUTHENTICATE.mac", "/tmp/ZAUTHENTICATE_old.mac")
      #; Do $SYSTEM.OBJ.Load("/tmp/ZAUTHENTICATE_old.mac","ck",,1)
    }

    // install IRIS RAD authentication routines
    Do $SYSTEM.OBJ.Load(pSoruceDir_"/IRISRADAUTHENTICATE.mac","ck",,1)
    Do $SYSTEM.OBJ.Load(pSoruceDir_"/ZAUTHENTICATE.mac","ck",,1)
    
    // enables delegation authentication
    Set sc = ##Class(Security.System).Get("SYSTEM",.Properties) 
    Set Properties("AutheEnabled") = $ZBOOLEAN(Properties("AutheEnabled"),8192,7) 
    Set sc = ##Class(Security.System).Modify("SYSTEM",.Properties) 
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Set $NAMESPACE = originalNS
  Return sc
}

ClassMethod InstallZPM(pPackageName As %String, pNamespace As %String = "") As %Status
{
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
  Set $NAMESPACE = originalNS
  Return sc
}

ClassMethod createRESTApp(pAppName As %String, pNamespace As %String, pDispatchClass As %String) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"
    If '##class(Security.Applications).Exists(pAppName) {
      #; Set props("AutheEnabled") = 8224
      Set props("AutheEnabled") = 8192
      Set props("NameSpace") = pNamespace
      Set props("IsNameSpaceDefault") = $$$NO
      Set props("DispatchClass") = pDispatchClass
      Set props("MatchRoles")=":%DB_%DEFAULT"
      Set sc = ##class(Security.Applications).Create(pAppName, .props)
    }
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Set $NAMESPACE = originalNS
  Return sc
}

ClassMethod CreateDirectory(pCSPDirectory As %String) As %Status
{
  Set sc = $$$OK
  // todo: use %File insted of linux commands
  Do $ZF(-1, "mkdir -p "_pCSPDirectory)
  Return sc
}

ClassMethod SetRESTApp(pCSPDirectory As %String, pNewRESTAppName As %String) As %Status
{
  Set sc = $$$OK
  Set oldRESTAppName = "\/irisrad"
  // todo: change to use some IRIS API instead of linux commands
  // naive linux escaping code
  Set pNewRESTAppName = $REPLACE(pNewRESTAppName, "/", "\/")
  // set the new app REST app name
  Do $ZF(-1, "sed -i 's/"_oldRESTAppName_"/"_pNewRESTAppName_"/g' "_pCSPDirectory_"/resources/js/classcreator.js")
  Do $ZF(-1, "sed -i 's/"_oldRESTAppName_"/"_pNewRESTAppName_"/g' "_pCSPDirectory_"/resources/js/customdash2.js")
  Do $ZF(-1, "sed -i 's/"_oldRESTAppName_"/"_pNewRESTAppName_"/g' "_pCSPDirectory_"/resources/js/util.js")
  Return sc
}

ClassMethod EnableCSPApp(pAppName As %String) As %Status
{
  Set sc = $$$OK
  Do EnableDeepSee^%SYS.cspServer(pAppName)
  Return sc
}

ClassMethod RemoveForms(pFormsCSV...) As %Status
{
  Set sc = $$$OK
  Set idx = $O(pFormsCSV(""))
  While(idx '= "") {
    Set className = pFormsCSV(idx)
    Do ##class(dc.irisrad.rest.Main).DeleteForm(className)
    Set idx = $O(pFormsCSV(idx))
  }
  Return sc
}

ClassMethod ExportForms(pNamespace As %String, pAppName As %String, pNewFormsPath As %String, pFormClassCSV As %String) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    If (pNamespace '= "") {
      New $NAMESPACE
      Set $NAMESPACE = pNamespace
    }
    
    Do $ZF(-1, "rm -rf "_pNewFormsPath)
    Do $ZF(-1, "mkdir -p "_pNewFormsPath)
    Set newAppForms = $LISTFROMSTRING(pFormClassCSV)
    For i=1:1:$LISTLENGTH(newAppForms) {
      Set formClassName = $LISTGET(newAppForms, i)_".cls"
      $$$TOE(sc, $SYSTEM.OBJ.Export(formClassName, pNewFormsPath_"/"_formClassName))
    }
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Set $NAMESPACE = originalNS
  Return sc
}

/// Remove an application
ClassMethod RemoveApp(pAppName As %String) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    ZNspace "%SYS"

    Set appNamespace = pAppName_"_APP"
    Set appDatabase = pAppName_"_APP"

    // remove app's CSP web app
    Set rs = ##class(%ResultSet).%New()
    Set rs.ClassName = "Security.Applications"
    Set rs.QueryName = "NamespaceList"
    $$$TOE(sc, rs.Prepare())
    $$$TOE(sc, rs.Execute(appNamespace))
    While(rs.Next()) {
      Set cspAppName = rs.Data("Name")
      $$$TOE(sc, ##class(Security.Applications).Delete(cspAppName))
    }
    Do rs.Close()

    // remove app namespace
    $$$TOE(sc, ##class(Config.Namespaces).Delete(appNamespace))

    // remove app database
    Set rs = ##class(%ResultSet).%New()
    Set rs.ClassName = "Config.Databases"
    Set rs.QueryName = "CompactLocalDBList"
    $$$TOE(sc, rs.Prepare())
    $$$TOE(sc, rs.Execute(appDatabase))
    While(rs.Next()) {
      Set dbDirectory = rs.Data("Directory")
      $$$TOE(sc, ##class(SYS.Database).DismountDatabase(dbDirectory))
      $$$TOE(sc, ##Class(Config.Databases).Delete(appDatabase))
      $$$TOE(sc, ##class(SYS.Database).DeleteDatabase(dbDirectory))
    }
    Do rs.Close()

    // unregister app
    $$$TOE(sc, ..UnregisterApp(pAppName))
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Set $NAMESPACE = originalNS
  Return sc
}

ClassMethod teste() As %Status
{
  Set sc = $$$OK
  Set var("APPNAME")="test1"
  Set var("APPPATH")="/opt/test1-app"
  Set var("APP_DESC")="test1 app"
  Set var("CSPAPPPATH")="/opt/test1-app/csp/"
  Set var("DBNAME")="TEST1_APP"
  Set var("DBPATH")="/usr/irissys/mgr/TEST1_APP"
  Set var("FORCEROUTINES")=1
  Set var("FORMSCLASSPATH")="/opt/irisapp/src"
  Set var("NAMESPACE")="TEST1_APP"
  Set var("NAMESPACE_CSPAPPPATH")="/opt/test1/csp"
  Set var("NEW_APP_FORMS_PATH")="/tmp/test1"
  Set var("NEW_APP_URL")="/csp/test1-app"
  Set var("RESOURCE")="%DB_TEST1_APP"
  Set var("RESTAPPNAME")="/test1-app/forms"
  Set var("SRC_PATH")="/opt/irisapp/src/csp"
  zw ..RegisterApp(.var)
  Return sc
}

/// Register an app
ClassMethod RegisterApp(ByRef pVars) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE

  Try {
    ZNspace ..#DefaulSystemNS

    Set app = ##class(dc.irisrad.data.RADUserApp).%New()

    Set username = $USERNAME
    Set app.User = ##class(dc.irisrad.data.RADUser).IdxUsernameOpen(username,, .sc)
    Return:$$$ISERR(sc) sc

    Set app.AppName = pVars("APPNAME")
    Set app.AppDesc = pVars("APP_DESC")
    Set app.AppNamespace = pVars("NAMESPACE")

    Set sc = app.%Save()
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  
  ZNspace originalNS
  Return sc
}

/// Unregister an app
ClassMethod UnregisterApp(pAppName As %String) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE

  Try {
    ZNspace ..#DefaulSystemNS
    Set appNamespace = pAppName_"_APP"
    Set appRef = ##class(dc.irisrad.data.RADUserApp).IdxAppNamespaceOpen(appNamespace, .sc)
    Return:($$$ISERR(sc)) sc
    Set sc = ##class(dc.irisrad.data.RADUserApp).%DeleteId(appRef.%Id())
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  
  ZNspace originalNS
  Return sc
}

}
