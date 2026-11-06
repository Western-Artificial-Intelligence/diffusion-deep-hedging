"""Checks that the environment is set up and the package imports.

If these fail on your machine, your setup is the problem, not your code. Fix it before Task 1.
"""

import importlib

import pytest

import dhedge

SUBPACKAGES = [
    "simulators",
    "agents",
    "evaluation",
    "baselines",
    "gate",
    "marketdata",
    "theory",
]


def test_version_is_set():
    assert isinstance(dhedge.__version__, str)
    assert dhedge.__version__


@pytest.mark.parametrize("name", SUBPACKAGES)
def test_subpackage_imports(name):
    importlib.import_module(f"dhedge.{name}")


@pytest.mark.parametrize("module", ["numpy", "scipy", "pandas", "matplotlib", "yaml", "torch"])
def test_core_dependency_imports(module):
    importlib.import_module(module)
