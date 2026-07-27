"""Project state discovery data structures for manual pages."""

from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Project:
    """Placeholder project contract discovered from filesystem state."""

    root: Path = field(default_factory=lambda: Path.cwd())

    @classmethod
    def discover(cls) -> "Project":
        """Discover and return the current project state."""
        return cls()
