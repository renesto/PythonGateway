Class od.ObjectsList Extends (%Persistent,%JSON.Adaptor)
{
	Property objects As List of od.Objects;
	
Storage Default
{
<Data name="ObjectsListDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>objects</Value>
</Value>
<Value name="3">
<Value>Timestamp</Value>
</Value>
</Data>
<DataLocation>^od.ObjectsListD</DataLocation>
<DefaultData>ObjectsListDefaultData</DefaultData>
<IdLocation>^od.ObjectsListD</IdLocation>
<IndexLocation>^od.ObjectsListI</IndexLocation>
<StreamLocation>^od.ObjectsListS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}