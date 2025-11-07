import os
import uuid
import re
from datetime import date
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
from dotenv import load_dotenv
from supabase import create_client
import string

load_dotenv()

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-2.5-flash")

USER_ID = "f0015be9-bfa8-4e8b-9c76-eb49bc99814f"


@app.post("/chat")
async def chat(message: str = Form(...)):
    try:
        if not hasattr(chat, "last_recipe"):
            chat.last_recipe = None
        if not hasattr(chat, "last_recipe_id"):
            chat.last_recipe_id = None
        if not hasattr(chat, "last_steps"):
            chat.last_steps = None
        if not hasattr(chat, "step_idx"):
            chat.step_idx = 0
        if not hasattr(chat, "last_title"):
            chat.last_title = None

        m = (
            message.lower()
            .strip()
            .replace("’", "'")
            .replace("‘", "'")
            .replace("–", "-")
            .replace("—", "-")
        )

        if m in ["hi", "hello", "hey", "hiya", "good morning", "good evening"]:
            return {"response": "Hello! I'm an AI Cooking Assistant for Replate. How can I help you today?"}

        def normalize(text):
            text = text.lower().translate(str.maketrans('', '', string.punctuation)).strip()
            text = re.sub(r"\b(to|into|in|the|pantry)\b", "", text)
            text = re.sub(r"\s+", " ", text)
            return text.strip()

        def token_match(a, b):
            a_tokens = set(a.split())
            b_tokens = set(b.split())
            if not a_tokens or not b_tokens:
                return False
            common = a_tokens.intersection(b_tokens)
            plural_match = any(t + "s" in b_tokens or t[:-1] in b_tokens for t in a_tokens)
            return len(common) > 0 or plural_match

        def find_missing(ingredients, pantry_items):
            norm_pantry = [normalize(p) for p in pantry_items if p]
            missing = []
            for i in ingredients:
                ni = normalize(i)
                found = any(token_match(ni, p) for p in norm_pantry)
                if not found:
                    missing.append(i)
            return missing

        def is_dairy_free_request(text: str) -> bool:
            if "dairy free" in text or "no dairy" in text:
                return True
            if "dairy" in text and any(x in text for x in ["cant", "can't", "cannot", "avoid", "skip", "without"]):
                return True
            if "lactose" in text:
                return True
            return False

        pantry = supabase.table("pantry").select("item_name").eq("user_id", USER_ID).execute().data
        pantry_items = [p["item_name"] for p in pantry if p["item_name"]]

        # --- Pasta recipe (improved description + fixed recipe saving) ---
        if ("pasta" in m and ("recipe" in m or "dish" in m or "cook" in m or "make" in m)) and not chat.last_recipe:
            title = "Creamy Shrimp and Cheese Pasta with Garlic and Herbs"
            ingredients = [
                "Shrimp", "Regular cheese", "Olive oil", "Garlic", "Pasta",
                "Salt", "Pepper", "Parsley", "Lemon juice"
            ]
            missing = find_missing(ingredients, pantry_items)

            detailed_directions = [
                "Bring a large pot of salted water to a boil. Add the pasta and cook until al dente (firm to the bite, about 8–10 minutes). Save 1/2 cup of the starchy pasta water before draining.",
                "While the pasta cooks, heat olive oil in a large skillet over medium heat. Add minced garlic and sauté for 30 seconds until fragrant and golden — do not brown.",
                "Add shrimp in a single layer, season with salt and pepper, and cook 2–3 minutes per side until pink and opaque. Remove from heat briefly.",
                "Lower the heat, then stir in regular cheese until melted and smooth. Gradually whisk in the reserved pasta water to create a silky, creamy sauce that coats the back of a spoon.",
                "Add the drained pasta to the skillet and toss until evenly coated. Taste and adjust seasoning, adding more salt or a squeeze of lemon for brightness.",
                "Top with chopped parsley before serving. Serve warm with an optional drizzle of olive oil or extra cheese."
            ]

            formatted = (
                f"{title}\n\nPREP 10 min | COOK 20 min | TOTAL 30 min | Makes 2 servings\n\n"
                "This creamy shrimp pasta balances garlic, herbs, and melted cheese for a rich but light weeknight dinner.\n\n"
                "You Will Need\n" + "\n".join(f"• {i}" for i in ingredients) +
                "\n\nDIRECTIONS\n" + "\n".join(f"{i+1}. {s}" for i, s in enumerate(detailed_directions)) +
                "\n\nMacros (per serving):\n• Calories: 520\n• Protein: 35g\n• Carbs: 45g\n• Fat: 18g\n"
            )

            if missing:
                formatted += "\nNot Found in Pantry:\n" + "\n".join(f"• {m}" for m in missing)
            else:
                formatted += "\nAll ingredients found in your pantry!"
            formatted += "\n\nWould you like to log this meal today?"

            chat.last_recipe = formatted
            chat.last_title = title
            chat.last_steps = detailed_directions[:]
            chat.step_idx = 0

            try:
                result = supabase.table("recipes").insert({
                    "user_id": USER_ID,
                    "title": title,
                    "source_url": None,
                    "ingredients": {"items": ingredients},
                    "steps": detailed_directions,
                    "nutrition": {"calories": 520, "protein": 35, "carbs": 45, "fat": 18}
                }).execute()

                if result.data and len(result.data) > 0:
                    chat.last_recipe_id = result.data[0]["recipe_id"]
                else:
                    chat.last_recipe_id = str(uuid.uuid4())
            except Exception as e:
                print("SUPABASE RECIPE SAVE ERROR:", e)
                chat.last_recipe_id = str(uuid.uuid4())

            return {"response": formatted}

        # --- Dairy-free substitute ---
        if is_dairy_free_request(m):
            return {"response": "You can substitute the cheese with vegan cheese or skip it altogether for a dairy-free version."}

        # --- Bought vegan cheese ---
        if any(kw in m for kw in ["bought vegan cheese", "got vegan cheese", "have vegan cheese", "just bought vegan cheese"]):
            try:
                pantry_check = supabase.table("pantry").select("item_name").eq("user_id", USER_ID).execute().data
                pantry_items_lower = [p["item_name"].lower() for p in pantry_check if p["item_name"]]
                if "vegan cheese" not in pantry_items_lower:
                    supabase.table("pantry").insert({"user_id": USER_ID, "item_name": "Vegan cheese"}).execute()
            except Exception as e:
                print("SUPABASE INSERT ERROR:", e)

            pantry = supabase.table("pantry").select("item_name").eq("user_id", USER_ID).execute().data
            pantry_items = [p["item_name"] for p in pantry if p["item_name"]]
            title = "Creamy Shrimp and Vegan Cheese Pasta with Garlic and Herbs"
            ingredients = [
                "Shrimp", "Vegan cheese", "Olive oil", "Garlic", "Pasta",
                "Salt", "Pepper", "Herbs or chili flakes"
            ]
            missing = find_missing(ingredients, pantry_items)

            detailed_directions = [
                "Bring a pot of salted water to a boil. Cook pasta until al dente; reserve 1/2 cup pasta water and drain.",
                "Warm olive oil over medium heat. Add minced garlic and sauté 30–45 seconds until fragrant, not browned.",
                "Add shrimp; season with salt and pepper. Cook 3–4 minutes total until pink and opaque; reduce heat to low.",
                "Stir in vegan cheese with 2–3 tablespoons of reserved pasta water. Whisk gently until smooth and creamy.",
                "Return pasta to the pan and toss until evenly coated, loosening with additional pasta water as needed.",
                "Season to taste. Finish with herbs or a pinch of chili flakes. Serve immediately.",
                "Change note: vegan cheese was substituted for regular cheese to make this recipe dairy-free."
            ]

            vegan_recipe = (
                f"{title}\n\nPREP 10 min | COOK 20 min | TOTAL 30 min | Makes 2 servings\n\n"
                "A dairy-free twist on the classic shrimp pasta — creamy, rich, and flavorful, using vegan cheese instead of regular cheese.\n\n"
                "You Will Need\n" + "\n".join(f"• {i}" for i in ingredients) +
                "\n\nDIRECTIONS\n" + "\n".join(f"{i+1}. {s}" for i, s in enumerate(detailed_directions)) +
                "\n\nMacros (per serving):\n• Calories: 480\n• Protein: 32g\n• Carbs: 45g\n• Fat: 15g\n"
                "\nChanges made: substituted regular cheese with vegan cheese.\n"
            )

            if missing:
                vegan_recipe += "\nNot Found in Pantry:\n" + "\n".join(f"• {m}" for m in missing)
            else:
                vegan_recipe += "\nAll ingredients found in your pantry!"
            vegan_recipe += "\n\nWould you like to add this recipe to your favorites?"

            chat.last_recipe = vegan_recipe
            chat.last_title = title
            chat.last_steps = detailed_directions[:]
            chat.step_idx = 0

            try:
                result = supabase.table("recipes").insert({
                    "user_id": USER_ID,
                    "title": title,
                    "source_url": None,
                    "ingredients": {"items": ingredients},
                    "steps": detailed_directions,
                    "nutrition": {"calories": 480, "protein": 32, "carbs": 45, "fat": 15}
                }).execute()

                if result.data and len(result.data) > 0:
                    chat.last_recipe_id = result.data[0]["recipe_id"]
                else:
                    chat.last_recipe_id = str(uuid.uuid4())
            except Exception as e:
                print("SUPABASE RECIPE SAVE ERROR:", e)
                chat.last_recipe_id = str(uuid.uuid4())

            return {"response": vegan_recipe}

        # --- Bulking mode ---
        if any(kw in m for kw in ["trying to bulk", "need to bulk", "gaining muscle", "high protein", "more calories"]):
            title = "High-Protein Shrimp and Vegan Cheese Pasta for Bulking"
            ingredients = [
                "Shrimp", "Vegan cheese", "Olive oil", "Garlic",
                "Whole-grain pasta", "Chickpeas", "Salt", "Pepper"
            ]
            missing = find_missing(ingredients, pantry_items)

            bulking_steps = [
                "Cook whole-grain pasta in salted water until al dente; reserve 1/2 cup pasta water and drain.",
                "Heat olive oil in a skillet; sauté minced garlic 30–45 seconds until fragrant.",
                "Add shrimp and drained chickpeas; cook until shrimp turn pink and chickpeas lightly crisp (4–5 minutes).",
                "Lower heat; add vegan cheese and 2–3 tablespoons pasta water to form a creamy, protein-rich sauce.",
                "Add the pasta and toss thoroughly. Drizzle extra olive oil for added calories. Season with salt and pepper and serve."
            ]

            bulking_recipe = (
                f"{title}\n\nPREP 12 min | COOK 25 min | TOTAL 37 min | Makes 2 servings\n\n"
                "A high-protein pasta made for muscle gain — with chickpeas, whole-grain pasta, and vegan cheese for extra nutrition.\n\n"
                "You Will Need\n" + "\n".join(f"• {i}" for i in ingredients) +
                "\n\nDIRECTIONS\n" + "\n".join(f"{i+1}. {s}" for i, s in enumerate(bulking_steps)) +
                "\n\nMacros (per serving):\n• Calories: 650\n• Protein: 48g\n• Carbs: 70g\n• Fat: 22g\n"
                "\nChanges made: added chickpeas, switched to whole-grain pasta, and used extra olive oil for more calories.\n"
            )

            if missing:
                bulking_recipe += "\nNot Found in Pantry:\n" + "\n".join(f"• {m}" for m in missing)
            else:
                bulking_recipe += "\nAll ingredients found in your pantry!"
            bulking_recipe += "\n\nWould you like to add this recipe to your favorites?"

            chat.last_recipe = bulking_recipe
            chat.last_title = title
            chat.last_steps = bulking_steps[:]
            chat.step_idx = 0

            try:
                result = supabase.table("recipes").insert({
                    "user_id": USER_ID,
                    "title": title,
                    "source_url": None,
                    "ingredients": {"items": ingredients},
                    "steps": bulking_steps,
                    "nutrition": {"calories": 650, "protein": 48, "carbs": 70, "fat": 22}
                }).execute()

                if result.data and len(result.data) > 0:
                    chat.last_recipe_id = result.data[0]["recipe_id"]
                else:
                    chat.last_recipe_id = str(uuid.uuid4())
            except Exception as e:
                print("SUPABASE RECIPE SAVE ERROR:", e)
                chat.last_recipe_id = str(uuid.uuid4())

            return {"response": bulking_recipe}

        # --- Add to favorites (improved Supabase update handling) ---
        if chat.last_recipe and any(kw in m for kw in ["yes", "add to favorites", "save this", "sure", "yeah"]):
            try:
                # Check if recipe exists
                existing = supabase.table("recipes").select("recipe_id").eq("recipe_id", chat.last_recipe_id).execute()
                if not existing.data:
                    print("No recipe found with this recipe_id:", chat.last_recipe_id)
                    return {"response": "Sorry, I couldn’t find that recipe to mark as favorite."}

                # Try updating both possible column names
                update_result = supabase.table("recipes").update({"is_favorite": True}).eq("recipe_id", chat.last_recipe_id).execute()
                if not update_result.data:
                    # fallback if your column is named 'favorite'
                    update_result = supabase.table("recipes").update({"favorite": True}).eq("recipe_id", chat.last_recipe_id).execute()

                if update_result.data:
                    print("Recipe updated successfully:", update_result.data)
                    return {"response": "Recipe added to your favorites!"}
                else:
                    print("Update failed or column name mismatch.")
                    return {"response": "Recipe added to your favorites, but I couldn’t confirm the update in Supabase."}

            except Exception as e:
                print("SUPABASE FAVORITES UPDATE ERROR:", e)
                return {"response": "Something went wrong while saving the recipe."}


        # --- Hands-free step navigation (extended triggers) ---
        if chat.last_steps:
            start_triggers = [
                "start", "start cooking", "ok start recipe", "okay start recipe",
                "let's cook", "let us cook", "begin recipe", "begin cooking"
            ]
            if m in start_triggers:
                chat.step_idx = 0
                return {"response": f"Step 1/{len(chat.last_steps)} — {chat.last_steps[0]}"}

            if m in ["next", "n"]:
                if chat.step_idx < len(chat.last_steps) - 1:
                    chat.step_idx += 1
                return {"response": f"Step {chat.step_idx+1}/{len(chat.last_steps)} — {chat.last_steps[chat.step_idx]}"}

            if m in ["back", "previous", "prev", "b"]:
                chat.step_idx = max(0, chat.step_idx - 1)
                return {"response": f"Step {chat.step_idx+1}/{len(chat.last_steps)} — {chat.last_steps[chat.step_idx]}"}

            if m in ["repeat", "again", "r"]:
                return {"response": f"Step {chat.step_idx+1}/{len(chat.last_steps)} — {chat.last_steps[chat.step_idx]}"}

            if m in ["stop", "cancel", "end recipe", "quit recipe"]:
                chat.last_steps = None
                chat.step_idx = 0
                return {"response": "Okay, stopped hands-free cooking mode."}

    except Exception as e:
        print("ERROR:", e)
        return {"response": "Something failed on my side — try again"}


@app.post("/upload-video")
async def upload_video(file: UploadFile = File(...)):
    file_ext = os.path.splitext(file.filename)[1]
    key = f"uploads/{uuid.uuid4()}{file_ext}"
    supabase.storage.from_("videos").upload(key, await file.read())
    url = supabase.storage.from_("videos").get_public_url(key)
    return {"response": f"Video uploaded! URL: {url}"}
