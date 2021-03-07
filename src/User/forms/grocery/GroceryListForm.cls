Class User.forms.grocery.GroceryListForm Extends (%Persistent,  dc.irisrad.FormAdaptor) [ Inheritance = right, Not ProcedureBlock ]
{

Property itemName As User.forms.grocery.GroceryProductForm(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Item");

Property amount As %Library.String(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Amount");

Property done As %Library.Boolean(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Done");

Property user As dc.irisrad.default.UserForm(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "User");

Parameter DISPLAYPROPERTY = "itemName";

Parameter FORMNAME = "My grocery list";

Parameter OBJPERMISSIONS = "CRUD";

Storage Default
{
<Data name="GroceryListFormDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>itemName</Value>
</Value>
<Value name="3">
<Value>amount</Value>
</Value>
<Value name="4">
<Value>done</Value>
</Value>
<Value name="5">
<Value>user</Value>
</Value>
</Data>
<DataLocation>^User.formsEA1D.GroceryListA6A1D</DataLocation>
<DefaultData>GroceryListFormDefaultData</DefaultData>
<IdLocation>^User.formsEA1D.GroceryListA6A1D</IdLocation>
<IndexLocation>^User.formsEA1D.GroceryListA6A1I</IndexLocation>
<StreamLocation>^User.formsEA1D.GroceryListA6A1S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
