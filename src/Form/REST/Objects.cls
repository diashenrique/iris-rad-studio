/// Broker class to work with queries
Class Form.REST.Objects Extends Form.REST.Abstract
{

/// Query to return all availible information about form objects
Parameter ALL = "*, %CLASSNAME AS _class";

/// Query to return objects count
Parameter COUNT = "count(1) ""count""";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/:form/custom/:query" Method="GET" Call="getFormObjectsCustom"/>
<Route Url="/:form/:query" Method="GET" Call="getFormObjects"/>
</Routes>
}

/// Get all form objects
ClassMethod getFormObjects(class As %String = "", queryType As %String) As %Status
{
	#dim sc As %Status = $$$OK
	Set sc = ##class(Form.Info).formExistsStatus(class)
	Return:$$$ISERR(sc) sc
	Set sc = ..checkObjPermission(class, "R")
	Return:$$$ISERR(sc) sc
	Set sc = ..getBaseQuery(queryType, class, .queryBase)
	Return:$$$ISERR(sc) sc

	Set table = ##class(%CSP.UI.Portal.SQL.Home).Quoter2($$$ClassSQLTable(class))
	Set sql = queryBase _ table

	Set sc = ..InsertUserConstraintClause(class, .sql)

	Set sc = ##class(Form.JSON.SQL).WriteJSONFromSQL(sql, class)
	Return sc
}

