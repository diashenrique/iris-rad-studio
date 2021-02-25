Class User.forms.TestForm Extends (%Persistent, Form.Adaptor) [ Inheritance = right, Not ProcedureBlock ]
{

Property name As %Library.String(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "OBJECT", DISPLAYNAME = "Name");

Property spouse As Form.Test.Person(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Spouse");

Property children As list Of Form.Test.Person(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Children");

Parameter DISPLAYPROPERTY = "name";

Parameter FORMNAME = "FormTest";

Parameter OBJPERMISSIONS = "CRUD";

ClassMethod customqueryDEFAULT() As %String
{
  Quit "SELECT name, spouse->name spouse, "_
    "(SELECT LIST(name) FROM Form_Test.Person WHERE ID %INLIST dc_irisrad.Form_FlattenList(User_forms_TestForm1.children)) children "_
    "FROM User_forms.TestForm User_forms_TestForm1"
}

Parameter ToolbarUIDef = "User.forms.TestForm||toolbarTestFormUI";

Parameter CustomUIDef = "User.forms.TestForm||customTestFormUI";

XData toolbarTestFormUI
{
<jsonContext>
  <![CDATA[
[{
   "location":"before",
   "widget":"dxButton",
   "options":{
      "type":"back",
      "onClick":function(){
        DevExpress.ui.notify("Back button has been clicked!");
      }
   }
},
{
   "location":"before",
   "widget":"dxButton",
   "locateInMenu":"auto",
   "options":{
      "icon":"refresh",
      "onClick":function(){
        DevExpress.ui.notify("Refresh button has been clicked!");
      }
   }
},
{
   "location":"center",
   "locateInMenu":"never",
   "template":function(){
      return $("<div class='toolbar-label'><b>Tom's Club</b> Products</div>");
   }
},
{
   "location":"after",
   "widget":"dxSelectBox",
   "locateInMenu":"auto",
   "options":{
      "width":140,
      "valueExpr":"id",
      "displayExpr":"text"
   }
},
{
   "location":"after",
   "widget":"dxButton",
   "locateInMenu":"auto",
   "options":{
      "icon":"plus",
      "onClick":function(){
         DevExpress.ui.notify("Add button has been clicked!");
      }
   }
},
{
   "locateInMenu":"always",
   "text":"Save",
   "onClick":function(){
      DevExpress.ui.notify("Save option has been clicked!");
   }
},
{
   "locateInMenu":"always",
   "text":"Print",
   "onClick":function(){
      DevExpress.ui.notify("Print option has been clicked!");
   }
},
{
   "locateInMenu":"always",
   "text":"Settings",
   "onClick":function(){
      DevExpress.ui.notify("Settings option has been clicked!");
   }
}]
  ]]>
</jsonContext>
}

XData customTestFormUI
{
<jsonContext>
  <![CDATA[
{
   "colCount":2,
   "items":[
      {
         "dataField":"FirstName",
         "editorOptions":{
            "disabled":true
         }
      },
      {
         "dataField":"LastName",
         "editorOptions":{
            "disabled":true
         }
      },
      {
         "dataField":"HireDate",
         "editorType":"dxDateBox",
         "editorOptions":{
            "value":null,
            "width":"100%"
         },
         "validationRules":[
            {
               "type":"required",
               "message":"Hire date is required"
            }
         ]
      },
      {
         "dataField":"BirthDate",
         "editorType":"dxDateBox",
         "editorOptions":{
            "disabled":true,
            "width":"100%"
         }
      },
      "Address",
      {
         "colSpan":2,
         "dataField":"Notes",
         "editorType":"dxTextArea",
         "editorOptions":{
            "height":90
         }
      },
      "Email",
      {
         "dataField":"Phone",
         "editorOptions":{
            "mask":"+1 (X00) 000-0000",
            "maskRules":{
               "X":/[02-9]/
            }
         }
      },
      {
         "itemType":"button",
         "horizontalAlignment":"left",
         "buttonOptions":{
            "text":"Register",
            "type":"success"
         }
      }
   ]
}
  ]]>
</jsonContext>
}

Storage Default
{
<Data name="TestFormDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
<Value name="3">
<Value>spouse</Value>
</Value>
<Value name="4">
<Value>children</Value>
</Value>
</Data>
<DataLocation>^User.forms.TestFormD</DataLocation>
<DefaultData>TestFormDefaultData</DefaultData>
<IdLocation>^User.forms.TestFormD</IdLocation>
<IndexLocation>^User.forms.TestFormI</IndexLocation>
<StreamLocation>^User.forms.TestFormS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
