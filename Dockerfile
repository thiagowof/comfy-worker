FROM runpod/worker-comfyui:5.6.0-base

# Custom nodes
RUN comfy-node-install comfyui-reactor && \
    comfy-node-install comfyui_controlnet_aux && \
    comfy-node-install ComfyUI-Manager && \
    comfy-node-install ComfyUI_UltimateSDUpscale && \
    comfy-node-install ComfyUI_IPAdapter_plus && \
    comfy-node-install ComfyUI-Impact-Pack

# Custom extra_model_paths to match our network volume structure
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
