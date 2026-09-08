"""Add official SDK-generated platform files, never overwrite the app sources."""
from pathlib import Path
import shutil
import sys
root = Path(__file__).resolve().parents[1]
source = Path(sys.argv[1]).resolve()
for platform in ('android', 'ios', 'web'):
    for path in (source / platform).rglob('*'):
        if not path.is_file():
            continue
        relative = path.relative_to(source)
        # Keep our sole application entry activity, not the generated duplicate.
        if path.name == 'MainActivity.kt':
            continue
        destination = root / relative
        if not destination.exists():
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, destination)
# Flutter's Android build also needs the Gradle wrapper at the project root.
# Copy generated wrapper files only when the repository does not already have them.
for relative in ('gradlew', 'gradlew.bat', 'gradle/wrapper/gradle-wrapper.jar',
                 'gradle/wrapper/gradle-wrapper.properties'):
    path = source / relative
    destination = root / relative
    if path.exists() and not destination.exists():
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, destination)
metadata = root / '.metadata'
if not metadata.exists() and (source / '.metadata').exists():
    shutil.copy2(source / '.metadata', metadata)
print('Official platform wrappers and iOS/Web scaffolds added; custom files preserved.')
