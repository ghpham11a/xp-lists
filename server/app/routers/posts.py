from fastapi import APIRouter, Query
from pydantic import BaseModel

from models import Post

router = APIRouter()

TOTAL_POSTS = 500

class PostsResponse(BaseModel):
    posts: list[Post]
    total: int
    page: int
    per_page: int
    total_pages: int

def generate_posts(skip: int, limit: int) -> list[Post]:
    posts = []
    for i in range(skip + 1, min(skip + limit + 1, TOTAL_POSTS + 1)):
        posts.append(Post(
            id=i,
            title=f"Post {i}",
            image_url=f"/static/pic_{i}.png",
            description=f"This is the description for post number {i}"
        ))
    return posts

@router.get("", response_model=PostsResponse)
def get_posts(
    page: int = Query(1, ge=1),
    per_page: int = Query(10, ge=1, le=100)
):
    skip = (page - 1) * per_page
    posts = generate_posts(skip, per_page)
    total_pages = (TOTAL_POSTS + per_page - 1) // per_page

    return PostsResponse(
        posts=posts,
        total=TOTAL_POSTS,
        page=page,
        per_page=per_page,
        total_pages=total_pages
    )

@router.get("/{post_id}", response_model=Post)
def get_post(post_id: int):
    if post_id < 1 or post_id > TOTAL_POSTS:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Post not found")

    return Post(
        id=post_id,
        title=f"Post {post_id}",
        image_url=f"/static/pic_{post_id}.png",
        description=f"This is the description for post number {post_id}"
    )
