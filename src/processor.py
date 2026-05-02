from typing import Any


def process_data(data: list[dict[str, Any]], config: dict | None = None) -> list[dict[str, Any]]:
    results = []
    for item in data:
        if item["status"] == "active":
            if item["score"] > 80:
                entry = {"name": item["name"], "score": item["score"]}
                if config is not None:
                    entry["level"] = "high"
                results.append(entry)
    return results
