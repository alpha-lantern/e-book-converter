from enum import Enum
from uuid import UUID, uuid4
from pydantic import BaseModel, Field

class CodexBlockType(str, Enum):
    """Enum for the different types of blocks in a codex."""
    H1 = "h1"
    H2 = "h2"
    P = "p"
    IMAGE = "image"
    WIDGET = "widget"


class CodexBBox(BaseModel):
    """Represents a bounding box with coordinates (x0, y0, x1, y1)."""
    x0: float
    y0: float
    x1: float
    y1: float


class CodexBlock(BaseModel):
    """A block of content in a codex."""
    id: UUID = Field(default_factory=uuid4)
    type: CodexBlockType
    content: str
    style: dict = Field(default_factory=dict)
    bbox: CodexBBox