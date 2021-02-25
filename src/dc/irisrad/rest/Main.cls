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
    Set form.DisplayField = body.displayProperty
    Set form.Fields = body.fields
    $$$TOE(sc, form.Save())
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
    $$$TOE(sc, ##class(%Dictionary.ClassDefinition).%DeleteId(pFormName))
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
