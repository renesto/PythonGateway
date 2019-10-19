Class od.RestServer Extends %CSP.REST
{
Parameter HandleCorsRequest = 1;
Parameter CHARSET = "utf-8";

Parameter CONTENTTYPE = "application/json";


XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
    <Routes>
      <Route Url="/sendImage/:ind" Method="GET" Call="sendImage"/>
   </Routes> 
}

ClassMethod sendImage(id As %String) As %Status
{
 set tRet = {"status":"ok"}
 set tSC = $$$OK
 try {
 		//Instantiate Business Service
 		set tSC = ##class(Ens.Director).CreateBusinessService("od.RestFulService",.tService)
 		$$$ThrowOnError(tSC)
 		//Pass along input from url to ProcessInput
 		set request = ##class(od.msg.ImageODRequest).%New()
 		set request.Filename="Fruitshelf"_id_".jpg"
 		set request.Filepath="/usr/irissys/csp/python/shelf_images"
 		set tSC = tService.ProcessInput(request,.output)
 	 	$$$ThrowOnError(tSC)
 	 	set %response.Status = ..#HTTP200OK
 	}
 	Catch ex {
 		set tSC=ex.AsStatus()
 		set tRet = {"status":"exception thrown", "details":"not implemented"}
 		set %response.Status = ..#HTTP500INTERNALSERVERERROR
 	}
 	write tRet.%ToJSON()

  Quit $$$OK
}

}