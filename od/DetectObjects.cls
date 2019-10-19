/// 
Class od.DetectObjects Extends (Ens.BusinessProcessBPL, isc.py.ens.ProcessUtils)
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' response='Ens.Response' height='2000' width='2000' >
<sequence xend='200' yend='1050' >
<call name='Import Python Libraries' target='isc.py.ens.Operation' async='1' xpos='200' ypos='250' >
<annotation><![CDATA[import os
from pprint import pprint
from six import BytesIO


import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()
import tensorflow_hub as hub
from PIL import Image, ImageColor, ImageDraw, ImageFont, ImageOps
from tqdm import tqdm

import sys
sys.path.append(r'/home/irisuser/pycode')]]></annotation>
<request type='isc.py.msg.ExecutionRequest' >
<assign property="callrequest.Code" value="process.GetAnnotation(&quot;Import Python Libraries&quot;)" action="set" />
</request>
<response type='Ens.Response' />
</call>
<sync calls='Import Python Libraries' type='all' xpos='200' ypos='350' />
<call name='Utility Functions' target='isc.py.ens.Operation' async='1' xpos='200' ypos='450' >
<annotation><![CDATA[import od_utils]]></annotation>
<request type='isc.py.msg.ExecutionRequest' >
<assign property="callrequest.Code" value="process.GetAnnotation(&quot;Utility Functions&quot;)" action="set" />
</request>
<response type='Ens.Response' />
</call>
<sync calls='Utility Functions' type='all' xpos='200' ypos='550' />
<call name='Set Image Path' target='isc.py.ens.Operation' async='1' xpos='200' ypos='650' >
<annotation><![CDATA[
test_path="/home/irisowner/samples/"
sample_image_path = test_path+"people.jpg"]]></annotation>
<request type='isc.py.msg.ExecutionRequest' >
<assign property="callrequest.Code" value="process.GetAnnotation(&quot;Set Image Path&quot;)" action="set" />
</request>
<response type='Ens.Response' />
</call>
<sync calls='Set Image Path' type='all' xpos='200' ypos='750' />
<call name='Detect Objects' target='isc.py.ens.Operation' async='1' xpos='200' ypos='850' >
<annotation><![CDATA[import od_detect
result = od_detect.detect_image(sample_image_path)]]></annotation>
<request type='isc.py.msg.ExecutionRequest' >
<assign property="callrequest.Code" value="process.GetAnnotation(&quot;Detect Objects&quot;)" action="set" />
<assign property="callrequest.Variables" value="&quot;result&quot;" action="set" />
</request>
<response type='Ens.Response' />
</call>
<sync calls='Detect Objects' type='all' xpos='200' ypos='950' />
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
