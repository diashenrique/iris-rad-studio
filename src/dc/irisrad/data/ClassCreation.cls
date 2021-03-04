Class dc.irisrad.data.ClassCreation Extends %Persistent
{

/// Class Name
Property ClassName As %String [ Required ];

/// Class Description 
Property Description As %String(MAXLEN = 250);

Storage Default
{
<Data name="ClassCreationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ClassName</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
</Data>
<DataLocation>^dc.irisrad.data.ClassCreationD</DataLocation>
<DefaultData>ClassCreationDefaultData</DefaultData>
<IdLocation>^dc.irisrad.data.ClassCreationD</IdLocation>
<IndexLocation>^dc.irisrad.data.ClassCreationI</IndexLocation>
<StreamLocation>^dc.irisrad.data.ClassCreationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
