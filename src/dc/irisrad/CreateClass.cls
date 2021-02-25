Class dc.irisrad.CreateClass Extends %Persistent
{

/// Class Name
Property ClassName As %String;

/// Description
Property Description As %String;

Storage Default
{
<Data name="CreateClassDefaultData">
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
<DataLocation>^dc.irisrad.CreateClassD</DataLocation>
<DefaultData>CreateClassDefaultData</DefaultData>
<IdLocation>^dc.irisrad.CreateClassD</IdLocation>
<IndexLocation>^dc.irisrad.CreateClassI</IndexLocation>
<StreamLocation>^dc.irisrad.CreateClassS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
