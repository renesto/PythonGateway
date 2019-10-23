import os
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

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2' 
tf.disable_v2_behavior()
tf.get_logger().setLevel('WARNING')
tf.autograph.set_verbosity(2)

import sys
sys.path.append(r'/home/irisuser/pycode')
import od_utils

test_path="/home/irisuser/samples/"
sample_image_path = test_path+"FruitShelf.jpg"

import od_detect
result,image_out = od_detect.detect_image(sample_image_path)

resultDF=TFtoPANDAS(result)
resultDF=resultDF.loc[resultDF.reset_index().groupby(['objectID'])['Score'].idxmax()]
resultDF=resultDF[resultDF['Class']!=b'Shelf']

image_with_boxes = draw_boxes(
    np.array(image_out), resultDF[['Ymin','Xmin','Ymax','Xmax']].to_numpy(),
    resultDF['Class'].to_numpy(), resultDF['Score'].to_numpy(), max_boxes=100, min_score=0.2, exceptions=exceptions
)
im = Image.fromarray(image_with_boxes)
im.save("your_file.jpeg")
