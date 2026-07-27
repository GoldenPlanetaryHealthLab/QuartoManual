"""Spack recipe helper stubs."""

from pathlib import Path


def write_spack_yaml(path: Path) -> None:
    """Write a placeholder spack.yaml file."""


def inspect_spack_yaml(path: Path) -> dict:
    """Inspect a placeholder spack.yaml file."""
    return {"path": str(path)}
