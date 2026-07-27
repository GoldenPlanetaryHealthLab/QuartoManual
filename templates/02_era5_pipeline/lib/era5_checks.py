"""ERA5 readiness check helper stubs."""

from pathlib import Path


def check_download_files(data_dir: Path) -> bool:
    """Check placeholder download file readiness."""
    return data_dir.exists()


def check_expected_variables() -> bool:
    """Check placeholder variable expectations."""
    return True


def check_pipeline_readiness() -> bool:
    """Check placeholder pipeline readiness status."""
    return False
