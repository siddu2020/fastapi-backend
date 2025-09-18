# FastAPI Backend - Fruits and Vegetables API

A simple FastAPI backend with `/fruits` and `/vegetables` endpoints, featuring a comprehensive list of vegetables native to India.

## Features

- **Fruits Endpoint**: Returns a list of common fruits with local Indian names and scientific names
- **Vegetables Endpoint**: Returns a comprehensive list of vegetables native to India
- **Individual Item Lookup**: Get specific fruits or vegetables by name
- **API Documentation**: Auto-generated interactive documentation with Swagger UI
- **Response Models**: Structured JSON responses with proper data models

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd fastapi-backend
```

2. Install dependencies:
```bash
pip3 install -r requirements.txt
```

## Running the Application

### Option 1: Using Python directly
```bash
python3 main.py
```

### Option 2: Using the start script
```bash
./start.sh
```

### Option 3: Using Uvicorn directly
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at `http://localhost:8000`

## API Endpoints

### Root Endpoint
- **GET** `/` - Welcome message and available endpoints

### Fruits
- **GET** `/fruits` - Get all fruits (10 items)
- **GET** `/fruits/{fruit_name}` - Get specific fruit by name

### Vegetables
- **GET** `/vegetables` - Get all vegetables native to India (20 items)
- **GET** `/vegetables/{vegetable_name}` - Get specific vegetable by name

### Documentation
- **GET** `/docs` - Interactive API documentation (Swagger UI)
- **GET** `/redoc` - Alternative API documentation (ReDoc)

## Example Responses

### Fruits Endpoint
```json
{
  "items": [
    {
      "name": "Mango",
      "local_name": "Aam",
      "scientific_name": "Mangifera indica"
    },
    ...
  ],
  "count": 10
}
```

### Vegetables Endpoint
```json
{
  "items": [
    {
      "name": "Bottle Gourd",
      "local_name": "Lauki",
      "scientific_name": "Lagenaria siceraria"
    },
    ...
  ],
  "count": 20
}
```

## Indian Native Vegetables Included

The `/vegetables` endpoint includes authentic vegetables native to India such as:
- Bottle Gourd (Lauki)
- Ridge Gourd (Turai)
- Bitter Gourd (Karela)
- Snake Gourd (Chichinda)
- Pointed Gourd (Parwal)
- Drumstick (Moringa)
- And many more traditional Indian vegetables

## Testing the API

### Using curl:
```bash
# Get all fruits
curl http://localhost:8000/fruits

# Get all vegetables
curl http://localhost:8000/vegetables

# Get specific fruit
curl http://localhost:8000/fruits/mango

# Get specific vegetable
curl http://localhost:8000/vegetables/drumstick
```

### Using browser:
Visit `http://localhost:8000/docs` for interactive API documentation where you can test all endpoints directly.

## Dependencies

- FastAPI 0.104.1
- Uvicorn 0.24.0 (ASGI server)
- Pydantic (for data validation)