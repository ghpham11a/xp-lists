from pydantic import BaseModel

class Post(BaseModel):
    id: int
    title: str
    image_url: str
    description: str