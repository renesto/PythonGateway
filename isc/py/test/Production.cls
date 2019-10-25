/// Sample production
Class isc.py.test.Production Extends Ens.Production
{

/// Register callout lib system-wide
ClassMethod OnStart(pTimeStarted As %String) As %Status
{
  set sc = ##class(isc.py.Callout).Setup()
  quit sc
}

XData ProductionDefinition
{
<Production Name="isc.py.test.Production" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="isc.py.ens.Operation" Category="" ClassName="isc.py.ens.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="PythonLib">libpython3.6m.so</Setting>
  </Item>
  <Item Name="od.RestFulService" Category="" ClassName="od.RestFulService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="od.DetectObjects" Category="" ClassName="od.DetectObjects" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="od.EscalatedodWorkflow" Category="" ClassName="od.EscalatedodWorkflow" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="od.NormalodWorkflow" Category="" ClassName="od.NormalodWorkflow" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Order Team" Category="" ClassName="EnsLib.Workflow.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AutoCreateRole">1</Setting>
  </Item>
  <Item Name="odRouter" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">od.odRouterRoutingRule</Setting>
  </Item>
</Production>
}

}
