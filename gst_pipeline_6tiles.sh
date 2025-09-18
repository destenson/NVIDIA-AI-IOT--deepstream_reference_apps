#!/bin/bash

# GStreamer pipeline for processing 1920x1080 MP4 with 6x640x640 tiles
# This pipeline uses NVIDIA DeepStream elements for inference

INPUT_FILE="input.mp4"
OUTPUT_FILE="output_with_detections.mp4"
MODEL_CONFIG="config_infer_primary.txt"  # Path to your nvinfer config file

gst-launch-1.0 -e \
filesrc location=$INPUT_FILE ! \
qtdemux ! h264parse ! nvv4l2decoder ! \
nvvideoconvert ! "video/x-raw(memory:NVMM), width=1920, height=1080, format=NV12" ! \
tee name=t \
\
t. ! queue ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
videocrop left=0 top=0 right=1280 bottom=440 ! \
nvvideoconvert ! "video/x-raw(memory:NVMM), width=640, height=640" ! \
nvinfer config-file-path=$MODEL_CONFIG ! \
nvdsosd ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
queue name=tile1 \
\
t. ! queue ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
videocrop left=640 top=0 right=640 bottom=440 ! \
nvvideoconvert ! "video/x-raw(memory:NVMM), width=640, height=640" ! \
nvinfer config-file-path=$MODEL_CONFIG ! \
nvdsosd ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
queue name=tile2 \
\
t. ! queue ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
videocrop left=1280 top=0 right=0 bottom=440 ! \
nvvideoconvert ! "video/x-raw(memory:NVMM), width=640, height=640" ! \
nvinfer config-file-path=$MODEL_CONFIG ! \
nvdsosd ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
queue name=tile3 \
\
t. ! queue ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
videocrop left=0 top=440 right=1280 bottom=0 ! \
nvvideoconvert ! "video/x-raw(memory:NVMM), width=640, height=640" ! \
nvinfer config-file-path=$MODEL_CONFIG ! \
nvdsosd ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
queue name=tile4 \
\
t. ! queue ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
videocrop left=640 top=440 right=640 bottom=0 ! \
nvvideoconvert ! "video/x-raw(memory:NVMM), width=640, height=640" ! \
nvinfer config-file-path=$MODEL_CONFIG ! \
nvdsosd ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
queue name=tile5 \
\
t. ! queue ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
videocrop left=1280 top=440 right=0 bottom=0 ! \
nvvideoconvert ! "video/x-raw(memory:NVMM), width=640, height=640" ! \
nvinfer config-file-path=$MODEL_CONFIG ! \
nvdsosd ! \
nvvideoconvert ! "video/x-raw(memory:NVMM)" ! \
queue name=tile6 \
\
nvcompositor name=comp \
sink_0::xpos=0 sink_0::ypos=0 sink_0::width=640 sink_0::height=640 \
sink_1::xpos=640 sink_1::ypos=0 sink_1::width=640 sink_1::height=640 \
sink_2::xpos=1280 sink_2::ypos=0 sink_2::width=640 sink_2::height=640 \
sink_3::xpos=0 sink_3::ypos=640 sink_3::width=640 sink_3::height=640 \
sink_4::xpos=640 sink_4::ypos=640 sink_4::width=640 sink_4::height=640 \
sink_5::xpos=1280 sink_5::ypos=640 sink_5::width=640 sink_5::height=640 \
width=1920 height=1280 ! \
nvvideoconvert ! "video/x-raw(memory:NVMM), format=NV12" ! \
nvv4l2h264enc ! h264parse ! \
qtmux ! filesink location=$OUTPUT_FILE \
\
tile1. ! comp.sink_0 \
tile2. ! comp.sink_1 \
tile3. ! comp.sink_2 \
tile4. ! comp.sink_3 \
tile5. ! comp.sink_4 \
tile6. ! comp.sink_5