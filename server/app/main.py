
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os

from routers import posts

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("")
    yield 
    print("")

def create_app() -> FastAPI:

    app = FastAPI(lifespan=lifespan)

    app.include_router(posts.router, prefix="/posts", tags=["posts"])

    data_dir = os.path.join(os.path.dirname(__file__), "..", "data")
    app.mount("/static", StaticFiles(directory=data_dir), name="static")

    @app.get("/")
    def root():
        return { "status": "up" }
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["http://localhost:5173", "http://localhost:3000"],
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "DELETE"],
        allow_headers=["Content-Type"],
    )
    
    return app

load_dotenv() 

# uvicorn main:app --host 0.0.0.0 --port 6969 --reload
app = create_app()