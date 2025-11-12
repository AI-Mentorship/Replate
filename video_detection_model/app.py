import os
import shutil
import cv2
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from models.clip_model import detect_video_ingredients
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(title="CLIP Video Ingredient Detection API", version="1.0.0")

# --- CORS Middleware ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Supabase Setup ---
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

@app.post("/detect")
async def detect(file: UploadFile = File(...)):
    if not file.content_type.startswith("video/"):
        raise HTTPException(status_code=400, detail="Only video files are allowed")

    try:
        os.makedirs("uploads", exist_ok=True)
        file_path = os.path.join("uploads", file.filename)

        # Save uploaded video
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Process video and detect ingredients
        data = detect_video_ingredients(file_path)

        # Upload detections to Supabase table
        try:
            supabase.table("video_detections").insert({
                "filename": file.filename,
                "detections": data["detections"],
                "total_frames": data["total_frames"]
            }).execute()
        except Exception as e:
            print("Supabase upload failed:", e)

        # Clean up uploaded video
        os.remove(file_path)
        return JSONResponse(content=data)

    except Exception as e:
        if os.path.exists(file_path):
            os.remove(file_path)
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/")
async def root():
    return {"message": "Welcome to the CLIP Video Ingredient Detection API. POST /detect to upload a video."}
