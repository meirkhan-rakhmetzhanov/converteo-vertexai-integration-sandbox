```bash
TOKEN=$(gcloud auth print-access-token)
PROJECT_ID='cvto-internal-saintgobain-sdx'
REGION='europe-west4'
MODEL='gemini-2.5-flash'
```

### Simple example
```bash
curl -X POST \
  "https://$REGION-aiplatform.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/publishers/google/models/$MODEL:generateContent" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "role": "user",
      "parts": [{ "text": "Respond with Hello World" }]
    }]
  }'
```

### Few-shot example
```bash
curl -X POST \
  "https://${REGION}-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/publishers/google/models/${MODEL}:generateContent" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "systemInstruction": {
      "parts": [{ "text": "You are a construction materials expert." }]
    },
    "contents": [
      {
        "role": "user",
        "parts": [{ "text": "What is concrete?" }]
      },
      {
        "role": "model",
        "parts": [{ "text": "Concrete is a composite material made of cement, water, and aggregates." }]
      },
      {
        "role": "user",
        "parts": [{ "text": "What about its tensile strength?" }]
      }
    ]
  }'
```