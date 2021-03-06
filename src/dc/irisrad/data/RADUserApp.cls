/// User's RAD apps
Class dc.irisrad.data.RADUserApp Extends %Persistent
{

Property RADUser As dc.irisrad.data.RADUser;

Property AppName As %String(MAXLEN = 256);

Property AppNamespace As %String(MAXLEN = 256);

Property AppDesc As %String(MAXLEN = "");

Property AppURL As %String(MAXLEN = "");

ForeignKey FkRADUser(RADUser) References dc.irisrad.data.RADUser() [ OnDelete = cascade ];

Index IdxAppNamespace On AppNamespace [ Unique ];

Index IdxUserAppName On (RADUser, AppName) [ Unique ];

Index IdxAppName On AppName [ Unique ];

/// Check if a namespace is from a RAD app
ClassMethod IsNamespaceRADApp(pNamespace As %String) As %Boolean
{
  Return:(pNamespace = ##class(dc.irisrad.Installer).#DefaulSystemNS) $$$OK
  Return ##class(dc.irisrad.data.RADUserApp).IdxAppNamespaceExists(pNamespace)
}

/// Check if the user is in RAD admins table
ClassMethod IsUserRADAdminApp(pUsername As %String, pAppName As %String = "") As %Boolean
{
  Set isUserRADAdminApp = 0
  Set originalNS = $NAMESPACE
  Try {
    ZNspace ##class(dc.irisrad.Installer).#DefaulSystemNS
    If (pAppName = "") {
      Set isUserRADAdminApp = ##class(dc.irisrad.data.RADUser).IdxUsernameExists(pUsername)
    } Else {
      Do ##class(dc.irisrad.data.RADUser).IdxUsernameExists(pUsername, .userId)
      Set isUserRADAdminApp = ##class(dc.irisrad.data.RADUserApp).IdxUserAppNameExists(userId, pAppName)
    }
  }
  Catch ex {
    Set sc=ex.AsStatus()
  }
  ZNspace originalNS
  Return isUserRADAdminApp
}

/// Get all applications for a user
ClassMethod GetUserApps(pUsername As %String) As %SQL.StatementResult
{
  Set sc = $$$OK
  Set sql = 
  "SELECT JSON_ARRAYAGG(JSON_OBJECT("_
    "'ID':ID, "_
    "'AppName':AppName, "_
    "'AppNamespace':AppNamespace, "_
    "'AppDesc': AppDesc, "_
    "'AppURL': AppURL"_
  ")) Apps FROM ("_
    "SELECT * FROM dc_irisrad_data.RADUserApp WHERE RADUser->Username = ?"_
  ")"
  Set stmt = ##class(%SQL.Statement).%New()
  $$$TOE(st, stmt.%Prepare(sql))
  Return stmt.%Execute(pUsername)
}

Storage Default
{
<Data name="RADUserAppDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RADUser</Value>
</Value>
<Value name="3">
<Value>AppName</Value>
</Value>
<Value name="4">
<Value>AppNamespace</Value>
</Value>
<Value name="5">
<Value>AppDesc</Value>
</Value>
<Value name="6">
<Value>AppURL</Value>
</Value>
</Data>
<DataLocation>^dc.irisrad.data.RADUserAppD</DataLocation>
<DefaultData>RADUserAppDefaultData</DefaultData>
<IdLocation>^dc.irisrad.data.RADUserAppD</IdLocation>
<IndexLocation>^dc.irisrad.data.RADUserAppI</IndexLocation>
<StreamLocation>^dc.irisrad.data.RADUserAppS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
