"""Shared inspection helper stubs used by page-level tests."""

from pathlib import Path


def expect_file(path: Path) -> None:
    """Placeholder check that a file exists."""


def expect_dir(path: Path) -> None:
    """Placeholder check that a directory exists."""


def expect_command_succeeds(command: str) -> None:
    """Placeholder check that a command succeeds."""


def expect_symlink(path: Path) -> None:
    """Placeholder check that a symlink exists."""
