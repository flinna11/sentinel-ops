import chromadb
from chromadb.utils import embedding_functions
import subprocess

client = chromadb.PersistentClient(path="./vectorstore")
collection = client.get_collection(
    name="sentinel_ops",
    embedding_function=embedding_functions.OllamaEmbeddingFunction(model_name="gemma3:4b")
)

def ask_ollama(prompt):
    result = subprocess.run(
        ["ollama", "run", "gemma3:4b"],
        input=prompt.encode(),
        stdout=subprocess.PIPE
    )
    return result.stdout.decode()

def query(q):
    results = collection.query(query_texts=[q], n_results=5)
    context = "\n\n".join(results["documents"][0])

    prompt = f"""
Use ONLY the context below to answer the question.

Context:
{context}

Question:
{q}

Answer:
"""
    return ask_ollama(prompt)

if __name__ == "__main__":
    while True:
        q = input("Ask: ")
        print(query(q))