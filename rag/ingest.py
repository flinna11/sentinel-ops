import os
import yaml
import chromadb
from chromadb.utils import embedding_functions

# Load config
with open("config.yaml", "r") as f:
    cfg = yaml.safe_load(f)

chunk_size = cfg["chunk_size"]
chunk_overlap = cfg["chunk_overlap"]
paths = cfg["include_paths"]

client = chromadb.PersistentClient(path=cfg["vectorstore_path"])
collection = client.get_or_create_collection(
    name="sentinel_ops",
    embedding_function=embedding_functions.OllamaEmbeddingFunction(
        model_name="nomic-embed-text"
    )
)

def chunk_text(text, size, overlap):
    chunks = []
    start = 0
    length = len(text)

    # Prevent infinite loops
    step = max(1, size - overlap)

    while start < length:
        end = min(start + size, length)
        chunks.append(text[start:end])
        start += step

    return chunks

doc_id = 0

for folder in paths:
    folder_path = os.path.join(os.path.dirname(__file__), folder)

    for root, _, files in os.walk(folder_path):
        for file in files:
            if not file.lower().endswith((".md", ".txt", ".yaml", ".yml", ".tf", ".json")):
                continue

            full_path = os.path.join(root, file)
            print(f"Processing {full_path}")

            with open(full_path, "r", encoding="utf-8") as f:
                text = f.read()

            chunks = chunk_text(text, chunk_size, chunk_overlap)

            for j, chunk in enumerate(chunks):
                collection.add(
                    ids=[f"doc-{doc_id}-{j}"],
                    documents=[chunk],
                    metadatas=[{"source": file}]
                )

            doc_id += 1

print("Ingestion complete.")