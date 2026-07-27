"""Platform contract dataclass helper stubs."""

from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class PlatformContract:
    """Placeholder platform contract values."""

    project_name: str = ""


@dataclass
class RuntimePaths:
    """Placeholder runtime path bundle."""

    work: Path = field(default_factory=Path)
    tmp: Path = field(default_factory=Path)


@dataclass
class ContainerBindPlan:
    """Placeholder container bind plan."""

    binds: list[str] = field(default_factory=list)
