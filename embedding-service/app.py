from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

app = FastAPI()

# Load model once at startup (uses local cache)
model = SentenceTransformer('all-MiniLM-L6-v2')


class TextInput(BaseModel):
    text: str


class SimilarityInput(BaseModel):
    text1: str
    text2: str


@app.post("/embed")
async def create_embedding(input: TextInput):
    """Generate embedding vector for text"""
    try:
        embedding = model.encode(input.text)
        return {
            "embedding": embedding.tolist(),
            "dimensions": len(embedding)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/similarity")
async def calculate_similarity(input: SimilarityInput):
    """Calculate cosine similarity between two texts"""
    try:
        emb1 = model.encode(input.text1)
        emb2 = model.encode(input.text2)

        similarity = cosine_similarity(
            emb1.reshape(1, -1),
            emb2.reshape(1, -1)
        )[0][0]

        return {
            "similarity": float(similarity),
            "interpretation": interpret_score(similarity)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def interpret_score(score):
    """Human-readable interpretation"""
    if score >= 0.80:
        return "Very High Match"
    elif score >= 0.70:
        return "High Match"
    elif score >= 0.60:
        return "Moderate Match"
    elif score >= 0.50:
        return "Low Match"
    else:
        return "Poor Match"


@app.get("/health")
async def health_check():
    return {"status": "healthy", "model": "all-MiniLM-L6-v2"}
