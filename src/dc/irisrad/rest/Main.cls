Include %occErrors

Class dc.irisrad.rest.Main Extends Form.REST.Main
{

Parameter UseSession As BOOLEAN = 1;

/// TODO: create a ENUM for auth types
Parameter AuthType = "SESSION";

/// todo: there are too much rotes here; analyse and separate them into subject-oriented classes
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Authentication routes -->
<Route Url="/login" Method="GET" Call="DoLogin"/>
<Route Url="/login/:appName" Method="GET" Call="DoLogin"/>
<Route Url="/logout" Method="GET" Call="DoLogout"/>

<!-- Routes for application management -->
<Route Url="/apps" Method="GET" Call="GetApps"/>
<Route Url="/apps/:appName" Method="POST" Call="DeployApp"/>
<Route Url="/apps/:appName" Method="DELETE" Call="DeleteApp"/>

<!-- Routes for dynamic form creation/deletion -->
<Route Url="/form" Method="POST" Call="CreateForms"/>
<Route Url="/form/:form" Method="DELETE" Call="DeleteForm"/>
<Route Url="/form/package/:package" Method="DELETE" Call="DeleteFormPackage"/>

<!-- todo: evaluate if this will be implemented -->
<!-- Overrided due UI customizations features -->
<Route Url="/form/info/:form" Method="GET" Call="dc.irisrad.Form:GetFormInfo"/>
<!-- Get the queries metadata for UI configuration  -->
<Route Url="/form/info/:form/:query" Method="GET" Call="dc.irisrad.Form:GetFormQueryInfo"/>

<!-- todo: fix it -->
<!-- Ungly hack for resolve jQuery weird bug -->
<Route Url="/form/object/:form/:id" Method="PUT" Call="updateFormDynamicObject"/>
<Route Url="/form/object/:form/:id" Method="DELETE" Call="deleteFormObject"/>

<!-- Create RESTForms classes using RAD Interface -->
<Route Url="/form/class/lookup" Method="GET" Call="dc.irisrad.CreationUtility:ListClasses" />
<Route Url="/form/class/relatedclass/lookup" Method="GET" Call="dc.irisrad.CreationUtility:RelatedClassList" />
<Route Url="/form/class/:id" Method="GET" Call="dc.irisrad.CreationUtility:GetClassById" />
<Route Url="/form/class/check/:name" Method="GET" Call="dc.irisrad.CreationUtility:CheckClassName" />
<Route Url="/form/class/fields/:id" Method="GET" Call="dc.irisrad.CreationUtility:GetFields" />
<Route Url="/task/:id" Method="GET" Call="diashenrique.npm.REST.Routes.Task:GetTask" Cors="true"/>
<Route Url="/form/class" Method="POST" Call="dc.irisrad.CreationUtility:CreateClass" Cors="true"/>
<Route Url="/form/class/:id" Method="DELETE" Call="dc.irisrad.CreationUtility:DeleteClass" Cors="true"/>
<Route Url="/form/class/fields" Method="POST" Call="dc.irisrad.CreationUtility:CreateField" Cors="true"/>
<Route Url="/form/class/fields/:id" Method="PUT" Call="dc.irisrad.CreationUtility:UpdateField" />
<Route Url="/form/class/fields/:id" Method="DELETE" Call="dc.irisrad.CreationUtility:DeleteField" />
<Route Url="/form/class/compile/:id" Method="POST" Call="dc.irisrad.CreationUtility:CompileClass" />

<!-- Original Form.REST.Main redirections -->
<Map Prefix="/form" Forward="Form.REST.Form"/>

<!-- Original Form.REST.Main routes -->
<!-- <Route Url="/logout" Method="GET" Call="logout"/> -->
<Route Url="/test" Method="GET" Call="test"/>
<Route Url="/test" Method="POST" Call="test"/>
<Route Url="/info" Method="GET" Call="info"/>
</Routes>
}

ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
  // todo: check why the security doesn't work
  // "workaround" 
  Quit $$$OK
  
  // todo: try to use native REST security SECURITYRESOURCE parameter (https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=GREST_securing#GREST_authorization_securityresourceparam)
  Set username = $USERNAME
  Set appRef = ##class(dc.irisrad.data.RADUserApp).IdxAppNamespaceOpen($NAMESPACE)
  Set appName = ""
  Set:($ISOBJECT(appRef)) appName = appRef.AppName
  Set isAdmin = ##class(dc.irisrad.data.RADUserApp).IsUserRADAdminApp(username, appName)
  If ('isAdmin) && (
    ($MATCH(pUrl, "\/apps\/.*")) ||
    ($MATCH(pUrl, "\/form\/class\/.*"))
  ) {
    Quit $SYSTEM.Status.Error($$$InsufficientPrivilegeForOperationReq)
  }
  Quit $$$OK
}

