FROM runpod/worker-comfyui:5.7.1-base

# Custom nodes
RUN comfy-node-install comfyui-reactor && \
    comfy-node-install comfyui_controlnet_aux && \
    comfy-node-install ComfyUI_UltimateSDUpscale && \
    comfy-node-install ComfyUI_IPAdapter_plus && \
    comfy-node-install ComfyUI-Impact-Pack
