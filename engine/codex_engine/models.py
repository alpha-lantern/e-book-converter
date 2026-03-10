from enum import Enum
from typing import Optional
from uuid import UUID, uuid4
from pydantic import BaseModel, Field, computed_field

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


class CodexStyle(BaseModel):
    """Specialized model for CSS-like block styles to reduce memory overhead."""
    font_size: Optional[float] = None
    font_weight: Optional[str] = None
    line_height: Optional[float] = None
    color: Optional[str] = None
    text_align: Optional[str] = None
    margin_top: Optional[float] = None
    margin_bottom: Optional[float] = None
    font_family: Optional[str] = None
    text_decoration: Optional[str] = None
    font_style: Optional[str] = None


class CodexBlock(BaseModel):
    """A block of content in a codex."""
    id: UUID = Field(default_factory=uuid4)
    type: CodexBlockType
    content: str
    style: CodexStyle = Field(default_factory=CodexStyle)
    bbox: CodexBBox


class CodexSEO(BaseModel):
    """Crawler-specific metadata for SEO optimization."""
    title: Optional[str] = None
    description: Optional[str] = None
    keywords: list[str] = Field(default_factory=list)
    canonical_url: Optional[str] = None
    og_image: Optional[str] = None


class CodexMeta(BaseModel):
    """Metadata for a codex document."""
    title: str
    author: str
    description: Optional[str] = None
    base_size: float
    seo: CodexSEO = Field(default_factory=CodexSEO)


class CodexManifest(BaseModel):
    """The root container for a codex document."""
    meta: CodexMeta
    blocks: list[CodexBlock] = Field(default_factory=list)
    assets: dict = Field(default_factory=dict)

    @computed_field
    @property
    def block_map(self) -> dict[UUID, CodexBlock]:
        """Returns a cached mapping of block IDs for O(1) lookups during synthesis."""
        return {block.id: block for block in self.blocks}

    def to_json(self) -> str:
        """Serialize the manifest to a JSON string."""
        return self.model_dump_json()