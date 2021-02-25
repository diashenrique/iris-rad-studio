Class dc.irisrad.Form Extends %RegisteredObject
{

Property Form As %Persistent;

Property Name As %String [ Required ];

Property DisplayField As %String [ Required ];

Property Fields As %DynamicArray [ Required ];

Method Save() As %Status
{
  Set sc = $$$OK
  Try {
    // form config validation
    $$$TOE(sc, ..%ValidateObject())

    // form creation
    Set ..Form = ..CreateFormClass()
    
    // form parameters
    Do ..SetParameters([{
      "name": "FORMNAME",
      "value": "FormTest"
    },{
      "name": "OBJPERMISSIONS",
      "value": "CRUD"
    },{
      "name": "DISPLAYPROPERTY",
      "value": (..DisplayField)
    }])

    // form persistencing
    $$$TOE(sc, ..Form.%Save())
    
    // form fields persistencing
    Set propIter = ..Fields.%GetIterator()
    While (propIter.%GetNext(.propIdx, .propDef)) {
      Set class = ..Name
      Set name = propDef.name
      Set type = propDef.type
      Set collection = ..GetProperty(propDef, "collection", "")
      Set displayName = ..GetProperty(propDef, "displayName", "")
      Set required = ..GetProperty(propDef, "required", 0)
      Set jsonInclude = ..GetProperty(propDef, "jsonInclude", "INOUT")
      Set jsonReference = ..GetProperty(propDef, "jsonReference", "ID")
      $$$TOE(sc, ##class(Form.Property).addClassProperty(class, name, type, collection, displayName, required, jsonInclude, jsonReference))
    }

    // form compiling
    $$$TOE(sc, $SYSTEM.OBJ.Compile(..Name, "-d"))
  }
  Catch ex {
    Set sc = ex.AsStatus()
  }
  Return sc
}

Method GetProperty(pDynObj As %DynamicObject, pPropName As %String, pDefault = "")
{
  If (pDynObj.%IsDefined(pPropName)) {
    Return pDynObj.%Get(pPropName)
  }
  Return pDefault
}

Method CreateFormClass() As %Persistent
{
  Set className = ..Name
  Set classObj = ##class(%Dictionary.ClassDefinition).%OpenId(className)
  If ('$ISOBJECT(classObj)) {
    Set classObj = ##class(%Dictionary.ClassDefinition).%New()
  }
  Set classObj.Name = className
  Set classObj.Super = "%Persistent, dc.irisrad.FormAdaptor"
  Return classObj
}

Method SetParameters(pParametersDef As %DynamicArray)
{
  Set it = pParametersDef.%GetIterator()
  While(it.%GetNext(.idx, .parameterDef)) {
    Do ..SetParameter(parameterDef)
  }
}

Method SetParameter(pParameterDef As %DynamicObject)
{
  Set parameterName = pParameterDef.name
  Set paramObj = ##class(%Dictionary.ParameterDefinition).%New()
  Set paramObj.Name = parameterName
  Set paramObj.parent = ..Form
  Set paramObj.Default = pParameterDef.value
}

/// Get form metainformation by name
/// Overrided due UI customizations features
ClassMethod GetFormInfo(form As %String = "") As %Status
{
	Set metadata = ##class(Form.Info).getFormMetadata(form)

	Set toolbarUIDef = $PARAMETER(form, "ToolbarUIDef")
  If (toolbarUIDef '= "") {
    Set metadata.toolbarUIDef = ..GetXDataContent(toolbarUIDef)
  }

	Set customUIDef = $PARAMETER(form, "CustomUIDef")
  If (customUIDef '= "") {
    Set metadata.customUIDef = ..GetXDataContent(customUIDef)
  }
	
  Write metadata.%ToJSON()
	Return $$$OK
}

ClassMethod GetFormQueryInfo(form As %String, query As %String) As %Status
{
  Set sc = $$$OK
  Do $CLASSMETHOD(form, "GetQueryInfo", query)
  Return sc
}

ClassMethod GetXDataContent(pXDataID As %String)
{
  Set compiledXdata = ##class(%Dictionary.CompiledXData).%OpenId(pXDataID)
  Set tStream = compiledXdata.Data
  Do ##class(%XML.TextReader).ParseStream(tStream,.textreader)
  While textreader.Read() {
    If (textreader.NodeType="chars") {
      Set value = textreader.Value
      Return value //{}.%FromJSON(value)
    }
  }
}

Method CreateDefaulQuery()
{
  // todo:
  /*
  Quit "SELECT name, spouse->name spouse, "_
    "(SELECT LIST(name) FROM Form_Test.Person WHERE ID %INLIST dc_irisrad.Form_FlattenList(User_forms_TestForm1.children)) children "_
    "FROM User_forms.TestForm User_forms_TestForm1"
  */
  /*
	set tMethod = ##class(%Dictionary.MethodDefinition).%New()
	set tMethod.parent = pClass
	set tMethod.Name = "Import"
	set pSequence = pSequence + 1
	set tMethod.SequenceNumber = pSequence
	set tMethod.ClassMethod = 1
	set tMethod.ReturnType = "%Library.Integer"
	set tMethod.FormalSpec = "pSelectMode:%Library.Integer=$zu(115,5),pFileName:%Library.String(MAXLEN=""""),pDelimiter:%String="","",pQuote:%String="""""""",pHeaders:%Integer=0,&pRecordCount:%Integer"
	set tMethod.SqlProc = 1
	do tMethod.Implementation.WriteLine($Char(9)_"set tStatementId = $SYSTEM.Util.CreateGUID(), tCounter = 0, pRecordCount = 0")
	do tMethod.Implementation.WriteLine($Char(9)_"set tPreparedStatement = ##class(%SQL.DynamicStatement).Prepare(tStatementId,..#ROWTYPE,pDelimiter,pQuote,,,0,""CSV"")")
	do tMethod.Implementation.WriteLine($Char(9)_"if $Isobject(tPreparedStatement) {")
  */
}

/// TODO: move to a util class
ClassMethod FlattenList(pList As %List) As %List [ SqlProc ]
{
  Set result = ""
  Set len = $LISTLENGTH(pList)
  For i=1:1:len {
    Set $LIST(result, * + 1) = $LISTTOSTRING($LISTGET(pList, i))
  }
  Return result
}

}
