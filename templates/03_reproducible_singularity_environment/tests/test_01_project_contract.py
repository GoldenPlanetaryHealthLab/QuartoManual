from pathlib import Path


def test_scaffold_paths_exist() -> None:
    """Placeholder scaffold checks for expected files and directories."""
    template_dir = Path(__file__).resolve().parents[1]
    assert (template_dir / 'pages/01_project_contract.qmd').exists()
    assert (template_dir / 'lib/platform_contract.py').exists()
