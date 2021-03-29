Class diashenrique.REST.Routes.Wizard Extends %CSP.REST
{

ClassMethod Upload(pInput As %Library.AbstractStream, Output pOutput As %Stream.Object) As %Status
{
	Set status =  $$$OK

	//Checa os Parametros
	If ($$$ISERR(%request.Content)) {
		Set %response.Status = "400 Bad Request"
		Set %response.Context("Mensagem") = "Falta os parametros"
		Return $$$NO
	}
	//Recupera JSON Enviado pelo cliente
	Set dados = {}.%FromJSON(%request.Content)
	//Converte JSON envido para objeto JSON
	//Set tSC = ##class(%ZEN.Auxiliary.jsonProvider).%ParseJSON(dados, "%ZEN.proxyObject", .objJSON)
	//Valida converção
	if $$$ISERR(tSC) {
		Set %response.Status = "500 Internal Server Error"
		Set %response.Context("Mensagem") = "Retorno ao gerar objeto JSON"
		Return $$$NO
	}
	
	set ^zHGD("separator") = objJSON.separator
	set ^zHGD("className") = objJSON.className
	set ^zHGD("cubeCreate") = objJSON.cubeCreate
	set ^zHGD("cubeName") = objJSON.cubeName
	set ^zHGD("sampleDashboard") = objJSON.sampleDashboard

	Set listRetorno = {}
	Set listRetorno.status 		= status
	Set listRetorno.mensagem	= mensagem
	Write listRetorno.%ToJSON()
	;
	Return $$$OK
}

ClassMethod UploadOld() As %Status
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
