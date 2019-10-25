Class od.CustomFunctionSet Extends Ens.Rule.FunctionSet
{

/// Evaluate a odRequest, it is used within an Ensemble Business Process
/// w ##class(od.CustomFunctionSet).CalculateShelfStatus("BANANA")
ClassMethod CalculateShelfStatus(pItem As %String = "", Output pStatus As %Status) As %String
{
	#Dim tSC as %Status=$$$OK
	#Dim ex as %Exception.AbstractException
	Try {
		  q:pItem=""
		  #dim tItem As %Integer = 0
		  SET myquery = "SELECT COUNT(*) As cnt FROM od.Objects Where Class=? AND Timestamp = (Select MAX(Timestamp) from od.Objects) group by Class"
		  SET tStatement = ##class(%SQL.Statement).%New()
		  SET qStatus = tStatement.%Prepare(myquery)
		  IF qStatus'=1 { WRITE "%Prepare failed:" DO $System.Status.DisplayError(qStatus) QUIT }
		  SET rset = tStatement.%Execute(pItem)
		  WHILE rset.%Next() { 
		  	set tItem = rset.cnt
		  }

	} Catch ex {
		Set tSC=ex.AsStatus()
	}	
		
	Set ^zDebug($I(^tCounter)) = tItem
	Set pStatus=tSC
	Quit tItem
}





}