#!/bin/bash

if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
    echo "Usage: $0 <image> <resize_percent> <rotation> <num_of_frames> [output_gif]"
    exit 1
fi

IMAGE=$1
RESIZE_P=$2
ROTATION=$3
FRAMES=$4
OUTPUT=$5

if [ ! -f "$IMAGE" ]; then
    echo "Error: File $IMAGE does not exist."
    exit 1
fi

if [ -z "$OUTPUT" ]; then
    BASENAME=$(basename "$IMAGE" | cut -f 1 -d '.')
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    OUTPUT="${BASENAME}_${TIMESTAMP}.gif"
fi

check_imagemagick() {
    if ! command -v convert &> /dev/null; then
        echo "Installing ImageMagick in a virtual environment..."
        
        if [ ! -d "./venv" ]; then
            python3 -m venv venv
        fi
        
        source venv/bin/activate
        
        sudo apt-get update
        sudo apt-get install imagemagick -y
        
        if ! command -v convert &> /dev/null; then
            echo "Error: ImageMagick could not be installed."
            deactivate
            exit 1
        fi

    fi
}

check_imagemagick

DIR="Outputs/Q3"
mkdir -p $DIR

for ((i=0; i<$FRAMES; i++)); do
    ANGLE=$((i * ROTATION))
    convert "$IMAGE" -resize "${RESIZE_P}%" -rotate "$ANGLE" "$DIR/frame_$i.png"
done

convert -delay 10 -loop 0 "$DIR/frame_*.png" "$DIR/$OUTPUT"

rm $DIR/frame_*.png
echo "GIF created successfully: $OUTPUT"
