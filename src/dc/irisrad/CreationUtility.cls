Class dc.irisrad.CreationUtility Extends Form.REST.Abstract
{

/// Return the list of class created using RAD Studio
ClassMethod ListClasses() As %Status
{
    Set %response.ContentType = "application/json"
    
    Set sc = $$$OK

    Set array = []

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT ID, ClassName, Description FROM dc_irisrad_data.ClassCreation"

        Set sc = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(sc)

        Set intcolumnCount = oRS.%Metadata.columnCount

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
	        While result.%Next() {
	        	Set json = { }
	        	For i=1:1:intcolumnCount {
					Do json.%Set(oRS.%Metadata.columns.GetAt(i).colName,result.%GetData(i))
				}
				Do array.%Push(json)
            }
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }
    }
    Catch (oException) {
        Set sc = oException.AsStatus()
    }

    Write array.%ToJSON() 
    
    Return sc
}

ClassMethod CheckClassName(pName) As %Status
{
   
    Set sc = $$$OK

    set array = []

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT ID FROM dc_irisrad_data.ClassCreation WHERE ClassName = '"_pName_"'"

        Set sc = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(sc)

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
            set json = {"msg":"Class already exists"}
        }
        Else {
            set json = {"msg":""}
        }
    }
    Catch (oException) {
        Set sc = oException.AsStatus()
    }
    
    write json.%ToJSON()
    Return sc
}

ClassMethod GetFields(pId) As %Status
{
    Set %response.ContentType = "application/json"
    
    Set sc = $$$OK

    Set array = []

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT ID, ParentClass, FieldName, FieldType, DisplayName, IsRequired, ClassRelated "_
        "FROM dc_irisrad_data.ClassLineCreation " 
        if (pId '="") {
            set sql= sql_"WHERE ParentClass = '"_pId_"'" 
        }

        Set sc = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(sc)

        Set intcolumnCount = oRS.%Metadata.columnCount

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
	        While result.%Next() {
	        	Set json = { }
	        	For i=1:1:intcolumnCount {
					Do json.%Set(oRS.%Metadata.columns.GetAt(i).colName,result.%GetData(i))
				}
				Do array.%Push(json)
            }
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }
    }
    Catch (oException) {
        Set sc = oException.AsStatus()
    }

    Write array.%ToJSON() 
    
    Return sc
}

// Return the list of class created using RAD Studio

ClassMethod GetClassById(pId) As %Status
{
    Set %response.ContentType = "application/json"
    
    Set sc = $$$OK

    Set array = []

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT ID, ClassName, Description FROM dc_irisrad_data.ClassCreation WHERE ID = "_pId

        Set sc = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(sc)

        Set intcolumnCount = oRS.%Metadata.columnCount

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
	        While result.%Next() {
	        	Set json = { }
	        	For i=1:1:intcolumnCount {
					Do json.%Set(oRS.%Metadata.columns.GetAt(i).colName,result.%GetData(i))
				}
				Do array.%Push(json)
            }
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }
    }
    Catch (oException) {
        Set sc = oException.AsStatus()
    }

    Write array.%ToJSON() 
    
    Return sc
}

ClassMethod UpdateField(id As %Integer) As %Status
{
    Set obj = ##class(%DynamicObject).%FromJSON(%request.Content)

    Set objClassField = ##class(dc.irisrad.data.ClassLineCreation).%OpenId(id)

    If '$IsObject(objClassField) {
        Set %response.Status = ..#HTTP404NOTFOUND
        Quit $$$OK
    }

    Set iter = obj.%GetIterator()
    While iter.%GetNext(.key , .value )  {
        Set ^zHGD($ZName,"Update",key) = value
        Set $Property(objClassField, key) = value
    }

    Set tSC = objClassField.%Save()

    If $$$ISERR(tSC) {
        Quit $System.OBJ.DisplayError(tSC)
    } else {
        set json = {"msg":"Field updated"}
    }

    write json.%ToJSON()

    Quit $$$OK
}

