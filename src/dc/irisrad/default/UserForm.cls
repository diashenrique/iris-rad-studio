Include (%occStatus, %occErrors)

Class dc.irisrad.default.UserForm Extends (%Persistent, dc.irisrad.FormAdaptor) [ Inheritance = right, Not ProcedureBlock ]
{

Property name As %Library.String(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Name");

Property username As %Library.String(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "User name");

Property password As dc.irisrad.datatype.Password(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Password");

Parameter DISPLAYPROPERTY = "name";

Parameter FORMNAME = "Users";

Parameter OBJPERMISSIONS = "CRUD";

Index idxUsername On username [ Unique ];

ClassMethod Hash(pValue As %String) As %String
{
  Return $SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1Hash(pValue))
}

Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
  // Ensure that password is not stored in plain text
  Set oldPassword = ##class(dc.irisrad.default.UserForm).passwordGetStored(..%Id())
  If (..password '= oldPassword) {
    Set ..password = ..Hash(..password)
  }
	Quit $$$OK
}

Trigger Trigger [ Event = UPDATE ]
{
  // Ensure that password is not stored in plain text
  If ({password} '= {password*O}) {
	  Set {password} = ..Hash({password})
  }
}

ClassMethod Authenticate(pUsername As %String, pPassword As %String, ByRef pProperties, ByRef pStatus As %Status) As %Status
{
  Set pStatus = $$$OK
  
  // Check if username is valid
  Set sql = "SELECT name FROM dc_irisrad_default.UserForm WHERE username = ?"
  Set stmt = ##class(%SQL.Statement).%New()
  $$$TOE(st, stmt.%Prepare(sql))
  Set rs = stmt.%Execute(pUsername)
  Do rs.%Next()
  Set fullName = rs.name
  If (fullName = "") {
    Set pStatus = $SYSTEM.Status.Error($$$UserDoesNotExist)
    Quit pStatus
  }
  Kill rs, stmt

  // Check if username and password are valid
  Set encPsw = ..Hash(pPassword)
  Set sql = "SELECT name FROM dc_irisrad_default.UserForm WHERE username = ? AND password = ?"
  Set stmt = ##class(%SQL.Statement).%New()
  $$$TOE(st, stmt.%Prepare(sql))
  Set rs = stmt.%Execute(pUsername, encPsw)
  Do rs.%Next()
  Set fullName = rs.name
  If (fullName = "") {
    Set pStatus = $SYSTEM.Status.Error($$$UserInvalidPassword)
    Quit pStatus
  }
  Kill rs, stmt

  // IRIS's user properties
  Set pProperties("FullName") = fullName
  Set pProperties("Comment") = ""
  Set pProperties("Roles") = "%All"
  Set pProperties("NameSpace") = $NAMESPACE
  Set pProperties("Routine") = ""
  Set pProperties("Password") = encPsw
  Set pProperties("Username") = pUsername
  
  Return pStatus
}

Storage Default
{
<Data name="UserFormDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
<Value name="3">
<Value>username</Value>
</Value>
<Value name="4">
<Value>password</Value>
</Value>
</Data>
<DataLocation>^dc.irisrad.default.UserFormD</DataLocation>
<DefaultData>UserFormDefaultData</DefaultData>
<IdLocation>^dc.irisrad.default.UserFormD</IdLocation>
<IndexLocation>^dc.irisrad.default.UserFormI</IndexLocation>
<StreamLocation>^dc.irisrad.default.UserFormS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