ClassMethod InsertUserConstraintClause(class As %String, ByRef sql As %String) As %Status
{
	// todo: add logic for admin user
	Set username = $ZCONVERT($USERNAME, "L")
	If (username = ##class(dc.irisrad.data.RADUser).#RADSuperUser) {
		Return $$$OK
	}

	Set sc = $$$OK
	Set userClass = "dc.irisrad.default.UserForm"
	Set userField = "user"
	Set objUserField = ##class(%Dictionary.PropertyDefinition).IDKEYOpen(class, userField)
	// todo: add logic for detect relationship
	If ($ISOBJECT(objUserField)) && (objUserField.Type = userClass) {
		Set sql = sql_" where """_userField_"""->username = '"_$USERNAME_"'"
	}
	If (class = userClass) {
		Set sql = sql_" where username = '"_$USERNAME_"'"
	}
	Return sc
}

/// Returns the part between SELECT and FORM (queryBase) based on queryType and target class
/// Supported queryBase sources:<br>
/// 1. Uppercase parameter values defined in this class<br>
/// 2. ClassMethods, defined in this class with the name: queryQUERYTYPE
ClassMethod getBaseQuery(queryType As %String, class As %String, Output queryBase As %String) As %Status
{
	Set queryBase = ""
	Set queryType = $ZCONVERT(queryType, "U")
	Set userQueryClass = ##class(Form.Settings).getSetting("queryclass")
	#dim sc As %Status = $$$OK
	If ##class(%Dictionary.CompiledMethod).IDKEYExists(class, "query" _ queryType) {
		Set queryBase = $CLASSMETHOD(class, "query" _ queryType)
	}
  ElseIf ((userQueryClass'="") && (##class(%Dictionary.CompiledParameter).IDKEYExists(userQueryClass, queryType))) {
		Set queryBase = $PARAMETER(userQueryClass, queryType)
	}
  ElseIf ((userQueryClass'="") && (##class(%Dictionary.CompiledMethod).IDKEYExists(userQueryClass, "query" _ queryType))) {
		Set queryBase = $CLASSMETHOD(userQueryClass, "query" _ queryType, class)
	}
  ElseIf ##class(%Dictionary.CompiledParameter).IDKEYExists($CLASSNAME(), queryType) {
		Set queryBase = $PARAMETER(, queryType)
	}
  ElseIf ##class(%Dictionary.CompiledMethod).IDKEYExists($CLASSNAME(), "query" _ queryType) {
		Set queryBase = $CLASSMETHOD(, "query" _ queryType, class)
	}
  ElseIf 0 {
		/// TODO Some other type of "get stuff between SELECT and FROM"
	}
  Else {
		Set sc = $$$ERROR($$$GeneralError, "Query type " _ queryType _ " not found")
	}

	If (queryBase'="") {
		Set queryBase = "SELECT " _ queryBase _ " FROM "
	}

	Return sc
}

/// Return id and dislpayName
/// <example>w ##class(Form.REST.Objects).queryINFO("Form.Test.Simple")</example>
ClassMethod queryINFO(class As %String) As %String
{
	Set method = "getObjectDisplayName"

	If ##class(%Dictionary.CompiledMethod).IDKEYExists(class, method) {
		Set sqlProc = $$$ClassSQLTable(class) _ "_" _ method _ "(id)"
	}
  Else {
		Set sqlProc = $PARAMETER(class, $$$displayProp)
	}

	Set queryBase = "id AS _id, " _ sqlProc _ " As displayName"
	Return queryBase
}

/// Return all non collection object fields
/// <example>w ##class(Form.REST.Objects).queryALLOBJ("Form.Test.Simple")</example>
ClassMethod queryALLOBJ(class As %String) As %String
{
	Set queryBase = "%ID ID, "
	Set property=$$$comMemberNext(class, $$$cCLASSproperty, "")
	While property'="" {
		Set internal = $$$comMemberKeyGet(class, $$$cCLASSproperty, property, $$$cPROPinternal)
		Set displayName = ##class(Form.Property).getPropertyParam(class, property, $$$propDisplayNameParam)
		Set collection = $$$comMemberKeyGet(class, $$$cCLASSproperty, property, $$$cPROPcollection)
		If ((internal '= $$$YES) && (displayName'="")) {
			Set type = ##class(Form.Property).getPropertyType(class, property)
			Set category = ##class(Form.Property).determineClassCategory(type)
			Set sqlName = ##class(Form.Property).getPropertySQLName(class, property)

			If category = $$$cCLASSCLASSTYPESERIAL {
				Set queryBase = queryBase _ ..SerialToJSONOBJECT(sqlName, type)
			} ElseIf(collection '= "") {
				If (category = "form") {
					Set queryBase = queryBase _ "dc_irisrad.Form_toJSON('"_class_"', ID, '"_sqlName_"') JSON@"_sqlName
				} Else {
					Set property=$$$comMemberNext(class, $$$cCLASSproperty, property)
					Continue
				}
			} Else {
				Set:$SYSTEM.SQL.IsReservedWord(sqlName) sqlName = $$$QUOTE(sqlName)
				Set queryBase = queryBase _ sqlName
			}
			Set queryBase = queryBase _ ", "
		}
		
		Set property=$$$comMemberNext(class, $$$cCLASSproperty, property)		
	}

	Set queryBase = $EXTRACT(queryBase, 1,*-2) 
	Return queryBase
}

/// refProperty - property name for a serial class
/// class - serial class
ClassMethod SerialToJSONOBJECT(refProperty As %String, class As %Dictionary.Classname, level As %Integer = 0) As %String
{
	Set queryBase = "JSON_OBJECT("
	Set property=$$$comMemberNext(class, $$$cCLASSproperty, "")
	While property'="" {
		Set internal = $$$comMemberKeyGet(class, $$$cCLASSproperty, property, $$$cPROPinternal)
		Set collection = $$$comMemberKeyGet(class, $$$cCLASSproperty, property, $$$cPROPcollection)
		If ((internal '= $$$YES) && (collection = "")) {
			Set type = ##class(Form.Property).getPropertyType(class, property)
			Set category = ##class(Form.Property).determineClassCategory(type)
			Set sqlName = ##class(Form.Property).getPropertySQLName(class, property)
		
			If category = $$$cCLASSCLASSTYPESERIAL {
				Set queryBase = queryBase _ "'" _ sqlName _ "':" _ ..SerialToJSONOBJECT(refProperty _ "_" _ sqlName, type, level + 1)
			} Else {
				Set queryBase = queryBase _ "'" _ sqlName _ "':" _  refProperty _ "_" _ sqlName
			}
			Set queryBase = queryBase _ ", "
		}
		
		Set property=$$$comMemberNext(class, $$$cCLASSproperty, property)		
	}

	Set queryBase = $EXTRACT(queryBase, 1,*-2) _ ") " _ $SELECT(level=0:$$$jsonLabel _ refProperty, 1:"")
	Return queryBase
}

/// Return id, dislpayName and class
/// <example>w ##class(Form.REST.Objects).queryINFOCLASS("Form.Test.Simple")</example>
ClassMethod queryINFOCLASS(class As %String) As %String
{
	Set queryBase = ..queryINFO(class) _ ", %CLASSNAME AS _class "
	Return queryBase
}

/// Get form objects by a custom query
ClassMethod getFormObjectsCustom(class As %String = "", queryType As %String) As %Status
{
	#dim sc As %Status = $$$OK
	Set sc = ##class(Form.Info).formExistsStatus(class)
	Return:$$$ISERR(sc) sc
	Set sc = ..checkObjPermission(class, "R")
	Return:$$$ISERR(sc) sc

	Set queryType = $ZCONVERT(queryType, "U")

	If ##class(%Dictionary.CompiledMethod).IDKEYExists(class, "customquery" _ queryType) {
		Set sql = $CLASSMETHOD(class, "customquery" _ queryType)
	}
  Else {
		Set sc = $$$ERROR($$$GeneralError, "Custom query type " _ queryType _ " not found")
	}

	Return:$$$ISERR(sc) sc

	Set sc = ##class(Form.JSON.SQL).WriteJSONFromSQL(sql)
	Return sc
}

}
