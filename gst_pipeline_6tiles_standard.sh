#!/bin/bash

# Alternative pipeline using standard GStreamer elements (without DeepStream)
# This version uses compositor for combining tiles

INPUT_FILE="input.mp4"
OUTPUT_FILE="output_tiled.mp4"

gst-launch-1.0 -e \
compositor name=comp sink_0::xpos=0 sink_0::ypos=0 sink_0::width=640 sink_0::height=640 \
sink_1::xpos=640 sink_1::ypos=0 sink_1::width=640 sink_1::height=640 \
sink_2::xpos=1280 sink_2::ypos=0 sink_2::width=640 sink_2::height=640 \
sink_3::xpos=0 sink_3::ypos=640 sink_3::width=640 sink_3::height=640 \
sink_4::xpos=640 sink_4::ypos=640 sink_4::width=640 sink_4::height=640 \
sink_5::xpos=1280 sink_5::ypos=640 sink_5::width=640 sink_5::height=640 \
width=1920 height=1280 ! \
videoconvert ! x264enc ! mp4mux ! filesink location=$OUTPUT_FILE \
\
filesrc location=$INPUT_FILE ! decodebin ! videoconvert ! videoscale ! \
video/x-raw, width=1920, height=1080 ! tee name=t \
\
t. ! queue ! \
videocrop left=0 top=0 right=1280 bottom=440 ! \
videoscale ! video/x-raw, width=640, height=640 ! \
textoverlay text="Tile 1" valignment=top halignment=left ! \
comp.sink_0 \
\
t. ! queue ! \
videocrop left=640 top=0 right=640 bottom=440 ! \
videoscale ! video/x-raw, width=640, height=640 ! \
textoverlay text="Tile 2" valignment=top halignment=left ! \
comp.sink_1 \
\
t. ! queue ! \
videocrop left=1280 top=0 right=0 bottom=440 ! \
videoscale ! video/x-raw, width=640, height=640 ! \
textoverlay text="Tile 3" valignment=top halignment=left ! \
comp.sink_2 \
\
t. ! queue ! \
videocrop left=0 top=440 right=1280 bottom=0 ! \
videoscale ! video/x-raw, width=640, height=640 ! \
textoverlay text="Tile 4" valignment=top halignment=left ! \
comp.sink_3 \
\
t. ! queue ! \
videocrop left=640 top=440 right=640 bottom=0 ! \
videoscale ! video/x-raw, width=640, height=640 ! \
textoverlay text="Tile 5" valignment=top halignment=left ! \
comp.sink_4 \
\
t. ! queue ! \
videocrop left=1280 top=440 right=0 bottom=0 ! \
videoscale ! video/x-raw, width=640, height=640 ! \
textoverlay text="Tile 6" valignment=top halignment=left ! \
comp.sink_5
