
import ssl
import tensorflow.compat.v1 as tf

tf.disable_v2_behavior()

import tensorflow_hub as hub

ssl._create_default_https_context = ssl._create_unverified_context

def detect_image(path):
    with tf.Graph().as_default():
        # Create our inference graph
        image_string_placeholder = tf.placeholder(tf.string)
        decoded_image = tf.image.decode_jpeg(image_string_placeholder)
        decoded_image_float = tf.image.convert_image_dtype(
            image=decoded_image, dtype=tf.float32
        )
        # Expanding image from (height, width, 3) to (1, height, width, 3)
        image_tensor = tf.expand_dims(decoded_image_float, 0)
        
        # Load the model from tfhub.dev, and create a detector_output tensor
        model_url = "/home/irisuser/models"
        detector = hub.Module(model_url)
        detector_output = detector(image_tensor, as_dict=True)
        
        # Initialize the Session
        init_ops = [tf.global_variables_initializer(), tf.tables_initializer()]
        sess = tf.Session()
        sess.run(init_ops)
        
        # Load our sample image into a binary string
        with tf.gfile.Open(path, "rb") as binfile:
            image_string = binfile.read()
        
        # Run the graph we just created
        result_out, image_out = sess.run(
            [detector_output, decoded_image],
            feed_dict={image_string_placeholder: image_string}
        )
    return {'result':result_out, 'image':image_out}

