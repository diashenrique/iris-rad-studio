/// Country
Class diashenrique.data.Task Extends (%Persistent, %JSON.Adaptor)
{

Property text As %String;

Property completed As %Boolean;

Property important As %Boolean;

Property taskDate As %Date;

ClassMethod reset()
{
    Do ##class(diashenrique.data.Task).%DeleteExtent()
    Set tasks = [
        {"text": "Make dinner reservations", "important": 0, "completed": 0},
        {"text": "Get coffee", "important": 1, "completed": 0},
        {"text": "Book a hotel for my trip", "important": 0, "completed": 0},
        {"text": "Upgrade Caché", "important": 0, "completed": 0},
        {"text": "Update OS X", "important": 0, "completed": 1},
        {"text": "Buy a new camera lens", "important": 1, "completed": 1}
    ]
    
    Set iter = tasks.%GetIterator()
    While iter.%GetNext(,.obj) {
        Set task = ##class(diashenrique.data.Task).%New()
        Set task.text = obj.text
        Set task.important = obj.important
        Set task.completed = obj.completed
        Do task.%Save()
    }
}

Storage Default
{
<Data name="TaskDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>text</Value>
</Value>
<Value name="3">
<Value>completed</Value>
</Value>
<Value name="4">
<Value>important</Value>
</Value>
<Value name="5">
<Value>taskDate</Value>
</Value>
</Data>
<DataLocation>^diashenrique.data.TaskD</DataLocation>
<DefaultData>TaskDefaultData</DefaultData>
<IdLocation>^diashenrique.data.TaskD</IdLocation>
<IndexLocation>^diashenrique.data.TaskI</IndexLocation>
<StreamLocation>^diashenrique.data.TaskS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
