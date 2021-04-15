Include %occInclude

Class dc.irisrad.Installer
{

/// Default system app name
Parameter DefaulSystemAppName = "irisapp";

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
    <!-- <CSPApplication Url="/csp/${APPNAME}" Directory="${NAMESPACE_CSPAPPPATH}" ServeFiles="1" Recurse="1" Grant="%DB_${NAMESPACE},%SQL" AuthenticationMethods="32" /> -->
    <CSPApplication Url="/csp/${APPNAME}" Directory="${NAMESPACE_CSPAPPPATH}" ServeFiles="1" Recurse="1" Grant="${RESOURCE}" AuthenticationMethods="8192" />

    <!-- enable the web application for the namespace -->
    <Invoke Class="dc.irisrad.Installer" Method="EnableCSPApp">
      <Arg Value="/csp/${APPNAME}"/>
    </Invoke>

    <!-- installRESTForms2 as we use it for base CRUD operations -->
    <Invoke Class="dc.irisrad.Installer" Method="InstallZPM">
      <Arg Value="restforms2"/>
      <Arg Value="${NAMESPACE}"/>
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
    <CSPApplication Url="${NEW_APP_URL}" Directory="${CSPAPPPATH}" ServeFiles="1" Recurse="1" Grant="${RESOURCE}" AuthenticationMethods="8192" />

    <!-- enable the web application for the new app -->
    <Invoke Class="dc.irisrad.Installer" Method="EnableCSPApp">
      <Arg Value="${NEW_APP_URL}"/>
    </Invoke>

    <!-- create a web application for forms api -->
    <Invoke Class="dc.irisrad.Installer" Method="createRESTApp">
      <Arg Value="${RESTAPPNAME}"/>
      <Arg Value="${NAMESPACE}"/>
      <Arg Value="dc.irisrad.rest.Main"/>
      <Arg Value="${RESOURCE}"/>
    </Invoke>

    <!-- create a web application for authenticated access (sign up) -->
    <Invoke Class="dc.irisrad.Installer" Method="createRESTApp">
      <Arg Value="${REST_UNAUTH_APPNAME}"/>
      <Arg Value="${NAMESPACE}"/>
      <Arg Value="dc.irisrad.rest.UnAuth"/>
      <Arg Value=":IRIS_RAD_UNAUTH"/>
      <Arg Value="64"/>
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

  <!-- change the user form of static assets copied -->
  <Invoke Class="dc.irisrad.Installer" Method="SetUserForm">
    <Arg Value="${CSPAPPPATH}"/>
  </Invoke>
</Manifest>
}

