import os
import json
import re
import datetime
from PIL import Image
import google.generativeai as genai
from supabase import create_client, Client
from dotenv import load_dotenv
from fastapi import HTTPException

# Load Environment Variables
load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
USER_ID = os.getenv("USER_ID")

# Configure clients
if not all([GEMINI_API_KEY, SUPABASE_URL, SUPABASE_KEY, USER_ID]):
    raise ValueError("Missing required environment variables. Please check .env file.")

genai.configure(api_key=GEMINI_API_KEY)
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def detect_ingredients(image_path: str) -> dict:
    """
    Detect ingredients in an image using Gemini AI and sync results to Supabase.
    
    Args:
        image_path (str): Path to the image file
        
    Returns:
        dict: Dictionary containing detected ingredients and their confidence scores
    """
    try:
        # Load and validate image
        if not os.path.exists(image_path):
            raise HTTPException(status_code=404, detail="Image file not found")
            
        img = Image.open(image_path)
        
        # Gemini prompt
        prompt = """
        You are an expert in food and ingredient detection.
        Analyze this image of a fridge, pantry, or kitchen counter and identify all visible ingredients or food items.

        For each detected item, estimate how confident you are that the identification is correct (0.0 to 1.0).
        Return strictly JSON:
        {
          "ingredients": [
            {"name": "ingredient_name", "confidence": confidence_value}
          ]
        }
        """

        # Run Gemini detection
        model = genai.GenerativeModel("models/gemini-2.5-flash")
        response = model.generate_content([prompt, img])

        # Parse JSON response
        text = response.text
        match = re.search(r"\{[\s\S]*\}", text)
        data = {"ingredients": []}
        
        if match:
            try:
                data = json.loads(match.group(0))
            except json.JSONDecodeError:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to parse Gemini response"
                )

        # Sync to Supabase
        sync_to_supabase(data.get("ingredients", []))

        # Save output locally
        os.makedirs("outputs", exist_ok=True)
        with open("outputs/detections.json", "w") as f:
            json.dump(data, f, indent=2)

        return data

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def sync_to_supabase(detections: list) -> None:
    """
    Sync detected ingredients to Supabase database.
    
    Args:
        detections (list): List of dictionaries containing ingredient detections
    """
    today = datetime.date.today().isoformat()
    
    try:
        for d in detections:
            name = d.get("name", "").lower()
            conf = round(d.get("confidence", 0), 2)

            # Insert into pantry table
            supabase.table("pantry").insert({
                "user_id": USER_ID,
                "item_name": name,
                "date_added": today
            }).execute()

            # Insert into substitutions table
            supabase.table("substitutions").insert({
                "ingredient": name,
                "alt_name": None,
                "nutrition_delta": {"confidence": conf},
                "source": "Gemini AI"
            }).execute()

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to sync with Supabase: {str(e)}"
        )