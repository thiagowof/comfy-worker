import runpod
import json
import urllib.request
import urllib.parse
import time
import uuid
import base64
import os

COMFY_API = "http://127.0.0.1:8188"
COMFY_OUTPUT_DIR = "/comfyui/output"


def queue_workflow(workflow, client_id):
    """Send workflow to ComfyUI for processing."""
    data = json.dumps({"prompt": workflow, "client_id": client_id}).encode("utf-8")
    req = urllib.request.Request(f"{COMFY_API}/prompt", data=data)
    req.add_header("Content-Type", "application/json")
    resp = urllib.request.urlopen(req)
    return json.loads(resp.read())["prompt_id"]


def poll_result(prompt_id, timeout=600):
    """Wait for the workflow to complete and return outputs."""
    start = time.time()
    while time.time() - start < timeout:
        try:
            resp = urllib.request.urlopen(f"{COMFY_API}/history/{prompt_id}")
            history = json.loads(resp.read())
            if prompt_id in history:
                outputs = history[prompt_id]
                if outputs.get("status", {}).get("completed", False) or "outputs" in outputs:
                    return outputs.get("outputs", outputs)
        except Exception:
            pass
        time.sleep(1)
    raise TimeoutError(f"Workflow did not complete within {timeout}s")


def get_images_from_outputs(outputs):
    """Extract images from workflow outputs and encode as base64."""
    images = []
    for node_id, node_output in outputs.items():
        if "images" in node_output:
            for img_info in node_output["images"]:
                img_path = os.path.join(COMFY_OUTPUT_DIR, img_info["subfolder"], img_info["filename"])
                if os.path.exists(img_path):
                    with open(img_path, "rb") as f:
                        img_b64 = base64.b64encode(f.read()).decode("utf-8")
                    images.append({
                        "filename": img_info["filename"],
                        "data": img_b64,
                        "type": img_info.get("type", "output"),
                    })
    return images


def save_input_images(input_images):
    """Save base64 input images to ComfyUI input directory."""
    input_dir = "/comfyui/input"
    os.makedirs(input_dir, exist_ok=True)
    saved = {}
    for name, b64_data in input_images.items():
        filepath = os.path.join(input_dir, name)
        with open(filepath, "wb") as f:
            f.write(base64.b64decode(b64_data))
        saved[name] = filepath
    return saved


def handler(event):
    """RunPod serverless handler."""
    input_data = event.get("input", {})

    # Workflow JSON (ComfyUI API format)
    workflow = input_data.get("workflow")
    if not workflow:
        return {"error": "No workflow provided"}

    # Optional: input images as base64
    input_images = input_data.get("images", {})
    if input_images:
        save_input_images(input_images)

    # Optional: timeout
    timeout = input_data.get("timeout", 600)

    try:
        client_id = str(uuid.uuid4())
        prompt_id = queue_workflow(workflow, client_id)
        outputs = poll_result(prompt_id, timeout=timeout)
        images = get_images_from_outputs(outputs)

        return {
            "prompt_id": prompt_id,
            "images": images,
            "status": "success",
        }
    except TimeoutError as e:
        return {"error": str(e), "status": "timeout"}
    except Exception as e:
        return {"error": str(e), "status": "failed"}


if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})
