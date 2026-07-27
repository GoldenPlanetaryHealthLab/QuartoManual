from pathlib import Path


def test_scaffold_paths_exist() -> None:
    """Placeholder scaffold checks for expected files and directories."""
    template_dir = Path(__file__).resolve().parents[1]
    assert (template_dir / 'pages/03_pipeline_skeleton.qmd').exists()
    assert (template_dir / 'lib/era5_paths.py').exists()
