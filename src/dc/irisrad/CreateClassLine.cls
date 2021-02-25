Class dc.irisrad.CreateClassLine Extends %Persistent
{

/// Form Parent
Property FormId As dc.irisrad.CreateClass;

/// Field Name
Property FieldName As %String;

/// Field Type
Property FieldType As %String;

Storage Default
{
<Data name="CreateClassLineDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FormId</Value>
</Value>
<Value name="3">
<Value>FieldName</Value>
</Value>
<Value name="4">
<Value>FieldType</Value>
</Value>
</Data>
<DataLocation>^dc.irisrad.CreateClassLineD</DataLocation>
<DefaultData>CreateClassLineDefaultData</DefaultData>
<IdLocation>^dc.irisrad.CreateClassLineD</IdLocation>
<IndexLocation>^dc.irisrad.CreateClassLineI</IndexLocation>
<StreamLocation>^dc.irisrad.CreateClassLineS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
