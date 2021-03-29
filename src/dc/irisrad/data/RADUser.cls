Include (%occStatus, %occErrors)

/// System's RAD admins
Class dc.irisrad.data.RADUser Extends (%Persistent, dc.irisrad.FormAdaptor) [ Inheritance = right, Not ProcedureBlock ]
{

Property Username As %Library.String(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "User name") [ Required ];

Property Password As dc.irisrad.datatype.Password(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Password") [ Required ];

Property FullName As %Library.String(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Full name") [ Required ];

Property Enabled As %Library.Boolean(%JSONINCLUDE = "INOUT", %JSONREFERENCE = "ID", DISPLAYNAME = "Enabled") [ Required ];

Parameter DISPLAYPROPERTY = "Username";

Parameter FORMNAME = "RAD Users";

Parameter OBJPERMISSIONS = "CRUD";

Index IdxUsername On Username [ Unique ];

/// RAD system superuser
Parameter RADSuperUser = "rad";

Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
  // Ensure that password is not stored in plain text
  Set oldPassword = ##class(dc.irisrad.data.RADUser).PasswordGetStored(..%Id())
  If (..Password '= oldPassword) {
    Set ..Password = ##class(dc.irisrad.default.UserForm).Hash(..Password)
  }
	Quit $$$OK
}

Trigger Trigger [ Event = UPDATE ]
{
  // Ensure that password is not stored in plain text
  If ({Password} '= {Password*O}) {
	  Set {Password} = ##class(dc.irisrad.default.UserForm).Hash({Password})
  }
}

/// Check if the user is in RAD admins table
ClassMethod IsUserRADAdmin(pUsername As %String) As %Boolean
{
  Return ##class(dc.irisrad.data.RADUser).IdxUsernameExists(pUsername)
}

/// Authenticate a RAD admin user
ClassMethod Authenticate(pUsername As %String, pPassword As %String, ByRef pProperties) As %Status
{
  Set sc = $$$OK

  Set user = ##class(dc.irisrad.data.RADUser).IdxUsernameOpen(pUsername,, .sc)
  Return:($$$ISERR(sc)) $SYSTEM.Status.Error($$$UserDoesNotExist)

  Set encPsw = ##class(dc.irisrad.default.UserForm).Hash(pPassword)
  Return:(encPsw '= user.Password) $SYSTEM.Status.Error($$$UserInvalidPassword)

  Set pProperties("FullName") = user.FullName
  Set pProperties("Comment") = ""
  // todo: review the right roles
  Set pProperties("Roles") = "%All"
  Set pProperties("NameSpace") = $NAMESPACE
  Set pProperties("Routine") = ""
  Set pProperties("Password") = encPsw
  Set pProperties("Username") = pUsername

  Return sc
}

/// Insert superuser
ClassMethod CreateSuperUser(pPassword As %String = "SYS") As %Status
{
  Set sc = $$$OK
  Set superuser = ##class(dc.irisrad.data.RADUser).%New()
  Set superuser.Username = ..#RADSuperUser
  Set superuser.Password = pPassword
  Set superuser.FullName = "IRIS RAD Admin"
  Set superuser.Enabled = 1
  Set sc = superuser.%Save()
  Return sc
}

Storage Default
{
<Data name="RADUserDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Username</Value>
</Value>
<Value name="3">
<Value>Password</Value>
</Value>
<Value name="4">
<Value>FullName</Value>
</Value>
<Value name="5">
<Value>Enabled</Value>
</Value>
</Data>
<DataLocation>^dc.irisrad.data.RADUserD</DataLocation>
<DefaultData>RADUserDefaultData</DefaultData>
<IdLocation>^dc.irisrad.data.RADUserD</IdLocation>
<IndexLocation>^dc.irisrad.data.RADUserI</IndexLocation>
<StreamLocation>^dc.irisrad.data.RADUserS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
