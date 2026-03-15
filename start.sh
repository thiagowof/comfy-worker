#!/bin/bash
echo "Starting ComfyUI server..."
cd /comfyui
python3 main.py --listen 0.0.0.0 --port 8188 --disable-auto-launch &

echo "Waiting for ComfyUI to be ready..."
while ! curl -s http://127.0.0.1:8188/system_stats > /dev/null 2>&1; do
    sleep 1
done
echo "ComfyUI is ready!"

echo "Starting RunPod handler..."
python3 handler.py
