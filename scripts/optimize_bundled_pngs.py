from pathlib import Path

from PIL import Image


TARGETS = (
    (Path("assets/images/campaign/bloodwake-captain-portrait-bundled.png"), (720, 1280)),
    (Path("assets/images/harbor/brasswake-harbor-highres-bundled.png"), (1280, 720)),
)


def optimize_png(path: Path, maximum_size: tuple[int, int]) -> None:
    before = path.stat().st_size
    with Image.open(path) as source:
        image = source.convert("RGB")
        image.thumbnail(maximum_size, Image.Resampling.LANCZOS)
        image = image.quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.FLOYDSTEINBERG)
        image.save(path, format="PNG", optimize=True, compress_level=9)
        print(f"{path}: {image.width}x{image.height}, {before} -> {path.stat().st_size} bytes")


for target, maximum_size in TARGETS:
    optimize_png(target, maximum_size)
