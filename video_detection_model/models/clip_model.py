import os
import json
import cv2
import torch
import numpy as np
from PIL import Image
from ultralytics import YOLO
import clip
from typing import Dict, Any
from supabase import create_client
from dotenv import load_dotenv

# Load env vars
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# Device setup
device = "cpu"

# Ingredients & prompts
INGREDIENTS = [
    "lettuce", "romaine", "spinach", "kale", "arugula", "cabbage",
    "tomato", "cherry tomato", "cucumber", "carrot", "bell pepper",
    "red onion", "onion", "corn", "beet", "radish", "celery", "olive",
    "chicken", "egg", "tofu", "tuna", "salmon", "bacon", "cheese", "feta",
    "avocado", "crouton", "walnut", "almond", "pecan", "pumpkin seed",
    "ranch dressing", "vinaigrette", "olive oil", "balsamic vinegar"
]

PROMPTS = [
    "a photo of {x}", "a close-up of {x}", "diced {x}", "chopped {x}",
    "sliced {x}", "finely chopped {x}", "coarsely chopped {x}",
    "whole {x}", "a bowl containing {x}"
]

# Load CLIP model
clip_model, clip_preprocess = clip.load("ViT-B/32", device=device)

# Prepare text embeddings
with torch.no_grad():
    text_prompts = []
    for ing in INGREDIENTS:
        for t in PROMPTS:
            text_prompts.append(t.format(x=ing))
    text_tokens = clip.tokenize(text_prompts).to(device)
    text_emb = clip_model.encode_text(text_tokens)
    text_emb = text_emb / text_emb.norm(dim=-1, keepdim=True)

# Load YOLO model
YOLO_WEIGHTS = "yolov8l.pt"
if not os.path.exists(YOLO_WEIGHTS):
    print(f"{YOLO_WEIGHTS} not found. Downloading automatically...")
yolo = YOLO(YOLO_WEIGHTS)

BASE_CONF = 0.05
IOU_NMS = 0.45


def clip_classify_crop(bgr_image, min_side=64):
    h, w = bgr_image.shape[:2]
    if min(h, w) < min_side:
        return None, 0.0, None

    pil = Image.fromarray(cv2.cvtColor(bgr_image, cv2.COLOR_BGR2RGB))
    image_input = clip_preprocess(pil).unsqueeze(0).to(device)

    with torch.no_grad():
        image_emb = clip_model.encode_image(image_input)
        image_emb = image_emb / image_emb.norm(dim=-1, keepdim=True)
        sims = (100.0 * image_emb @ text_emb.T).softmax(dim=-1).squeeze(0)

    agg_scores = {}
    idx = 0
    for ing in INGREDIENTS:
        scores = sims[idx: idx + len(PROMPTS)]
        agg_scores[ing] = float(scores.sum().item())
        idx += len(PROMPTS)

    total = sum(agg_scores.values()) + 1e-9
    for k in agg_scores:
        agg_scores[k] /= total

    best_ing = max(agg_scores, key=agg_scores.get)
    best_conf = agg_scores[best_ing]
    top_prompt_idx = int(torch.argmax(sims).item())
    top_prompt_text = text_prompts[top_prompt_idx]

    return best_ing, float(best_conf), top_prompt_text


def estimate_chop_level(crop_bgr):
    h, w = crop_bgr.shape[:2]
    if h < 32 or w < 32:
        return "whole/large", {"edge_density": 0, "mean_contour_area": h*w}

    gray = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (5,5), 0)
    edges = cv2.Canny(gray, 50, 150)
    edge_density = float(np.mean(edges > 0))

    cnts, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    areas = [cv2.contourArea(c) for c in cnts if cv2.contourArea(c) > 2.0]
    mean_area = float(np.mean(areas)) if areas else h*w

    if edge_density > 0.10 and mean_area < (h*w)*0.002:
        level = "finely chopped"
    elif edge_density > 0.04 and mean_area < (h*w)*0.01:
        level = "roughly chopped"
    else:
        level = "whole/large"

    return level, {"edge_density": edge_density, "mean_contour_area": mean_area, "contours": len(areas)}


def detect_video_ingredients(video_path: str) -> Dict[str, Any]:
    if not os.path.exists(video_path):
        raise FileNotFoundError("Video not found.")

    cap = cv2.VideoCapture(video_path)
    frame_count = 0
    detections = []

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame_count += 1
        if frame_count % 10 != 0:  # process every 10th frame to save time
            continue

        results = yolo.predict(frame, conf=BASE_CONF, iou=IOU_NMS, verbose=False)
        for r in results:
            for b in r.boxes:
                x1, y1, x2, y2 = map(int, b.xyxy[0].tolist())
                crop = frame[y1:y2, x1:x2].copy()
                ing, conf, top_prompt = clip_classify_crop(crop)
                if ing is None:
                    continue
                chop, _ = estimate_chop_level(crop)
                detections.append({
                    "frame": frame_count,
                    "bbox": [x1, y1, x2, y2],
                    "ingredient": ing,
                    "confidence": round(conf, 3),
                    "chop_level": chop
                })

    cap.release()

    result = {
        "total_frames": frame_count,
        "detections": detections
    }

    # Save results locally
    os.makedirs("outputs", exist_ok=True)
    out_json = os.path.join("outputs", f"{os.path.basename(video_path)}.json")
    with open(out_json, "w") as f:
        json.dump(result, f, indent=2)

    # Upload to Supabase Storage
    try:
        with open(out_json, "rb") as f:
            supabase.storage.from_("results").upload(os.path.basename(out_json), f)
    except Exception as e:
        print("Supabase upload failed:", e)

    return result
