Class dc.irisrad.CreationUtility Extends %CSP.REST
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

ClassMethod GetFields(pId) As %Status
{
    Set %response.ContentType = "application/json"
    
    Set sc = $$$OK

    Set array = []

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT ID, ParentClass, FieldName, FieldType, DisplayName, IsRequired, ClassRelated FROM dc_irisrad_data.ClassLineCreation"

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

}
