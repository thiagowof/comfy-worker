FROM runpod/worker-comfyui:5.6.0-base

# Custom nodes
RUN comfy-node-install comfyui-reactor && \
    comfy-node-install comfyui_controlnet_aux && \
    comfy-node-install ComfyUI_UltimateSDUpscale && \
    comfy-node-install ComfyUI_IPAdapter_plus && \
    comfy-node-install ComfyUI-Impact-Pack

# Install huggingface_hub for downloading models
RUN pip install --no-cache-dir huggingface_hub

# Download Z-Image Turbo (diffusion model)
RUN python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download('Comfy-Org/z_image_turbo', 'split_files/diffusion_models/z_image_turbo_bf16.safetensors', local_dir='/comfyui/models/diffusion_models/')" && \
    mv /comfyui/models/diffusion_models/split_files/diffusion_models/z_image_turbo_bf16.safetensors /comfyui/models/diffusion_models/ && \
    rm -rf /comfyui/models/diffusion_models/split_files

# Download Qwen 3 4B text encoder
RUN python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download('Comfy-Org/z_image_turbo', 'split_files/text_encoders/qwen_3_4b.safetensors', local_dir='/comfyui/models/text_encoders/')" && \
    mv /comfyui/models/text_encoders/split_files/text_encoders/qwen_3_4b.safetensors /comfyui/models/text_encoders/ && \
    rm -rf /comfyui/models/text_encoders/split_files

# Download VAE
RUN python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download('Comfy-Org/z_image_turbo', 'split_files/vae/ae.safetensors', local_dir='/comfyui/models/vae/')" && \
    mv /comfyui/models/vae/split_files/vae/ae.safetensors /comfyui/models/vae/ && \
    rm -rf /comfyui/models/vae/split_files

# Download ControlNet Union v2.1 lite
RUN python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download('alibaba-pai/Z-Image-Turbo-Fun-Controlnet-Union-2.1', 'Z-Image-Turbo-Fun-Controlnet-Union-2.1-lite-2602-8steps.safetensors', local_dir='/comfyui/models/controlnet/')"

# Download ReActor models
RUN python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download('Gourieff/ReActor', 'models/inswapper_128.onnx', local_dir='/comfyui/models/insightface/', repo_type='dataset')" && \
    mv /comfyui/models/insightface/models/inswapper_128.onnx /comfyui/models/insightface/ && \
    rm -rf /comfyui/models/insightface/models

RUN python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download('Gourieff/ReActor', 'models/facerestore_models/codeformer-v0.1.0.pth', local_dir='/comfyui/models/facerestore_models/', repo_type='dataset')" && \
    mv /comfyui/models/facerestore_models/models/facerestore_models/codeformer-v0.1.0.pth /comfyui/models/facerestore_models/ && \
    rm -rf /comfyui/models/facerestore_models/models

# Download upscalers
RUN python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download('lokCX/4x-Ultrasharp', '4x-UltraSharp.pth', local_dir='/comfyui/models/upscale_models/')"

# No network volume needed - all models baked in
