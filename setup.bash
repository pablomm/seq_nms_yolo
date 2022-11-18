#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
LIBDARKNET_PATH="$SCRIPT_DIR/libdarknet.so"

echo $LIBDARKNET_PATH

if [[ $1 == "test" ]] ; then
    echo "Test setup"

    conda activate seq_nms

    set -x  

    # Download example video input.mp4
    cd video
    wget 'https://www.pexels.com/video/5538137/download/?fps=25.0&h=240&w=426' -O input.mp4


    # Extract individual frames
    python video2img.py -i input.mp4
    python get_pkllist.py

    # Run yolo-seqnms algorithm
    cd .. # Return to the project root folder

    # Include LD paths
    export PATH=/usr/local/cuda-10.1/bin${PATH:+:${PATH}}
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.1/lib64
    export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/cuda-10.1/lib64:$LIBDARKET_PATH

    python yolo_seqnms.py

    # Generate video
    cd video
    python img2video.py -i output

    # Return to project folder
    cd ..

    set +x  

    echo Example video saved at video/output.mp4

else

echo "Environment setup"

set -x  

# Create conda environemnt
conda env create -f seq_nms.yml

# Activate environment
conda activate seq_nms

# Install pip requirements
pip install -r requirements.txt

# Explort paths
export PATH=/usr/local/cuda-10.1/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.1/lib64
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/cuda-10.1/lib64

# Compile
make


# Download weights
wget https://pjreddie.com/media/files/yolo.weights
wget https://pjreddie.com/media/files/yolov2-tiny.weights


set +x  

fi

