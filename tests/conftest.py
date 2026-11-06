"""Shared pytest setup.

Tests marked `data` need files in the top-level data/ folder. CI never has them, so it deselects
those tests with `-m "not slow and not data"`. Locally, they are skipped when data/ holds nothing
but its README.
"""

from pathlib import Path

import pytest

DATA_DIR = Path(__file__).resolve().parents[1] / "data"


def _have_data() -> bool:
    if not DATA_DIR.is_dir():
        return False
    return any(p.name != "README.md" for p in DATA_DIR.iterdir())


def pytest_collection_modifyitems(config, items):
    if _have_data():
        return
    skip = pytest.mark.skip(reason="no files in data/; run the data pipeline first")
    for item in items:
        if "data" in item.keywords:
            item.add_marker(skip)
