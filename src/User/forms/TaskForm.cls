Class User.forms.TaskForm Extends (%Persistent, dc.irisrad.FormAdaptor) [ Inheritance = right, Not ProcedureBlock ]
{

Property text As %Library.String(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Task name");

Property taskDate As %Library.TimeStamp(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Task date");

Property important As %Library.Boolean(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Important");

Property completed As %Library.Boolean(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Completed");

Parameter DISPLAYPROPERTY = "text";

Parameter FORMNAME = "FormTest";

Parameter OBJPERMISSIONS = "CRUD";

ClassMethod customqueryNEXTWEEK() As %String
{
  Quit "Select text, taskDate, important "_
    "FROM User_forms.TaskForm "_
    "WHERE completed = 0 AND taskDate >= '2021-03-01 00:00:00' "
}

ClassMethod GetQueryInfo(query As %String) As %Status
{
  Set sc = $$$OK
  // todo: improve this by using statement metadata
  Set fields = [{
    "category": "datatype",
    "displayName": "Task",
    "name": "text",
    "type": "%Library.String"
  },{
    "category": "datatype",
    "displayName": "Date",
    "name": "taskDate",
    "type": "%Library.TimeStamp"
  },{
    "category": "datatype",
    "displayName": "important",
    "name": "important",
    "type": "%Library.Boolean"
  }]
  Set info = {
    "class": "User.forms.TaskForm",
    "displayProperty": "text",
    "fields": (fields)
  }
  Write info.%ToJSON()
  Return sc
}

Parameter ToolbarUIDef = "User.forms.TaskForm||toolbarTestFormUI";

XData toolbarTestFormUI
{
<jsonContext>
  <![CDATA[
[{
   "location":"before",
   "widget":"dxButton",
   "options":{
      "text":"Next week",
      "onClick":function(){
        window.location.href = 'rad.html?formName=User.forms.TaskForm&queryName=NextWeek'
      }
   }
}]
  ]]>
</jsonContext>
}

Storage Default
{
<Data name="TaskFormDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>text</Value>
</Value>
<Value name="3">
<Value>taskDate</Value>
</Value>
<Value name="4">
<Value>important</Value>
</Value>
<Value name="5">
<Value>completed</Value>
</Value>
</Data>
<DataLocation>^User.forms.TaskFormD</DataLocation>
<DefaultData>TaskFormDefaultData</DefaultData>
<IdLocation>^User.forms.TaskFormD</IdLocation>
<IndexLocation>^User.forms.TaskFormI</IndexLocation>
<StreamLocation>^User.forms.TaskFormS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
