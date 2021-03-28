/// REST dispatcher for unauthenticated requests
Class dc.irisrad.rest.UnAuth Extends dc.irisrad.rest.Main
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "RAW";

Parameter UseSession As Integer = 0;

Parameter CONVERTINPUTSTREAM = 0;

Parameter HandleCorsRequest = 1;

/// todo: there are too much rotes here; analyse and separate them into subject-oriented classes
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Map Prefix="/form" Forward="Form.REST.Form"/>
<Route Url="/signup" Method="POST" Call="SignUp"/>
</Routes>
}

/// Performs user sign up
ClassMethod SignUp() As %Status
{
  Set sc = $$$OK
  write "OK"
  Return sc
}

}
