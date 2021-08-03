#!/usr/bin/env python

import warnings

warnings.simplefilter("ignore", FutureWarning)

from pathlib import Path
import sys

import h5py
import tensorflow as tf

from nets import nets_factory
from preprocessing import preprocessing_factory

slim = tf.contrib.slim

tf.app.flags.DEFINE_integer("num_classes", 5, "The number of classes.")
tf.app.flags.DEFINE_string("bot_out", None, "Output file for bottleneck features.")
tf.app.flags.DEFINE_string(
    "model_name", "inception_v4", "The name of the architecture to evaluate."
)
tf.app.flags.DEFINE_string(
    "checkpoint_path", None, "The directory where the model was written to."
)
tf.app.flags.DEFINE_integer("eval_image_size", 299, "Eval image size.")
tf.app.flags.DEFINE_string("filedir", None, "")

FLAGS = tf.app.flags.FLAGS


def main(_):
    model_name_to_variables = {
        "inception_v3": "InceptionV3",
        "inception_v4": "InceptionV4",
    }
    model_name_to_bottleneck_tensor_name = {
        "inception_v4": "InceptionV4/Logits/AvgPool_1a/AvgPool:0",
        "inception_v3": "InceptionV3/Logits/AvgPool_1a_8x8/AvgPool:0",
    }
    bottleneck_tensor_name = model_name_to_bottleneck_tensor_name.get(FLAGS.model_name)
    preprocessing_name = FLAGS.model_name
    eval_image_size = FLAGS.eval_image_size
    model_variables = model_name_to_variables.get(FLAGS.model_name)
    if model_variables is None:
        tf.logging.error("Unknown model_name provided `%s`." % FLAGS.model_name)
        sys.exit(-1)

    if tf.gfile.IsDirectory(FLAGS.checkpoint_path):
        checkpoint_path = tf.train.latest_checkpoint(FLAGS.checkpoint_path)
    else:
        checkpoint_path = FLAGS.checkpoint_path
    image_string = tf.placeholder(tf.string)
    image = tf.image.decode_jpeg(
        image_string, channels=3, try_recover_truncated=True, acceptable_fraction=0.3
    )
    image_preprocessing_fn = preprocessing_factory.get_preprocessing(
        preprocessing_name, is_training=False
    )
    network_fn = nets_factory.get_network_fn(
        FLAGS.model_name, FLAGS.num_classes, is_training=False
    )
    processed_image = image_preprocessing_fn(image, eval_image_size, eval_image_size)
    processed_images = tf.expand_dims(processed_image, 0)

    logits, _ = network_fn(processed_images)
    probabilities = tf.nn.softmax(logits)
    init_fn = slim.assign_from_checkpoint_fn(
        checkpoint_path, slim.get_model_variables(model_variables)
    )

    with tf.Session() as sess:
        init_fn(sess)
        with h5py.File(FLAGS.bot_out, "w") as h5:
            file_list = list(Path(FLAGS.filedir).glob("*.jpg"))
            for file in file_list:
                print(file)
                with file.open("rb") as f:
                    input_str = f.read().strip()
                preds = sess.run(
                    probabilities,
                    feed_dict={image_string: input_str},
                )
                bottleneck_values = sess.run(
                    bottleneck_tensor_name,
                    {image_string: input_str},
                )

                h5.create_dataset(
                    "/bottle/{}".format(file.name),
                    data=bottleneck_values.squeeze(),
                    compression="gzip",
                )
                h5.create_dataset(
                    "/preds/{}".format(file.name),
                    data=preds.squeeze(),
                    compression="gzip",
                )

            h5.create_dataset(
                "/filenames", data=[s.name.encode("ascii") for s in file_list]
            )


if __name__ == "__main__":
    tf.app.run()
