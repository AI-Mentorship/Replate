# ============================================================
# app.py — FastAPI Ingredient Detection API
# ============================================================

import os
import shutil
from typing import Dict, Any
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from models.gemini_model import detect_ingredients

app = FastAPI(
    title="Ingredient Detection API",
    description="Upload an image → Gemini detects ingredients → Saves results locally + to Supabase.",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/detect", response_model=Dict[str, Any])
async def detect(file: UploadFile = File(...)):
    """
    Upload an image file and detect ingredients using Gemini AI.
    
    Args:
        file (UploadFile): Image file to analyze
        
    Returns:
        JSONResponse: Detected ingredients and their confidence scores
        
    Raises:
        HTTPException: If file upload or processing fails
    """
    # Validate file type
    if not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=400,
            detail="Only image files are allowed"
        )
        
    try:
        # Create uploads directory
        os.makedirs("uploads", exist_ok=True)
        image_path = os.path.join("uploads", file.filename)
        
        # Save uploaded image
        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Run Gemini detection + Supabase sync
        data = detect_ingredients(image_path)
        
        # Clean up uploaded file
        os.remove(image_path)
        
        return JSONResponse(content=data)
        
    except Exception as e:
        # Clean up on error
        if os.path.exists(image_path):
            os.remove(image_path)
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "Welcome to the Ingredient Detection API. Use POST /detect to upload an image."}
