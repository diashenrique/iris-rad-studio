Class dc.irisrad.rest.Main Extends Form.REST.Main
{

Parameter UseSession As BOOLEAN = 1;

/// TODO: create a ENUM for auth types
Parameter AuthType = "SESSION";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Authentication routes -->
<Route Url="/login" Method="GET" Call="DoLogin"/>
<Route Url="/logout" Method="GET" Call="DoLogout"/>

<!-- Routes for application deployment -->
<Route Url="/deploy" Method="POST" Call="Deploy"/>

<!-- Routes for dynamic form creation/deletion -->
<Route Url="/form" Method="POST" Call="CreateForm"/>
<Route Url="/form/:form" Method="DELETE" Call="DeleteForm"/>

<!-- Overrided due UI customizations features -->
<Route Url="/form/info/:form" Method="GET" Call="dc.irisrad.Form:GetFormInfo"/>
<!-- Get the queries metadata for UI configuration  -->
<Route Url="/form/info/:form/:query" Method="GET" Call="dc.irisrad.Form:GetFormQueryInfo"/>

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

/// Login user from current session
ClassMethod DoLogin() As %Status
{
  If (..#AuthType = "SESSION") {
    // As seen in RESTForm2UI, the test method is called for login logic; such method uses
    // auth info stored in AUTHENTICATION HTTP header.
    Return ##class(Form.REST.Main).test()
    
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
  // ugly hack for jQuery Ajax error
  Write 1
  If (..#AuthType = "SESSION") {
    Return ##class(Form.REST.Main).logout()
  } Else {
    // todo: implement other auth types
    Throw ##class(%Exception.General).%New("Invalid value for AuthType parameter: "_..#AuthType)
  }
}

ClassMethod CreateForm() As %Status
{
  Set sc = $$$OK
  Try {
    Set body = {}.%FromJSON(%request.Content)
    Set form = ##class(dc.irisrad.Form).%New()
    Set form.Name = body.name
    Set form.DisplayFormName = body.displayFormName
    Set form.DisplayField = body.displayProperty
    Set form.Fields = body.fields
    $$$TOE(sc, form.Save())
    
    /// ugly hack for jQuery Ajax error
    Write 1
  }
  Catch ex {
    Set sc = ex.AsStatus()
  }
  Return sc
}

ClassMethod DeleteForm(pFormName As %String) As %Status
{
  Set sc = $$$OK
  Try {
    // Avoid default forms to be deleted
    If ($FIND(pFormName, "dc.irisrad.default.") > 0) {
      Throw ##class(%Exception.General).%New("A default form can't be deleted.")
    }

    $$$TOE(sc, ##class(%Dictionary.ClassDefinition).%DeleteId(pFormName))
    
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
  /// ugly hack for jQuery Ajax error
  Write 1
  Return sc
}

ClassMethod deleteFormObject(form, id) As %Status
{
  $$$TOE(sc, ##class(Form.REST.Object).deleteFormObject(form, id))
  /// ugly hack for jQuery Ajax error
  Write 1
  Return sc
}

ClassMethod Deploy() As %Status
{
  Set sc = $$$OK
  Try {
    // todo: check if app already exists

    Set body = {}.%FromJSON(%request.Content)
    Set appName = body.appName
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
    
    #; Set appName = "test"
    #; Set appDescription = "Test application"
    #; Set listForms = "User.forms.grocery.GroceryListForm,User.forms.grocery.GroceryProductForm"

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
      #; Do ..CreateDeployOutputOK()
    }
    Catch ex {
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
    //  * ex: pegar a saída quando dá certo e verificar se está diferent - o que significaria erro
    //    2021-03-17 21:37:42 0 dc.irisrad.Installer: Installation succeeded at 2021-03-17 21:37:42
    //    2021-03-17 21:37:42 0 %Installer: Elapsed time 12.216839s
    Set isDeployOK = $FIND(content, "dc.irisrad.Installer: Installation succeeded at ") > 0

    // create a json object for send back
    //  * link para a nova app
    //  * status do processo
    //  * output (pegar a partir do arquivo com a saída da instalação redirecionada)
    Set resp = {
      "status": (isDeployOK),
      "newAppLink": ("/csp/"_appName_"-app/login.html"),
      "output": (content)
    }
    Write resp.%ToJSON()
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  Return sc
}

ClassMethod CreateDeployOutputOK() As %Status
{
  Set sc = $$$OK
  Write "Load started on 03/17/2021 21:37:29",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/Installer.cls as udl, using up to 3 worker jobs",!
  Write "Compiling class dc.irisrad.Installer",!
  Write "Compiling routine dc.irisrad.Installer.1",!
  Write "Load finished successfully.",!
  Write "",!
  Write "Exporting to XML started on 03/17/2021 21:37:30",!
  Write "Exporting class: User.forms.grocery.GroceryListForm",!
  Write "Export finished successfully.",!
  Write "",!
  Write "Exporting to XML started on 03/17/2021 21:37:30",!
  Write "Exporting class: User.forms.grocery.GroceryProductForm",!
  Write "Export finished successfully.",!
  Write "2021-03-17 21:37:30 0 dc.irisrad.Installer: Installation starting at 2021-03-17 21:37:30, LogLevel=3",!
  Write "2021-03-17 21:37:30 3 Evaluate: %DB_${DBNAME} -> %DB_TEST_APP",!
  Write "2021-03-17 21:37:30 3 Evaluate: Resource for application ${APPNAME} -> Resource for application test",!
  Write "2021-03-17 21:37:30 1 CreateResource: Modifying Resource '%DB_TEST_APP' with public permission(s) 'RW', type=0",!
  Write "2021-03-17 21:37:30 3 Evaluate: ${NAMESPACE} -> TEST_APP",!
  Write "2021-03-17 21:37:30 3 Evaluate: ${DBNAME} -> TEST_APP",!
  Write "2021-03-17 21:37:30 3 Evaluate: ${DBNAME} -> TEST_APP",!
  Write "2021-03-17 21:37:30 3 Evaluate: ${DBNAME} -> TEST_APP",!
  Write "2021-03-17 21:37:30 3 Evaluate: ${DBPATH}/data -> /usr/irissys/mgr/TEST_APP/data",!
  Write "2021-03-17 21:37:30 3 Evaluate: ${RESOURCE} -> %DB_TEST_APP",!
  Write "2021-03-17 21:37:30 1 CreateDatabase: Creating database TEST_APP in /usr/irissys/mgr/TEST_APP/data/ with resource %DB_TEST_APP",!
  Write "2021-03-17 21:37:30 2 CreateDatabase: Overwriting /usr/irissys/mgr/TEST_APP/data/IRIS.DAT",!
  Write "2021-03-17 21:37:30 2 CreateDatabase: Adding database TEST_APP",!
  Write "2021-03-17 21:37:30 2 CreateDatabase: Creating and assigning resource '%DB_TEST_APP' to TEST_APP",!
  Write "2021-03-17 21:37:30 1 CreateNamespace: Creating namespace TEST_APP using TEST_APP/TEST_APP",!
  Write "2021-03-17 21:37:30 2 CreateNamespace: Adding namespace TEST_APP",!
  Write "2021-03-17 21:37:30 1 ActivateConfiguration: Activating Configuration",!
  Write "2021-03-17 21:37:30 1 ActivateConfiguration: Activating Configuration",!
  Write "2021-03-17 21:37:30 3 Evaluate: ${FORMSCLASSPATH}/dc/irisrad/Installer.cls -> /opt/irisapp/src/dc/irisrad/Installer.cls",!
  Write "2021-03-17 21:37:30 1 Import: Loading /opt/irisapp/src/dc/irisrad/Installer.cls (isdir=0) into TEST_APP, recurse=0",!
  Write "",!
  Write "Load started on 03/17/2021 21:37:30",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/Installer.cls as udl, using up to 3 worker jobs",!
  Write "Compiling class dc.irisrad.Installer",!
  Write "Compiling routine dc.irisrad.Installer.1",!
  Write "Load finished successfully.",!
  Write "2021-03-17 21:37:30 3 Evaluate: ${NAMESPACE_CSPAPPPATH} -> /opt/test/csp",!
  Write "chmod: changing permissions of '/opt/test/csp/../csp/Form_JSON.js': Operation not permitted",!
  Write "chmod: changing permissions of '/opt/test/csp/../csp/AnalyzeThis_ThirdParty.js': Operation not permitted",!
  Write "2021-03-17 21:37:30 3 Evaluate: /csp/${APPNAME} -> /csp/test",!
  Write "2021-03-17 21:37:30 3 Evaluate: ${NAMESPACE_CSPAPPPATH} -> /opt/test/csp",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate: 32 -> 32",!
  Write "2021-03-17 21:37:30 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:30 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:30 3 Evaluate: 0 -> 0",!
  Write "2021-03-17 21:37:30 3 Evaluate: 0 -> 0",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:30 3 Evaluate: %DB_${NAMESPACE},%SQL -> %DB_TEST_APP,%SQL",!
  Write "2021-03-17 21:37:30 1 CSPApplication: Creating /csp/test in TEST_APP, using /opt/test/csp",!
  Write "2021-03-17 21:37:31 3 Evaluate: /csp/${APPNAME} -> /csp/test",!
  Write "",!
  Write "[restforms2]    Reload START",!
  Write "[restforms2]    Reload SUCCESS",!
  Write "[restforms2]    Module object refreshed.",!
  Write "[restforms2]    Validate START",!
  Write "[restforms2]    Validate SUCCESS",!
  Write "[restforms2]    Compile START",!
  Write "[restforms2]    Compile SUCCESS",!
  Write "[restforms2]    Activate START",!
  Write "[restforms2]    Configure START",!
  Write "[restforms2]    Configure SUCCESS",!
  Write "[restforms2]    Activate SUCCESS2021-03-17 21:37:38 3 Evaluate: ${FORMSCLASSPATH} -> /opt/irisapp/src",!
  Write "2021-03-17 21:37:38 1 Import: Loading /opt/irisapp/src (isdir=1) into TEST_APP, recurse=0",!
  Write "",!
  Write "Load of directory started on 03/17/2021 21:37:38",!
  Write "",!
  Write "Loading file /opt/irisapp/src/IRISRADAUTHENTICATE.mac as udl",!
  Write "IRISRADAuthentication.MAC Loaded",!
  Write "Loading file /opt/irisapp/src/ZAUTHENTICATE.mac as udl",!
  Write "ZAUTHENTICATE.MAC Loaded",!
  Write "",!
  Write "Compilation started on 03/17/2021 21:37:38 with qualifiers 'c'",!
  Write "Compiling routine : IRISRADAuthentication.mac",!
  Write "Compiling routine : ZAUTHENTICATE.mac",!
  Write "Compilation finished successfully in 0.011s.",!
  Write "",!
  Write "Load finished successfully.",!
  Write "2021-03-17 21:37:38 3 Evaluate: ${FORMSCLASSPATH}/cls -> /opt/irisapp/src/cls",!
  Write "2021-03-17 21:37:38 1 Import: Loading /opt/irisapp/src/cls (isdir=1) into TEST_APP, recurse=1",!
  Write "",!
  Write "Load of directory started on 03/17/2021 21:37:38",!
  Write "",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/Installer.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/Generator.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/Utils.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/Dashboard/AutoPivot.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/Dashboard/MetaData.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/Dashboard/MetaDataAnalyze.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/Dashboard/Utils.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/ThirdParty/AmSmoothedLineChart.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/ThirdParty/AbstractAmChart.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/ThirdParty/ListingInterface.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/ThirdParty/NVD3timeChart.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/UI/CSVImport.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/UI/Dialog/CSVImport/showInfo.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/diashenrique/REST/Base.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/AnalyzeThis/UI/Dialog/CSVImport.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/diashenrique/REST/Dispatch.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/diashenrique/REST/Routes/Task.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/diashenrique/REST/Routes/Wizard.cls as udl",!
  Write "Loading file /opt/irisapp/src/cls/diashenrique/data/Task.cls as udl",!
  Write "",!
  Write "Compilation started on 03/17/2021 21:37:39 with qualifiers 'c'",!
  Write "Compiling 19 classes, using up to 3 worker jobs",!
  Write "Compiling class diashenrique.REST.Base",!
  Write "Compiling routine diashenrique.REST.Base.1",!
  Write "Compiling class AnalyzeThis.UI.CSVImport",!
  Write "Compiling class AnalyzeThis.UI.Dialog.CSVImport.showInfo",!
  Write "Compiling class AnalyzeThis.UI.Dialog.CSVImport",!
  Write "Compiling routine AnalyzeThis.UI.Dialog.CSVImport.showInfo.1",!
  Write "Compiling routine AnalyzeThis.UI.CSVImport.1",!
  Write "Compiling routine AnalyzeThis.UI.Dialog.CSVImport.1",!
  Write "Compiling class AnalyzeThis.Dashboard.AutoPivot",!
  Write "Compiling class AnalyzeThis.Dashboard.Utils",!
  Write "Compiling class AnalyzeThis.Generator",!
  Write "Compiling class AnalyzeThis.Installer",!
  Write "Compiling class AnalyzeThis.Dashboard.MetaDataAnalyze",!
  Write "Compiling class AnalyzeThis.Dashboard.MetaData",!
  Write "Compiling class AnalyzeThis.Utils",!
  Write "Compiling class diashenrique.REST.Dispatch",!
  Write "Compiling class diashenrique.REST.Routes.Task",!
  Write "Compiling class diashenrique.REST.Routes.Wizard",!
  Write "Compiling class diashenrique.data.Task",!
  Write "Compiling class AnalyzeThis.ThirdParty.NVD3timeChart",!
  Write "Compiling class AnalyzeThis.ThirdParty.ListingInterface",!
  Write "Compiling class AnalyzeThis.ThirdParty.AbstractAmChart",!
  Write "Compiling class AnalyzeThis.ThirdParty.AmSmoothedLineChart",!
  Write "Compiling table diashenrique_data.Task",!
  Write "Compiling table AnalyzeThis_Dashboard.MetaData",!
  Write "Compiling routine AnalyzeThis.Dashboard.MetaDataAnalyze.1",!
  Write "Compiling routine AnalyzeThis.Dashboard.Utils.1",!
  Write "Compiling routine AnalyzeThis.Generator.1",!
  Write "Compiling routine AnalyzeThis.Installer.1",!
  Write "Compiling routine AnalyzeThis.Dashboard.AutoPivot.1",!
  Write "Compiling routine AnalyzeThis.ThirdParty.ListingInterface.1",!
  Write "Compiling routine AnalyzeThis.Utils.1",!
  Write "Compiling routine AnalyzeThis.Dashboard.MetaData.1",!
  Write "Compiling routine AnalyzeThis.ThirdParty.NVD3timeChart.1",!
  Write "Compiling routine diashenrique.REST.Dispatch.1",!
  Write "Compiling routine diashenrique.REST.Routes.Task.1",!
  Write "Compiling routine diashenrique.REST.Routes.Wizard.1",!
  Write "Compiling routine diashenrique.data.Task.1",!
  Write "Compiling routine AnalyzeThis.ThirdParty.AbstractAmChart.1",!
  Write "Compiling routine AnalyzeThis.ThirdParty.AmSmoothedLineChart.1",!
  Write "Generating file: /opt/test/csp/AnalyzeThis_ThirdParty.js",!
  Write "Compilation finished successfully in 1.584s.",!
  Write "",!
  Write "Load finished successfully.",!
  Write "2021-03-17 21:37:40 3 Evaluate: ${FORMSCLASSPATH}/dc/irisrad -> /opt/irisapp/src/dc/irisrad",!
  Write "2021-03-17 21:37:40 1 Import: Loading /opt/irisapp/src/dc/irisrad (isdir=1) into TEST_APP, recurse=1",!
  Write "",!
  Write "Load of directory started on 03/17/2021 21:37:40",!
  Write "",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/FormAdaptor.cls as udl",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/Form.cls as udl",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/Installer.cls as udl",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/Wizard.cls as udl",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/CreationUtility.cls as udl",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/datatype/Password.cls as udl",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/data/ClassCreation.cls as udl",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/data/ClassLineCreation.cls as udl",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/rest/Main.cls as udl",!
  Write "Loading file /opt/irisapp/src/dc/irisrad/default/UserForm.cls as udl",!
  Write "",!
  Write "Compilation started on 03/17/2021 21:37:40 with qualifiers 'c'",!
  Write "Compiling 10 classes, using up to 3 worker jobs",!
  Write "Compiling class dc.irisrad.FormAdaptor",!
  Write "Compiling class dc.irisrad.CreationUtility",!
  Write "Compiling class dc.irisrad.Form",!
  Write "Compiling class dc.irisrad.Wizard",!
  Write "Compiling class dc.irisrad.Installer",!
  Write "Compiling class dc.irisrad.datatype.Password",!
  Write "Compiling class dc.irisrad.rest.Main",!
  Write "Compiling class dc.irisrad.data.ClassCreation",!
  Write "Compiling class dc.irisrad.data.ClassLineCreation",!
  Write "Compiling class dc.irisrad.default.UserForm",!
  Write "Compiling table dc_irisrad_data.ClassCreation",!
  Write "Compiling table dc_irisrad_data.ClassLineCreation",!
  Write "Compiling table dc_irisrad_default.UserForm",!
  Write "Compiling routine dc.irisrad.FormAdaptor.1",!
  Write "Compiling routine dc.irisrad.CreationUtility.1",!
  Write "Compiling routine dc.irisrad.Form.1",!
  Write "Compiling routine dc.irisrad.Wizard.1",!
  Write "Compiling routine dc.irisrad.Installer.1",!
  Write "Compiling routine dc.irisrad.data.ClassCreation.1",!
  Write "Compiling routine dc.irisrad.rest.Main.1",!
  Write "Compiling routine dc.irisrad.data.ClassLineCreation.1",!
  Write "Compiling routine dc.irisrad.default.UserForm.1",!
  Write "Compilation finished successfully in 0.268s.",!
  Write "",!
  Write "Load finished successfully.",!
  Write "2021-03-17 21:37:41 3 Evaluate: ${FORMSCLASSPATH}/Form -> /opt/irisapp/src/Form",!
  Write "2021-03-17 21:37:41 1 Import: Loading /opt/irisapp/src/Form (isdir=1) into TEST_APP, recurse=1",!
  Write "",!
  Write "Load of directory started on 03/17/2021 21:37:41",!
  Write "",!
  Write "Loading file /opt/irisapp/src/Form/Property.cls as udl",!
  Write "Loading file /opt/irisapp/src/Form/REST/Abstract.cls as udl",!
  Write "Loading file /opt/irisapp/src/Form/REST/Field.cls as udl",!
  Write "Loading file /opt/irisapp/src/Form/REST/Form.cls as udl",!
  Write "Loading file /opt/irisapp/src/Form/REST/Objects.cls as udl",!
  Write "",!
  Write "Compilation started on 03/17/2021 21:37:41 with qualifiers 'c'",!
  Write "Compiling 5 classes, using up to 3 worker jobs",!
  Write "Compiling class Form.Property",!
  Write "Compiling class Form.REST.Abstract",!
  Write "Compiling class Form.REST.Objects",!
  Write "Compiling class Form.REST.Field",!
  Write "Compiling class Form.REST.Form",!
  Write "Compiling routine Form.Property.1",!
  Write "Compiling routine Form.REST.Abstract.1",!
  Write "Compiling routine Form.REST.Field.1",!
  Write "Compiling routine Form.REST.Form.1",!
  Write "Compiling routine Form.REST.Objects.1",!
  Write "Compilation finished successfully in 0.065s.",!
  Write "",!
  Write "Load finished successfully.",!
  Write "2021-03-17 21:37:41 3 Evaluate: (${FORCEROUTINES}) && (##class(dc.irisrad.Installer).RoutineExists(""ZAUTHENTICATE.mac"", ""%SYS"")) -> (1) && (##class(dc.irisrad.Installer).RoutineExists(""ZAUTHENTICATE.mac"", ""%SYS""))",!
  Write "2021-03-17 21:37:41 0 : ZAUTHENTICATE.mac replaced; a routine ZAUTHENTICATE_old.mac will be created.",!
  Write "2021-03-17 21:37:41 3 Evaluate: ${FORMSCLASSPATH} -> /opt/irisapp/src",!
  Write "2021-03-17 21:37:41 3 Evaluate: ${FORCEROUTINES} -> 1",!
  Write "",!
  Write "Exporting to XML started on 03/17/2021 21:37:41",!
  Write "Exporting routine: ZAUTHENTICATE.mac",!
  Write "Export finished successfully.",!
  Write "",!
  Write "Load started on 03/17/2021 21:37:41",!
  Write "Loading file /opt/irisapp/src/IRISRADAUTHENTICATE.mac as udl",!
  Write "IRISRADAuthentication.MAC Loaded",!
  Write "Compiling routine : IRISRADAuthentication.mac",!
  Write "Load finished successfully.",!
  Write "",!
  Write "Load started on 03/17/2021 21:37:41",!
  Write "Loading file /opt/irisapp/src/ZAUTHENTICATE.mac as udl",!
  Write "ZAUTHENTICATE.MAC Loaded",!
  Write "Compiling routine : ZAUTHENTICATE.mac",!
  Write "Load finished successfully.",!
  Write "2021-03-17 21:37:41 3 Evaluate: ${CSPAPPPATH} -> /opt/test-app/csp/",!
  Write "2021-03-17 21:37:41 3 Evaluate: /csp/${APPNAME}-app -> /csp/test-app",!
  Write "2021-03-17 21:37:41 3 Evaluate: ${CSPAPPPATH} -> /opt/test-app/csp/",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate: 8224 -> 8224",!
  Write "2021-03-17 21:37:41 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:41 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:41 3 Evaluate: 0 -> 0",!
  Write "2021-03-17 21:37:41 3 Evaluate: 0 -> 0",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate: 1 -> 1",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate:  ->",!
  Write "2021-03-17 21:37:41 3 Evaluate: %DB_${NAMESPACE},%SQL -> %DB_TEST_APP,%SQL",!
  Write "2021-03-17 21:37:41 1 CSPApplication: Creating /csp/test-app in TEST_APP, using /opt/test-app/csp/",!
  Write "2021-03-17 21:37:41 3 Evaluate: /csp/${APPNAME}-app -> /csp/test-app",!
  Write "2021-03-17 21:37:41 3 Evaluate: ${RESTAPPNAME} -> /test-app/forms",!
  Write "2021-03-17 21:37:41 3 Evaluate: ${NAMESPACE} -> TEST_APP",!
  Write "1112021-03-17 21:37:41 3 Evaluate: ${NEW_APP_FORMS_PATH} -> /tmp/test",!
  Write "2021-03-17 21:37:41 1 Import: Loading /tmp/test (isdir=1) into TEST_APP, recurse=0",!
  Write "",!
  Write "Load of directory started on 03/17/2021 21:37:41",!
  Write "",!
  Write "Loading file /tmp/test/User.forms.grocery.GroceryProductForm.cls as xml",!
  Write "Imported class: User.forms.grocery.GroceryProductForm",!
  Write "Loading file /tmp/test/User.forms.grocery.GroceryListForm.cls as xml",!
  Write "Imported class: User.forms.grocery.GroceryListForm",!
  Write "",!
  Write "Compilation started on 03/17/2021 21:37:41 with qualifiers 'c'",!
  Write "Compiling 2 classes, using up to 3 worker jobs",!
  Write "Compiling class User.forms.grocery.GroceryProductForm",!
  Write "Compiling class User.forms.grocery.GroceryListForm",!
  Write "Compiling table User_forms_grocery.GroceryProductForm",!
  Write "Compiling table User_forms_grocery.GroceryListForm",!
  Write "Compiling routine User.forms.grocery.GroceryProductForm.1",!
  Write "Compiling routine User.forms.grocery.GroceryListForm.1",!
  Write "Compilation finished successfully in 0.118s.",!
  Write "",!
  Write "Load finished successfully.",!
  Write "2021-03-17 21:37:41 3 Evaluate: ${SRC_PATH} -> /opt/irisapp/src/csp",!
  Write "2021-03-17 21:37:41 3 Evaluate: ${CSPAPPPATH} -> /opt/test-app/csp/",!
  Write "2021-03-17 21:37:41 1 CopyDir: Copying directory /opt/irisapp/src/csp to /opt/test-app/csp/",!
  Write "2021-03-17 21:37:42 3 Evaluate: ${CSPAPPPATH} -> /opt/test-app/csp/",!
  Write "2021-03-17 21:37:42 3 Evaluate: ${RESTAPPNAME} -> /test-app/forms",!
  Write "2021-03-17 21:37:42 0 dc.irisrad.Installer: Installation succeeded at 2021-03-17 21:37:42",!
  Write "2021-03-17 21:37:42 0 %Installer: Elapsed time 12.216839s",!
  Return sc
}

}
