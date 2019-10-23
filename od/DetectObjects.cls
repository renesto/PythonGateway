/// resultDF=TFtoPANDAS(result_out)
/// resultDF=resultDF.loc[resultDF.reset_index().groupby(['objectID'])['Score'].idxmax()]
/// resultDF=resultDF[resultDF['Class']!=b'Shelf']
/// 
Class od.DetectObjects Extends (Ens.BusinessProcessBPL, isc.py.ens.ProcessUtils)
{

Storage Default
{
<Type>%Storage.Persistent</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='od.msg.ImageODRequest' response='Ens.Response' height='2000' width='2000' >
<context>
<property name='ObjectsAsString' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='2500' />
</parameters>
</property>
<property name='exportableDF' type='%String' collection='array' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='' />
</parameters>
</property>
<property name='listDF' type='%String' collection='list' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='' />
</parameters>
</property>
</context>
<sequence xend='200' yend='850' >
<call name='Send Value To Python' target='isc.py.ens.Operation' async='0' timeout='3000' xpos='200' ypos='250' >
<request type='isc.py.msg.ExecutionRequest' >
<assign property="callrequest.Code" value="&quot;sample_image_path = r'&quot;_request.Filepath_&quot;/&quot;_request.Filename_&quot;'&quot;" action="set" />
<assign property="callrequest.Variables" value="&quot;sample_image_path&quot;" action="set" />
</request>
<response type='Ens.Response' />
</call>
<call name='Import Python Libraries' target='isc.py.ens.Operation' async='0' timeout='3000' xpos='200' ypos='350' >
<annotation><![CDATA[import os
from pprint import pprint
from six import BytesIO
from collections import namedtuple
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import tensorflow.compat.v1 as tf
import tensorflow_hub as hub
from PIL import Image, ImageColor, ImageDraw, ImageFont, ImageOps
from tqdm import tqdm
import time
import sys
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2' 
tf.disable_v2_behavior()
tf.get_logger().setLevel('WARNING')
tf.autograph.set_verbosity(2)
sys.path.append(r'/home/irisuser/pycode')
import od_utils
import od_detect
]]></annotation>
<request type='isc.py.msg.ExecutionRequest' >
<assign property="callrequest.Code" value="process.GetAnnotation(&quot;Import Python Libraries&quot;)" action="set" />
</request>
<response type='Ens.Response' />
</call>
<call name='Detect Objects' target='isc.py.ens.Operation' async='0' timeout='300000' xpos='200' ypos='450' >
<annotation><![CDATA[resultOut = od_detect.detect_image(sample_image_path)
result=resultOut['result']
image_out=resultOut['image']
]]></annotation>
<request type='isc.py.msg.ExecutionRequest' >
<assign property="callrequest.Code" value="process.GetAnnotation(&quot;Detect Objects&quot;)" action="set" />
<assign property="callrequest.Variables" value="&quot;result&quot;" action="set" />
</request>
<response type='Ens.Response' />
</call>
<call name='Prepare Results' target='isc.py.ens.Operation' async='0' timeout='300000' xpos='200' ypos='550' >
<annotation><![CDATA[resultDF=pd.DataFrame(od_utils.TFtoPANDAS(result))
resultDF=resultDF.loc[resultDF.reset_index().groupby(['objectID'])['Score'].idxmax()]
resultDF=resultDF[resultDF['Class']!=b'Shelf']
exportableDF=resultDF[resultDF['Score']>0.2].to_csv(index=False)]]></annotation>
<request type='isc.py.msg.ExecutionRequest' >
<assign property="callrequest.Code" value="process.GetAnnotation(&quot;Prepare Results&quot;)" action="set" />
<assign property="callrequest.Variables" value="&quot;exportableDF&quot;" action="set" />
</request>
<response type='isc.py.msg.ExecutionResponse' >
<assign property="context.ObjectsAsString" value="callresponse.Variables" action="set" />
</response>
</call>
<code xpos='200' ypos='650' disabled="true">
<![CDATA[ s ^exportableDF = context.exportableDF]]>
</code>
<call name='Annotate Image' target='isc.py.ens.Operation' async='0' timeout='300000' xpos='200' ypos='750' >
<annotation><![CDATA[image_with_boxes = od_utils.draw_boxes(np.array(image_out), resultDF[['Ymin','Xmin','Ymax','Xmax']].to_numpy(),resultDF['Class'].to_numpy(), resultDF['Score'].to_numpy(), max_boxes=100, min_score=0.2)
im = Image.fromarray(image_with_boxes)
im.save("/usr/irissys/csp/python/result.jpg")]]></annotation>
<request type='isc.py.msg.ExecutionRequest' >
<assign property="callrequest.Code" value="process.GetAnnotation(&quot;Annotate Image&quot;)" action="set" />
</request>
<response type='Ens.Response' />
</call>
</sequence>
</process>
}

}
