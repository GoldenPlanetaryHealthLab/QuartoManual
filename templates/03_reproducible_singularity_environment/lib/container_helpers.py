"""Container command and bind helper stubs."""

from pathlib import Path


def build_container_command() -> list[str]:
    """Build a placeholder container command."""
    return []


def launch_container() -> int:
    """Launch a placeholder container command."""
    return 0


def verify_runtime_binds(work: Path, tmp: Path) -> bool:
    """Verify placeholder runtime bind paths."""
    return work.exists() and tmp.exists()
