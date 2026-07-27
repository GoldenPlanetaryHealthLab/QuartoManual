"""ERA5 project path helper stubs."""

from pathlib import Path


def raw_dir(project_root: Path) -> Path:
    """Return placeholder path for raw ERA5 data."""
    return project_root / 'data' / 'raw'


def interim_dir(project_root: Path) -> Path:
    """Return placeholder path for interim ERA5 data."""
    return project_root / 'data' / 'interim'


def processed_dir(project_root: Path) -> Path:
    """Return placeholder path for processed ERA5 data."""
    return project_root / 'data' / 'processed'
