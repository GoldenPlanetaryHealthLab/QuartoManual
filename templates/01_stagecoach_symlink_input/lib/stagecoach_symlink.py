"""Stagecoach input symlink workflow helper stubs."""

from pathlib import Path


def resolve_stagecoach_input(input_registry: Path, input_name: str) -> Path:
    """Resolve a registered input path for a named input."""
    return input_registry / input_name


def create_input_symlink(source: Path, target: Path) -> None:
    """Create a symlink from target to source."""


def validate_symlink_target(path: Path) -> bool:
    """Validate that a symlink target is present."""
    return False