/// Login user from current session
ClassMethod DoLogin(pAppName As %String = "") As %Status
{
  If (..#AuthType = "SESSION") {
    // As seen in RESTForm2UI, the test method is called for login logic; such method uses
    // auth info stored in AUTHENTICATION HTTP header.
    #; Return ##class(Form.REST.Main).test()

    Set:(pAppName = ##class(dc.irisrad.Installer).#DefaulSystemAppName) pAppName = ""
    Write {
      "username": ($USERNAME),
      "admin": (##class(dc.irisrad.data.RADUserApp).IsUserRADAdminApp($USERNAME, pAppName))
    }.%ToJSON()
    Return $$$OK
    
    #; Set authorization = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    #; Set authorization = $PIECE(authorization, " ", 2)
    #; Set authorization = ##class(%SYSTEM.Encryption).Base64Decode(authorization)
    #; Set user = $PIECE(authorization, ":", 1)
    #; Set pwd = $PIECE(authorization, ":", 1)
  } Else {
    // todo: implement other auth types
    Throw ##class(%Exception.General).%New("Invalid value for AuthType parameter: "_..#AuthType)
  }
}

/// Logout user from current session
ClassMethod DoLogout() As %Status
{
  /// todo: fix this
  // ugly hack for jQuery Ajax error
  Write 1
  If (..#AuthType = "SESSION") {
    Return ##class(Form.REST.Main).logout()
  } Else {
    // todo: implement other auth types
    Throw ##class(%Exception.General).%New("Invalid value for AuthType parameter: "_..#AuthType)
  }
}

ClassMethod CreateForms() As %Status
{
  Set sc = $$$OK
  Try {
    Set body = [].%FromJSON(%request.Content)
    Set iter = body.%GetIterator()
    Set classesList = ""
    While (iter.%GetNext(.idx, .form)) {
      Set $LIST(classesList, * + 1) = form.name_".cls"
      Set formObj = ..CreateForm(form)
      $$$TOE(sc, formObj.Save(0))
    }

    Set classesList = $LISTTOSTRING(classesList)
    $$$TOE(sc, $SYSTEM.OBJ.CompileList(classesList, "ck /nodisplay", .errorLog))
    
    /// todo: fix this
    /// ugly hack for jQuery Ajax error
    Write 1
  }
  Catch ex {
    Set sc = ex.AsStatus()
  }
  Return sc
}

ClassMethod CreateForm(pFormObj As %DynamicObject) As dc.irisrad.Form
{
  Set form = ##class(dc.irisrad.Form).%New()
  Set form.Name = pFormObj.name
  Set form.ExtendsDef = pFormObj.extends
  Set form.DisplayFormName = pFormObj.displayFormName
  Set form.DisplayField = pFormObj.displayProperty
  Set form.Fields = pFormObj.fields
  Set form.ObjPermissions = pFormObj.objpermissions
  Return form
}

ClassMethod DeleteForm(pFormName As %String) As %Status
{
  Set sc = $$$OK
  Try {
    // Avoid default forms to be deleted
    If ($FIND(pFormName, "dc.irisrad.data.RADUser") > 0) {
      Throw ##class(%Exception.General).%New("A default form can't be deleted.")
    }
    If ($FIND(pFormName, "dc.irisrad.default.") > 0) {
      Throw ##class(%Exception.General).%New("A default form can't be deleted.")
    }

    $$$TOE(sc, ##class(%Dictionary.ClassDefinition).%DeleteId(pFormName))
    
    /// todo: fix this
    /// ugly hack for jQuery Ajax error
    Write 1
  }
  Catch ex {
    Set sc = ex.AsStatus()
  }
  Return sc
}

ClassMethod DeleteFormPackage(pPackageName As %String) As %Status
{
  Set sc = $$$OK
  Try {
    $$$TOE(sc, $SYSTEM.OBJ.GetPackageList(.forms, pPackageName))
    //zw pPackageName,forms
    Set form = $ORDER(forms(""))
    While (form '= "") {
      $$$TOE(sc, ##class(%Dictionary.ClassDefinition).%DeleteId(form))
      Set form = $ORDER(forms(form))
    }
    
    /// todo: fix this
    /// ugly hack for jQuery Ajax error
    Write 1
  }
  Catch ex {
    Set sc = ex.AsStatus()
  }
  Return sc
}

/// Test method
ClassMethod test() As %Status
{
    Do ##class(Form.REST.Main).test()
    Return $$$OK
}

/// Language info
ClassMethod info() As %Status
{
	Do ##class(Form.REST.Main).info()
	Return $$$OK
}

ClassMethod updateFormDynamicObject(form, id) As %Status
{
  $$$TOE(sc, ##class(Form.REST.Object).updateFormDynamicObject(form, id))
  /// todo: fix this
  /// ugly hack for jQuery Ajax error
  Write 1
  Return sc
}

ClassMethod deleteFormObject(form, id) As %Status
{
	Set sc = ##class(Form.Info).formExistsStatus(form)
  $$$TOE(sc, ##class(Form.REST.Object).deleteFormObject(form, id))
  /// todo: fix this
  /// ugly hack for jQuery Ajax error
  Write 1
  Return sc
}

ClassMethod DeployApp(pAppName As %String) As %Status
{
  Set sc = $$$OK
  Try {
    // todo: check if app already exists
    // todo: perform a dependency check on forms

    Set body = {}.%FromJSON(%request.Content)
    //Set appName = body.appName
    Set appName = pAppName
    Set appDescription = body.appDescription
    Set forms = body.forms
    Set:('$ISOBJECT(forms)) forms = []

    // convert forms json array to a CSV
    Set listForms = ""
    Set iter = forms.%GetIterator()
    While (iter.%GetNext(.key, .value)) {
      Set $LIST(listForms, * + 1) = value.class
    }
    Set listForms = $LISTTOSTRING(listForms)
    
    // output file
    Set outfile = "/tmp/output-deploy-"_appName_".txt"
    Do ##class(%File).Delete(outfile)

    // redirect output to file
    Open outfile:("NW"):5
    Use outfile
    
    // deploy the app
    Set originalNS = $NAMESPACE
    Try {
      ZNspace "%SYS"
      $$$TOE(st, $SYSTEM.OBJ.Load("/opt/irisapp/src/dc/irisrad/Installer.cls", "c"))
      $$$TOE(st, ##class(dc.irisrad.Installer).DeployApp(appName, appDescription, listForms, 1))
      ZNspace originalNS
    }
    Catch ex {
      Write ex.DisplayString()
      Set sc=ex.AsStatus()
    }
    ZNspace originalNS
    
    // close file redirection
    Close outfile
    
    // read deploy output file
    Set file = ##class(%File).%New(outfile)
    $$$TOE(sc, file.Open("R"))
    Try {
      Set content = ""
      While('file.AtEnd){
        Set content = content_file.Read()_$CHAR(13,10)
      }
    }
    Catch ex {
      Set sc=ex.AsStatus()
    }
    Do file.Close()

    // check if deploy was ok
    Set isDeployOK = $FIND(content, "dc.irisrad.Installer: Installation succeeded at ") > 0

    // create a json object for send back
    Set resp = {
      "status": (isDeployOK),
      "newAppLink": (##class(dc.irisrad.Installer).GenerateAppURL(appName)),
      "output": (content)
    }
    Write resp.%ToJSON()
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Return sc
}

/// Remove an application
ClassMethod DeleteApp(pAppName As %String) As %Status
{
  Set sc = $$$OK
  $$$TOE(sc, ##class(dc.irisrad.Installer).RemoveApp(pAppName))
  Return sc
}

/// Get all current user applications
ClassMethod GetApps() As %Status
{
  Set sc = $$$OK
  Set rs = ##class(dc.irisrad.data.RADUserApp).GetUserApps($USERNAME)
  Do rs.%Next()
  Write rs.Apps
  Kill rs, stmt
  Return sc
}

}
