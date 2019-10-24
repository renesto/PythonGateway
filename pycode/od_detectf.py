import os
import pickle
from time import sleep

def detect_image(path):
  sleep(10)
  filename, file_extension = os.path.splitext(path)
  with open(filename+'.pickle', 'rb') as f:
    result_out = pickle.load(f)
  with open(filename+'.pickli', 'rb') as f:
    image_out = pickle.load(f)
  return {'result':result_out, 'image':image_out}

