Class diashenrique.REST.Routes.Task Extends %CSP.REST
{

ClassMethod TodoList() As %Status
{
    Set %response.ContentType = "application/json"

    Set tSC = $System.Status.OK()
    Set arrayTask = []
    Set dynamicTask = { }

    Try {

        Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT ID, text, completed, important, %EXTERNAL(taskDate) As taskDate FROM diashenrique_data.Task"

        Set tSC = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(tSC)

        Set intcolumnCount = oRS.%Metadata.columnCount

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
            While result.%Next() {
                Set json = { }
                
                Do json.%Set("id", result.ID)
                Do json.%Set("taskName", result.text)
                Do json.%Set("taskDate", result.taskDate)
                Do json.%Set("important", result.important)
                Do json.%Set("completed", result.completed)
                Do arrayTask.%Push(json)
            }
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }


    }
    Catch (oException) {
        Set tSC = oException.AsStatus()
    }

    Do dynamicTask.%Set("data",arrayTask)

    Write dynamicTask.%ToJSON() 

    Quit tSC
}

}
