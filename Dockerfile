FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# System dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv git wget \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxrender1 libxext6 \
    && rm -rf /var/lib/apt/lists/*

# ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip3 install --no-cache-dir -r requirements.txt

# Custom nodes
RUN cd custom_nodes && \
    # ReActor (face swap)
    git clone https://github.com/Gourieff/ComfyUI-ReActor.git && \
    pip3 install --no-cache-dir -r ComfyUI-ReActor/requirements.txt && \
    # ControlNet Auxiliary Preprocessors
    git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git && \
    pip3 install --no-cache-dir -r comfyui_controlnet_aux/requirements.txt && \
    # ComfyUI Manager
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    # Ultimate SD Upscale
    git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git --recursive && \
    # IP-Adapter
    git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git && \
    # Impact Pack (face detection/segmentation)
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    pip3 install --no-cache-dir -r ComfyUI-Impact-Pack/requirements.txt

# RunPod SDK
RUN pip3 install --no-cache-dir runpod requests

# Symlink models to network volume (mounted at /runpod-volume at runtime)
RUN rm -rf /comfyui/models && \
    ln -s /runpod-volume/models /comfyui/models

# Handler
COPY handler.py /comfyui/handler.py
COPY start.sh /comfyui/start.sh
RUN chmod +x /comfyui/start.sh

CMD ["/comfyui/start.sh"]
