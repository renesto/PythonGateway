import os
from pprint import pprint
from six import BytesIO

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import tensorflow.compat.v1 as tf
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2' 
tf.disable_v2_behavior()
tf.get_logger().setLevel('WARNING')
tf.autograph.set_verbosity(2)

import tensorflow_hub as hub
from PIL import Image, ImageColor, ImageDraw, ImageFont, ImageOps
from tqdm import tqdm

import sys
sys.path.append(r'/home/irisuser/pycode')

import od_utils

test_path="/home/irisowner/samples/"
sample_image_path = test_path+"FruitShelf.jpg"

import od_detect
result = od_detect.detect_image(sample_image_path)