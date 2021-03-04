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
<Route Url="/form/class/:id" Method="GET" Call="dc.irisrad.CreationUtility:GetClassById" />
<Route Url="/form/class/fields/:id" Method="GET" Call="dc.irisrad.CreationUtility:GetFields" />

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

}
