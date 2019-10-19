Class od.msg.ImageODRequest Extends Ens.Request
{
	Property Filename As %String;
	Property Filepath As %String;
	
Storage Default
{
<Data name="ImageODRequestDefaultData">
<Subscript>"ImageODRequest"</Subscript>
<Value name="1">
<Value>Method</Value>
</Value>
<Value name="2">
<Value>URL</Value>
</Value>
<Value name="3">
<Value>Filename</Value>
</Value>
<Value name="4">
<Value>Filepath</Value>
</Value>
</Data>
<DefaultData>ImageODRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}