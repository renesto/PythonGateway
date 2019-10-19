Class od.RestFulService extends Ens.BusinessService {

Parameter ADAPTER = "EnsLib.HTTP.InboundAdapter";

Method OnProcessInput(pInput As od.msg.ImageODRequest, Output pOutput As od.msg.ImageODResponse) As %Status
{
	Set tSC=$$$OK
	Try {
		set tSC=..SendRequestAsync("od.DetectObjects",.pInput,"")
		$$$ThrowOnError(tSC) 

	}
	Catch ex{
		set tSC=ex.AsStatus()
	}
	return tSC 
}


}