ClassMethod DeployApp(pAppName As %String, pAppDesc As %String, pFormsCSV As %String, pForceRoutines As %Boolean = 0) As %Status
{
  // zn "%sys" do $SYSTEM.OBJ.Load("/opt/irisapp/src/dc/irisrad/Installer.cls","c") do ##class(dc.irisrad.Installer).DeployApp("test", "Test app", "User.forms.grocery.GroceryListForm,User.forms.grocery.GroceryProductForm", 1)
  Set sc = $$$OK

  $$$TOE(sc, ..ValidateCreation(pAppName))

  Set newFormsPath = "/tmp/"_pAppName
  $$$TOE(sc, ..ExportForms(..#DefaulSystemNS, pAppName, newFormsPath, pFormsCSV))

  Set pVars("APPNAME") = pAppName
  Set pVars("APP_DESC") = pAppDesc
  Set pVars("SRC_PATH") = "/opt/irisapp/src/csp"
  Set pVars("NEW_APP_URL") = "/csp/"_pVars("APPNAME")
  Set pVars("NEW_APP_FORMS_PATH") = newFormsPath
  Set pVars("APPPATH") = "/opt/"_$ZCONVERT(pVars("APPNAME"), "L")
  Set pVars("NAMESPACE_CSPAPPPATH") = "/opt/"_$ZCONVERT(pVars("APPNAME"), "L")_"/csp"
  Set pVars("FORMSCLASSPATH") = "/opt/irisapp/src"
  Set pVars("CSPAPPPATH") = pVars("APPPATH")_"/csp/"
  Set pVars("DBPATH") = "/usr/irissys/mgr/"_$ZCONVERT(pVars("APPNAME"), "U")_"_APP"
  Set pVars("DBNAME") = $ZCONVERT(pVars("APPNAME"), "U")_"_APP"
  Set pVars("NAMESPACE") = $ZCONVERT(pVars("APPNAME"), "U")_"_APP"
  Set pVars("RESOURCE") = "%DB_"_pVars("DBNAME")
  Set pVars("RESTAPPNAME") = "/"_pVars("APPNAME")_"/forms"
  Set pVars("REST_UNAUTH_APPNAME") = "/"_pVars("APPNAME")_"/forms/unauth"
  Set pVars("FORCEROUTINES") = pForceRoutines
  Set sc = ##class(dc.irisrad.Installer).setup(.pVars)

  // GRANT * ON Data.Countries TO %DB_TEST3_APP
  #; Kill roleInfoArray
  #; Set roleInfoArray($I(roleInfoArray)) = $LB("SELECT,INSERT", "dc_irisrad_default.UserForm", "IRIS_RAD_UNAUTH")
  #; Set roleInfoArray($I(roleInfoArray)) = $LB("SELECT,INSERT", "dc_irisrad_data.RADUser", "IRIS_RAD_UNAUTH")
  #; $$$TOE(sc, ##class(App.Installer).GrantTablesRoleUnAuth(pVars("NAMESPACE"), .roleInfoArray))
  $$$TOE(sc, ##class(App.Installer).GrantRolesForUnauthAcess(pVars("NAMESPACE")))
  
  // todo: review which accesses should be granted
  // GRANT * ON SCHEMA Data TO %DB_TEST1_APP
  Kill roleInfoArray
  Set roleInfoArray($I(roleInfoArray)) = $LB("*", "SCHEMA Data", pVars("RESOURCE"))
  Set roleInfoArray($I(roleInfoArray)) = $LB("*", "SCHEMA Form_Test", pVars("RESOURCE"))
  Set roleInfoArray($I(roleInfoArray)) = $LB("*", "SCHEMA User_forms", pVars("RESOURCE"))
  Set roleInfoArray($I(roleInfoArray)) = $LB("SELECT,UPDATE", "dc_irisrad_default.UserForm", pVars("RESOURCE"))
  $$$TOE(sc, ##class(App.Installer).GrantTablesRoleUnAuth(pVars("NAMESPACE"), .roleInfoArray))

  $$$TOE(sc, ..RegisterApp(.pVars))

  Return sc
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

/// Check all validation rules for app creation
ClassMethod ValidateCreation(pAppName As %String) As %Status
{
  Set sc = $$$OK

  Try {
    // avoid creation of an app with same name of default RAD app
    If (pAppName = ..#DefaulSystemAppName) {
      Throw ##class(%Exception.General).%New("Application name not allowed: "_pAppName)
    }

    // avoid duplication of app name
    Set originalNS = $NAMESPACE
    Try {
      ZNspace ..#DefaulSystemNS
      If (##class(dc.irisrad.data.RADUserApp).IdxAppNameExists(pAppName)) {
        Throw ##class(%Exception.General).%New("Application name already exists: "_pAppName)
      }
    }
    Catch ex {
      Set sc=ex.AsStatus()
    }
    ZNspace originalNS
  }
  Catch ex {
    Set sc = ex.AsStatus()
  }

  Return sc
}

ClassMethod RoutineExists(pRoutineName As %String, pNamespace As %String) As %Boolean
{
  Set rs = ##class(%ResultSet).%New()
  Set rs.ClassName = "%Library.Routine"
  Set rs.QueryName = "RoutineList"
  $$$TOE(sc, rs.Prepare())
  $$$TOE(sc, rs.Execute(pRoutineName, "", "", pNamespace))
  Set exists = rs.Next()
  Do rs.Close()
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
  zw pPackageName,pNamespace
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    ZNspace "%SYS"
    Set sc = ##class(App.Installer).InstallZPM(pPackageName, pNamespace)
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Set $NAMESPACE = originalNS
  zw sc 
  Return sc
}

ClassMethod createRESTApp(pAppName As %String, pNamespace As %String, pDispatchClass As %String, pRoles As %String, pAutheEnabled As %Integer = 8192) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE
  Try {
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"
    /*
    If '##class(Security.Applications).Exists(pAppName) {
      #; Set props("AutheEnabled") = 8224
      Set props("AutheEnabled") = 8192
      Set props("NameSpace") = pNamespace
      Set props("IsNameSpaceDefault") = $$$NO
      Set props("DispatchClass") = pDispatchClass
      Set props("MatchRoles") = pRoles
      Set sc = ##class(Security.Applications).Create(pAppName, .props)
    }
    */
    zw pAppName, pNamespace, pDispatchClass, pRoles, pAutheEnabled
    Set sc = ##class(App.Installer).createRESTApp(pAppName, pNamespace, pDispatchClass, pRoles, pAutheEnabled)
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Set $NAMESPACE = originalNS
  zw sc
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
  // todo: iterate over all js files
  // set the new app REST app name
  Do $ZF(-1, "sed -i 's/"_oldRESTAppName_"/"_pNewRESTAppName_"/g' "_pCSPDirectory_"/resources/js/apps.js")
  Do $ZF(-1, "sed -i 's/"_oldRESTAppName_"/"_pNewRESTAppName_"/g' "_pCSPDirectory_"/resources/js/classcreator.js")
  Do $ZF(-1, "sed -i 's/"_oldRESTAppName_"/"_pNewRESTAppName_"/g' "_pCSPDirectory_"/resources/js/customdash2.js")
  Do $ZF(-1, "sed -i 's/"_oldRESTAppName_"/"_pNewRESTAppName_"/g' "_pCSPDirectory_"/resources/js/deploy.js")
  Do $ZF(-1, "sed -i 's/"_oldRESTAppName_"/"_pNewRESTAppName_"/g' "_pCSPDirectory_"/resources/js/signup.js")
  Do $ZF(-1, "sed -i 's/"_oldRESTAppName_"/"_pNewRESTAppName_"/g' "_pCSPDirectory_"/resources/js/util.js")
  Return sc
}

ClassMethod SetUserForm(pCSPDirectory As %String) As %Status
{
  Set sc = $$$OK
  Set oldUserForm = "dc.irisrad.data.RADUser"
  // todo: change to use some IRIS API instead of linux commands
  Set newUserForm = "dc.irisrad.default.UserForm"
  // todo: iterate over all js files
  // set the common form class for applications created by RAD
  Do $ZF(-1, "sed -i 's/"_oldUserForm_"/"_newUserForm_"/g' "_pCSPDirectory_"/resources/js/signup.js")
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
    If (##class(Config.Namespaces).Exists(appNamespace)) {
      $$$TOE(sc, ##class(Config.Namespaces).Delete(appNamespace))
    }

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

/// Register an app
ClassMethod RegisterApp(ByRef pVars) As %Status
{
  Set sc = $$$OK
  Set originalNS = $NAMESPACE

  Try {
    ZNspace ..#DefaulSystemNS

    Set app = ##class(dc.irisrad.data.RADUserApp).%New()

    Set username = $USERNAME
    Set app.RADUser = ##class(dc.irisrad.data.RADUser).IdxUsernameOpen(username,, .sc)
    Return:$$$ISERR(sc) sc

    Set app.AppName = pVars("APPNAME")
    Set app.AppDesc = pVars("APP_DESC")
    Set app.AppNamespace = pVars("NAMESPACE")
    Set app.AppURL = ##class(dc.irisrad.Installer).GenerateAppURL(pVars("APPNAME"))

    Set sc = app.%Save()
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  
  ZNspace originalNS
  Return sc
}

/// Generate a URL for access an app
ClassMethod GenerateAppURL(pAppName As %String) As %String
{
  Return "/csp/"_pAppName_"/login.html"
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
