/// 
Class od.odRouterRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="isc.py.test.Production">
<variable name="Bananas"></variable>
<variable name="Apples"></variable>
<variable name="Oranges"></variable>
<variable name="Mouse"></variable>
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<assign property="@Bananas" value="CalculateShelfStatus(&quot;BANANA&quot;,&quot;&quot;)"></assign>
<assign property="@Apples" value="CalculateShelfStatus(&quot;APPLE&quot;,&quot;&quot;)"></assign>
<assign property="@Oranges" value="CalculateShelfStatus(&quot;ORANGE&quot;,&quot;&quot;)"></assign>
<assign property="@Mouse" value="CalculateShelfStatus(&quot;MOUSE&quot;,&quot;&quot;)"></assign>
<rule name="" disabled="false">
<when condition="@Mouse&gt;0">
<send transform="" target="od.EscalatedodWorkflow"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<when condition="((@Bananas&lt;3)||(@Oranges&lt;3)||(@Apples&lt;3))&amp;&amp;(@Mouse=0)">
<send transform="" target="od.NormalodWorkflow"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
