from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints

Url = Annotated[str, StringConstraints(pattern=r"^https?://.+")]
Name = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1)]


class Category(BaseModel):
    id: int = Field(gt=0)
    name: Name
    parent_id: int | None = Field(default=None, gt=0)
    source_url: Url


class Product(BaseModel):
    id: int = Field(gt=0)
    name: Name
    description: str = Field(min_length=1)  # no product without a description
    price_gross: float = Field(gt=0)
    vat_rate: float | None = Field(default=None, ge=0, le=100)
    attributes: dict[str, str] = Field(default_factory=dict)
    weight_kg: float | None = Field(default=None, gt=0)
    slider_images: list[Url] = Field(min_length=1)  # at least one photo per product
    description_images: list[Url] = Field(default_factory=list)
    category_ids: list[int] = Field(min_length=1)  # listed in at least one category
    sku: str | None = None
    source_url: Url
