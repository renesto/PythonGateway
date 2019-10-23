import pandas as pd
from collections import namedtuple
from PIL import Image, ImageColor, ImageDraw, ImageFont, ImageOps
from tqdm import tqdm
import time
from pprint import pprint
from six import BytesIO
from collections import namedtuple

import matplotlib.pyplot as plt
import numpy as np


def overlapPercentage(xa1,ya1,xa2,ya2, xb1,yb1,xb2,yb2):  # returns None if rectangles don't intersect
    Rectangle = namedtuple('Rectangle', 'xmin ymin xmax ymax')
    a = Rectangle(xa1,ya1,xa2,ya2)
    b = Rectangle(xb1,yb1,xb2,yb2)
    dx = min(a.xmax, b.xmax) - max(a.xmin, b.xmin)
    dy = min(a.ymax, b.ymax) - max(a.ymin, b.ymin)
    if (dx>=0) and (dy>=0):
        return ((dx*dy / ((xa2-xa1)*(ya2-ya1))) + (dx*dy / ((xb2-xb1)*(yb2-yb1))))/2
    else:
        return 0


def defineObjects(overlapMin=0.8, result_out=[None]):
    cut_off_scores = len(list(result_out['detection_scores']))
    overlap = [None] * cut_off_scores
    group=1
    j=0
    while j < cut_off_scores:
        k=j+1
        while k < cut_off_scores:
            x11,y11,x12,y12 = result_out['detection_boxes'][j]
            x21,y21,x22,y22 = result_out['detection_boxes'][k]
            if overlapPercentage(x11,y11,x12,y12,x21,y21,x22,y22)>overlapMin:
                if overlap[j] != None:
                    overlap[k]=overlap[j]
                elif overlap[k] != None:
                    overlap[j]=overlap[k]
                else:
                    overlap[j]=overlap[k]=group
                    group=group+1
            k=k+1
        j=j+1
    j=0
    while j < cut_off_scores:
        if overlap[j]==None:
            overlap[j]=group
            group=group+1
        j=j+1
    return overlap

def format_prediction_string(image_id, result):
    prediction_strings = []
    
    for i in range(len(result['detection_scores'])):
        class_name = result['detection_class_names'][i].decode("utf-8")
        YMin,XMin,YMax,XMax = result['detection_boxes'][i]
        score = result['detection_scores'][i]
        
        prediction_strings.append(
            f"{class_name} {score} {XMin} {YMin} {XMax} {YMax}"
        )
        
    prediction_string = " ".join(prediction_strings)

    return {
        "ImageID": image_id,
        "PredictionString": prediction_string
    }
def display_image(image):
    fig = plt.figure(figsize=(20, 15))
    plt.grid(False)
    plt.axis('off')
    plt.imshow(image)

def draw_bounding_box_on_image(image,
                               ymin,
                               xmin,
                               ymax,
                               xmax,
                               color,
                               font,
                               thickness=4,
                               display_str_list=()):
    """Adds a bounding box to an image."""
    draw = ImageDraw.Draw(image)
    im_width, im_height = image.size
    (left, right, top, bottom) = (xmin * im_width, xmax * im_width,
                                  ymin * im_height, ymax * im_height)
    draw.line([(left, top), (left, bottom), (right, bottom), (right, top),
               (left, top)],
              width=thickness,
              fill=color)

    # If the total height of the display strings added to the top of the bounding
    # box exceeds the top of the image, stack the strings below the bounding box
    # instead of above.
    display_str_heights = [font.getsize(ds)[1] for ds in display_str_list]
    # Each display_str has a top and bottom margin of 0.05x.
    total_display_str_height = (1 + 2 * 0.05) * sum(display_str_heights)

    if top > total_display_str_height:
        text_bottom = top
    else:
        text_bottom = bottom + total_display_str_height
    # Reverse list and print from bottom to top.
    for display_str in display_str_list[::-1]:
        text_width, text_height = font.getsize(display_str)
        margin = np.ceil(0.05 * text_height)
        draw.rectangle([(left, text_bottom - text_height - 2 * margin),
                        (left + text_width, text_bottom)],
                       fill=color)
        draw.text((left + margin, text_bottom - text_height - margin),
                  display_str,
                  fill="black",
                  font=font)
        text_bottom -= text_height - 2 * margin

def draw_boxes(image, boxes, class_names, scores, max_boxes=10, min_score=0.1):
    """Overlay labeled boxes on an image with formatted scores and label names."""
    colors = list(ImageColor.colormap.values())

    font = ImageFont.load_default()

    for i in range(min(boxes.shape[0], max_boxes)):
        if scores[i] >= min_score:
            ymin, xmin, ymax, xmax = tuple(boxes[i].tolist())
            display_str = "{}: {}%".format(class_names[i].decode("ascii"),
                                           int(100 * scores[i]))
            color = colors[hash(class_names[i]) % len(colors)]
            image_pil = Image.fromarray(np.uint8(image)).convert("RGB")
            draw_bounding_box_on_image(
                image_pil,
                ymin,
                xmin,
                ymax,
                xmax,
                color,
                font,
                display_str_list=[display_str])
            np.copyto(image, np.array(image_pil))
    return image

def TFtoPANDAS(result_out):
  cut_off_scores = len(list(result_out['detection_scores']))
  detect_scores = []
  detect_classes = []
  detect_ymin = []
  detect_xmin = []
  detect_ymax = []
  detect_xmax = []
  for j in range(cut_off_scores):
      detect_scores.append(result_out['detection_scores'][j])
      detect_classes.append(result_out['detection_class_entities'][j])
      ymin,xmin,ymax,xmax = result_out['detection_boxes'][j]
      detect_ymin.append(ymin)
      detect_xmin.append(xmin)
      detect_ymax.append(ymax)
      detect_xmax.append(xmax)
  return {
      'Score': detect_scores,
      'Class': detect_classes,
      'Ymin':  detect_ymin,
      'Xmin': detect_xmin,
      'Ymax': detect_ymax,
      'Xmax':  detect_xmax,
      'objectID':defineObjects(result_out=result_out)
      }