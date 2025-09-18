from fastapi import FastAPI
from typing import List
from pydantic import BaseModel

app = FastAPI(
    title="Fruits and Vegetables API",
    description="A simple FastAPI backend with fruits and vegetables endpoints",
    version="1.0.0"
)

# Response models
class Item(BaseModel):
    name: str
    local_name: str = None
    scientific_name: str = None

class ItemList(BaseModel):
    items: List[Item]
    count: int

# Data for fruits (common fruits)
FRUITS_DATA = [
    Item(name="Apple", local_name="Seb", scientific_name="Malus domestica"),
    Item(name="Banana", local_name="Kela", scientific_name="Musa acuminata"),
    Item(name="Orange", local_name="Santra", scientific_name="Citrus × sinensis"),
    Item(name="Mango", local_name="Aam", scientific_name="Mangifera indica"),
    Item(name="Guava", local_name="Amrood", scientific_name="Psidium guajava"),
    Item(name="Papaya", local_name="Papita", scientific_name="Carica papaya"),
    Item(name="Pomegranate", local_name="Anar", scientific_name="Punica granatum"),
    Item(name="Grapes", local_name="Angoor", scientific_name="Vitis vinifera"),
    Item(name="Watermelon", local_name="Tarbooz", scientific_name="Citrullus lanatus"),
    Item(name="Pineapple", local_name="Ananas", scientific_name="Ananas comosus"),
]

# Data for vegetables native to India
VEGETABLES_DATA = [
    Item(name="Bottle Gourd", local_name="Lauki", scientific_name="Lagenaria siceraria"),
    Item(name="Ridge Gourd", local_name="Turai", scientific_name="Luffa acutangula"),
    Item(name="Bitter Gourd", local_name="Karela", scientific_name="Momordica charantia"),
    Item(name="Snake Gourd", local_name="Chichinda", scientific_name="Trichosanthes cucumerina"),
    Item(name="Pointed Gourd", local_name="Parwal", scientific_name="Trichosanthes dioica"),
    Item(name="Ash Gourd", local_name="Petha", scientific_name="Benincasa hispida"),
    Item(name="Indian Okra", local_name="Bhindi", scientific_name="Abelmoschus esculentus"),
    Item(name="Drumstick", local_name="Moringa", scientific_name="Moringa oleifera"),
    Item(name="Indian Spinach", local_name="Palak", scientific_name="Spinacia oleracea"),
    Item(name="Fenugreek Leaves", local_name="Methi", scientific_name="Trigonella foenum-graecum"),
    Item(name="Mustard Greens", local_name="Sarson", scientific_name="Brassica juncea"),
    Item(name="Amaranth", local_name="Chaulai", scientific_name="Amaranthus viridis"),
    Item(name="Indian Eggplant", local_name="Baingan", scientific_name="Solanum melongena"),
    Item(name="Cluster Beans", local_name="Gwar", scientific_name="Cyamopsis tetragonoloba"),
    Item(name="Taro Root", local_name="Arvi", scientific_name="Colocasia esculenta"),
    Item(name="Yam", local_name="Jimikand", scientific_name="Dioscorea alata"),
    Item(name="Sweet Potato", local_name="Shakarkand", scientific_name="Ipomoea batatas"),
    Item(name="Indian Turnip", local_name="Shalgam", scientific_name="Brassica rapa"),
    Item(name="Water Chestnut", local_name="Singhara", scientific_name="Trapa natans"),
    Item(name="Lotus Root", local_name="Kamal Kakdi", scientific_name="Nelumbo nucifera"),
]

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Welcome to the Fruits and Vegetables API",
        "endpoints": {
            "fruits": "/fruits",
            "vegetables": "/vegetables",
            "docs": "/docs"
        }
    }

@app.get("/fruits", response_model=ItemList)
async def get_fruits():
    """Get a list of common fruits"""
    return ItemList(items=FRUITS_DATA, count=len(FRUITS_DATA))

@app.get("/vegetables", response_model=ItemList)
async def get_vegetables():
    """Get a list of vegetables native to India"""
    return ItemList(items=VEGETABLES_DATA, count=len(VEGETABLES_DATA))

@app.get("/fruits/{fruit_name}")
async def get_fruit_by_name(fruit_name: str):
    """Get specific fruit by name"""
    fruit = next((f for f in FRUITS_DATA if f.name.lower() == fruit_name.lower()), None)
    if fruit:
        return fruit
    return {"error": "Fruit not found"}

@app.get("/vegetables/{vegetable_name}")
async def get_vegetable_by_name(vegetable_name: str):
    """Get specific vegetable by name"""
    vegetable = next((v for v in VEGETABLES_DATA if v.name.lower() == vegetable_name.lower()), None)
    if vegetable:
        return vegetable
    return {"error": "Vegetable not found"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)