ClassMethod DeleteClass(id As %Integer) As %Status
{
    if '##class(dc.irisrad.data.ClassCreation).%ExistsId(id) {
        set %responde.Status = ..#HTTP404NOTFOUND
        quit $$$OK	
    }

    set objClass = ##class(dc.irisrad.data.ClassCreation).%OpenId(id)

    set sc = ##class(dc.irisrad.data.ClassCreation).%DeleteId(id)

    if $$$ISOK(sc) {
        
        set arrResponse = []
        set jsonResponse = {}

        do jsonResponse.%Set("ClassName",objClass.ClassName)
        do arrResponse.%Push(jsonResponse)
        
        write arrResponse.%ToJSON()

        try {

            set oRS = ##class(%SQL.Statement).%New()
            
            set sql = "SELECT ID FROM dc_irisrad_data.ClassLineCreation WHERE ParentClass = "_id

            set sc = oRS.%Prepare(sql)

            quit:$System.Status.IsError(sc)

            set result = oRS.%Execute()

            if (result.%SQLCODE '< 0) {
                While result.%Next() { 
                    do ..DeleteField(result.ID)
                }
            }
            Else {
                Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
            }
        }
        Catch (oException) {
            Set sc = oException.AsStatus()
        }
    }

    quit $$$OK
}

/// Delete from %Dictionary.ClassDefinition
ClassMethod DeleteDictionaryClassDefinition() As %Status
{
    Set sc = $$$OK
    
    If '##class(%Dictionary.ClassDefinition).%ExistsId(id) {
        quit sc
    }

    set sc = ##class(%Dictionary.ClassDefinition).%DeleteId(id)
    
    quit sc
}

ClassMethod DeleteField(id As %Integer) As %Status
{
    If '##class(dc.irisrad.data.ClassLineCreation).%ExistsId(id) {
        Set %responde.Status = ..#HTTP404NOTFOUND
        Quit $$$OK	
    }

    set objClassField = ##class(dc.irisrad.data.ClassLineCreation).%OpenId(id)
    do ##class(dc.irisrad.data.ClassLineCreation).%DeleteId(id)

    set arrResponse = []
    set jsonResponse = {}

    do jsonResponse.%Set("FieldName",objClassField.FieldName)
    do arrResponse.%Push(jsonResponse)
    
    write arrResponse.%ToJSON()

    Quit $$$OK
}

ClassMethod CreateField() As %Status
{
    set tSC = $$$OK

    Set obj = ##class(%DynamicAbstractObject).%FromJSON(%request.Content)

    Set objClassField = ##class(dc.irisrad.data.ClassLineCreation).%New()

    Set objClassField.ParentClass = ##class(dc.irisrad.data.ClassCreation).%OpenId(obj.ParentClass)
    Set objClassField.FieldName = $ZSTRIP(obj.FieldName,"*W")
    Set objClassField.FieldType = obj.FieldType
    Set objClassField.IsRequired = obj.IsRequired
    Set objClassField.DisplayName = obj.DisplayName
    Set objClassField.ClassRelated = obj.ClassRelated
    Set tSC = objClassField.%Save()

    if $$$ISOK(tSC) {
        set arrResponse = []
        set jsonResponse = {}

        do jsonResponse.%Set("ParentClass",obj.ParentClass)
        do jsonResponse.%Set("FieldName",obj.FieldName)
        do jsonResponse.%Set("FieldType",obj.FieldType)
        do jsonResponse.%Set("IsRequired",obj.IsRequired)
        do jsonResponse.%Set("DisplayName",obj.DisplayName)
        do jsonResponse.%Set("ClassRelated",obj.ClassRelated)
        do arrResponse.%Push(jsonResponse)

        write arrResponse.%ToJSON()
    }

    Quit tSC
}

