Class od.Objects Extends %Persistent
{
Property Score As %Double;

Property Class As %String;

Property Ymin As %Double;

Property Xmin As %Double;

Property Ymax As %Double;

Property Xmax As %Double;

Property objectID As %Integer;

Property Timestamp As %Library.TimeStamp;

Storage Default
{
<Data name="ObjectsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Score</Value>
</Value>
<Value name="3">
<Value>Class</Value>
</Value>
<Value name="4">
<Value>Ymin</Value>
</Value>
<Value name="5">
<Value>Xmin</Value>
</Value>
<Value name="6">
<Value>Ymax</Value>
</Value>
<Value name="7">
<Value>Xmax</Value>
</Value>
<Value name="8">
<Value>objectID</Value>
</Value>
<Value name="9">
<Value>Timestamp</Value>
</Value>
</Data>
<DataLocation>^od.ObjectsD</DataLocation>
<DefaultData>ObjectsDefaultData</DefaultData>
<IdLocation>^od.ObjectsD</IdLocation>
<IndexLocation>^od.ObjectsI</IndexLocation>
<StreamLocation>^od.ObjectsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}