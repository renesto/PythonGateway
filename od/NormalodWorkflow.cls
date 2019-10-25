/// 
Class od.NormalodWorkflow Extends Ens.BusinessProcessBPL
{

Storage Default
{
<Type>%Storage.Persistent</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='od.msg.odRouterRequest' response='Ens.Response' height='2000' width='2000' >
<context>
<property name='ActionFromWorkflow' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='Resolved' type='%Boolean' initialexpression='0' instantiate='0' />
</context>
<sequence xend='200' yend='350' >
<while name='while' condition='context.Resolved=0' xpos='200' ypos='250' xend='200' yend='800' >
<annotation>Notify the od Respondant</annotation>
<call name='Notify Respondant' target='Order Team' async='1' xpos='200' ypos='250' >
<annotation><![CDATA[Send the problem report to the od respondant.]]></annotation>
<request type='EnsLib.Workflow.TaskRequest' >
<assign property="callrequest.%Actions" value="&quot;Submit Feedback,Buy New Fruits&quot;" action="set" />
<assign property="callrequest.%Subject" value="&quot;New od Has Arrived&quot;" action="set" />
<assign property="callrequest.%Message" value="&quot;&quot;" action="set" />
<assign property="callrequest.%FormFields" value="&quot;Assessment,Plan,Comments&quot;" action="set" />
<assign property="callrequest.%UserName" value="&quot;SuperUser&quot;" action="set" />
<assign property="callrequest.%FormTemplate" value="&quot;WorkFlowForm.csp&quot;" action="set" />
<assign property="callrequest.%FormValues" value="request.Apples" action="set" key="&quot;Apples&quot;" />
<assign property="callrequest.%FormValues" value="request.Oranges" action="set" key="&quot;Oranges&quot;" />
<assign property="callrequest.%FormValues" value="request.Bananas" action="set" key="&quot;Bananas&quot;" />
</request>
<response type='EnsLib.Workflow.TaskResponse' >
<assign property="context.ActionFromWorkflow" value="callresponse.%Action" action="set" />
</response>
</call>
<sync name='Wait for od Responder' calls='Notify Respondant' type='all' xpos='200' ypos='350' />
<if name='Reviewed?' condition='context.ActionFromWorkflow="Submit Feedback"' xpos='200' ypos='450' xend='200' yend='700' >
<annotation><![CDATA[Respondant has processed the od.  Make decision based on button the respodent clicked.]]></annotation>
<true>
<assign name="Logic For Button One" property="context.Resolved" value="1" action="set" xpos='470' ypos='600' />
</true>
<false>
<assign name="Logic For Button Two" property="context.Resolved" value="1" action="set" xpos='200' ypos='600' />
</false>
</if>
</while>
</sequence>
</process>
}

}
