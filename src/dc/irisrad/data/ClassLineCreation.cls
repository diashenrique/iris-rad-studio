Class dc.irisrad.data.ClassLineCreation Extends %Persistent
{

/// Parent Class
Property ParentClass As dc.irisrad.data.ClassCreation;

/// Field Name
Property FieldName As %String;

/// Field Type
Property FieldType As %String;

/// IsRequired
Property IsRequired As %Boolean;

/// DisplayName
Property DisplayName As %String;

/// ClassRelated
Property ClassRelated As %String;

Storage Default
{
<Data name="ClassLineCreationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ParentClass</Value>
</Value>
<Value name="3">
<Value>FieldName</Value>
</Value>
<Value name="4">
<Value>FieldType</Value>
</Value>
<Value name="5">
<Value>IsRequired</Value>
</Value>
<Value name="6">
<Value>DisplayName</Value>
</Value>
<Value name="7">
<Value>ClassRelated</Value>
</Value>
</Data>
<DataLocation>^dc.irisradFF4F.ClassLineCr2574D</DataLocation>
<DefaultData>ClassLineCreationDefaultData</DefaultData>
<IdLocation>^dc.irisradFF4F.ClassLineCr2574D</IdLocation>
<IndexLocation>^dc.irisradFF4F.ClassLineCr2574I</IndexLocation>
<StreamLocation>^dc.irisradFF4F.ClassLineCr2574S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
