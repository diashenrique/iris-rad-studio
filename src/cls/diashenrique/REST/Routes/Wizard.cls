Class diashenrique.REST.Routes.Wizard Extends %CSP.REST
{

ClassMethod Upload() As %Status
{
	#dim %request As %CSP.Request
	#dim stream As %CSP.BinaryStream
	//set stream = %request.GetMimeData("file")

	Set sc = $$$OK
	Try {
		Set body = {}.%FromJSON(%request.Content)
		set ^zHGD("separator") = body.separator
		set ^zHGD("className") = body.className
		set ^zHGD("cubeCreate") = body.cubeCreate
		set ^zHGD("cubeName") = body.cubeName
		set ^zHGD("sampleDashboard") = body.sampleDashboard
	} Catch ex {
		Set sc = ex.AsStatus()
	}
	Return sc
}

}