ClassMethod CreateClass() As %Status
{
    set tSC = $$$OK
    
    Set obj = ##class(%DynamicAbstractObject).%FromJSON(%request.Content)

    Set objClass = ##class(dc.irisrad.data.ClassCreation).%New()

    Set objClass.ClassName = $ZSTRIP(obj.ClassName,"*W")
    Set objClass.Description = obj.Description
    
    set tSC = objClass.%Save()

    if $$$ISOK(tSC) {
        set arrResponse = []
        set jsonResponse = {}

        do jsonResponse.%Set("ID",$number(objClass.%Id()))
        do jsonResponse.%Set("ClassName",objClass.ClassName)
        do jsonResponse.%Set("Description",objClass.Description)
        do arrResponse.%Push(jsonResponse)
        
        write arrResponse.%ToJSON()
    }

    Quit tSC
}

/// Compile class to generate a RESTForms2 model
ClassMethod CompileClass(pId) As %Status
{
   
    ;Set %response.ContentType = "application/json"
    
    Set sc = $$$OK

    &sql(SELECT ClassName, Description INTO :tClassName, :tDescription FROM dc_irisrad_data.ClassCreation WHERE ID = :pId)

    if (SQLCODE=0) {
        
        set jsonClass = { }
        do jsonClass.%Set("name",tClassName)
        do jsonClass.%Set("displayFormName",tDescription)
        
        // Getting fields details
        Set arrayFields = []
        Try {
            Set oRS = ##class(%SQL.Statement).%New()
            
            Set sql = "SELECT ID, ClassRelated, DisplayName, FieldName, FieldType, IsRequired, ClassRelated "_
                      "FROM dc_irisrad_data.ClassLineCreation WHERE ParentClass = "_pId
            
            Set sc = oRS.%Prepare(sql)
            quit:$System.Status.IsError(sc)
            Set result = oRS.%Execute()
            set count = 0
            
            If (result.%SQLCODE '< 0) {
                While result.%Next() {
                    Set jsonFields = {}
                    if (count=0){
                        set count=$increment(count)
                        do jsonClass.%Set("displayProperty",result.FieldName)
                    }
                    do jsonFields.%Set("name",result.FieldName)
                    do jsonFields.%Set("displayName",result.DisplayName)
                    if (result.ClassRelated = ""){
                        do jsonFields.%Set("type",result.FieldType)
                    } else {
                        do jsonFields.%Set("type",result.ClassRelated)
                        do jsonFields.%Set("jsonInclude","INOUT")
                        do jsonFields.%Set("jsonReference","ID")
                    }
                    if (result.IsRequired = 1) {
                        set tIsRequired = "true"
                    } else {
                        set tIsRequired = "false"
                    }
                    do jsonFields.%Set("required",tIsRequired,"boolean")
                    do arrayFields.%Push(jsonFields)
                }
            }
            Else {
                Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
            }
        }
        Catch (oException) {
            Set sc = oException.AsStatus()
        }

        do jsonClass.%Set("fields",arrayFields)
        set sc = ..CreateForm(jsonClass.%ToJSON())
        if $$$ISOK(sc) {
            set json = {"msg":"Class has been compiled successfully"}
            write json.%ToJSON()
        }
    }
    
    Return sc
}

/// Create the Form 
ClassMethod CreateForm(pObject As %Library.DynamicObject) As %Status
{
    Set sc = $$$OK
   
    Try {
        Set body = {}.%FromJSON(pObject)
        Set form = ##class(dc.irisrad.Form).%New()
        Set form.Name = body.name
        Set form.DisplayFormName = body.displayFormName
        Set form.DisplayField = body.displayProperty
        Set form.Fields = body.fields
        $$$TOE(sc, form.Save())
    }
    Catch ex {
        Set sc = ex.AsStatus()
    }

    Return sc
}

/// Get Classes that extends from dc.irisrad.FormAdaptor    
ClassMethod RelatedClassList() As %Status
{
    Set sc = $$$OK

    set array = []

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT ID, Name FROM %Dictionary.ClassDefinition WHERE  Super [ 'dc.irisrad.FormAdaptor'"

        Set sc = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(sc)

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
            While result.%Next() {
	        	Set json = { }
	        	do json.%Set("id",result.ID)
	        	do json.%Set("name",result.Name)
				Do array.%Push(json)
            }
        }
    }
    Catch (oException) {
        Set sc = oException.AsStatus()
    }
    
    write array.%ToJSON()
    
    Return sc
}

}
