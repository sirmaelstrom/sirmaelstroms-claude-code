_TAX_MULTIPLIERS: dict[int, float] = {
    1: 1.08,
    2: 1.15,
}


def calculate_total(items: list[dict[str, object]], discount: float | None = None) -> float:
    total = sum(
        item["val"] * _TAX_MULTIPLIERS.get(item["type"], 1.0)
        for item in items
    )
    if discount is not None:
        total -= discount
    return total
