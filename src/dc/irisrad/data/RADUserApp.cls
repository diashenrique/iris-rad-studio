/// User's RAD apps
Class dc.irisrad.data.RADUserApp Extends %Persistent
{

Property User As dc.irisrad.data.RADUser;

Property AppName As %String(MAXLEN = 256);

Property AppNamespace As %String(MAXLEN = 256);

Property AppDesc As %String(MAXLEN = "");

ForeignKey fkUser(User) References dc.irisrad.data.RADUser() [ OnDelete = cascade ];

Index IdxAppNamespace On AppNamespace [ Unique ];

/// Default system namespace
Parameter DefaulSystemNS = "IRISAPP";

/// Check if a namespace is from a RAD app
ClassMethod IsNamespaceRADApp(pNamespace As %String) As %Boolean
{
  Return:(pNamespace = ..#DefaulSystemNS) $$$OK
  Return ##class(dc.irisrad.data.RADUserApp).IdxAppNamespaceExists(pNamespace)
}

Storage Default
{
<Data name="RADUserAppDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>User</Value>
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
</Data>
<DataLocation>^dc.irisrad.data.RADUserAppD</DataLocation>
<DefaultData>RADUserAppDefaultData</DefaultData>
<IdLocation>^dc.irisrad.data.RADUserAppD</IdLocation>
<IndexLocation>^dc.irisrad.data.RADUserAppI</IndexLocation>
<StreamLocation>^dc.irisrad.data.RADUserAppS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
