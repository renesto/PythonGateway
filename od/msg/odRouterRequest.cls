Class od.msg.odRouterRequest Extends Ens.Request
{

Property Apples As %Integer;
Property Bananas As %Integer;
Property Oranges As %Integer;
Property Other As %String;



Storage Default
{
<Data name="odRouterRequestDefaultData">
<Subscript>"odRouterRequest"</Subscript>
<Value name="1">
<Value>Apples</Value>
</Value>
<Value name="2">
<Value>Bananas</Value>
</Value>
<Value name="3">
<Value>Oranges</Value>
</Value>
<Value name="4">
<Value>Other</Value>
</Value>
</Data>
<DefaultData>odRouterRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
