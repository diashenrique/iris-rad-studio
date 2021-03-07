Class User.forms.grocery.GroceryProductForm Extends (%Persistent,  dc.irisrad.FormAdaptor) [ Inheritance = right, Not ProcedureBlock ]
{

Property prodName As %Library.String(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Product");

Property user As dc.irisrad.default.UserForm(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "User");

Parameter DISPLAYPROPERTY = "prodName";

Parameter FORMNAME = "My grocery products";

Parameter OBJPERMISSIONS = "CRUD";

Storage Default
{
<Data name="GroceryProductFormDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>prodName</Value>
</Value>
<Value name="3">
<Value>user</Value>
</Value>
</Data>
<DataLocation>^User.formsEA1D.GroceryProd15FFD</DataLocation>
<DefaultData>GroceryProductFormDefaultData</DefaultData>
<IdLocation>^User.formsEA1D.GroceryProd15FFD</IdLocation>
<IndexLocation>^User.formsEA1D.GroceryProd15FFI</IndexLocation>
<StreamLocation>^User.formsEA1D.GroceryProd15FFS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
