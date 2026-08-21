from pathlib import Path

from PIL import Image


SOURCE = Path("/home/ubuntu/webdev-static-assets/nightfall-launcher-icon.png")
TARGETS = [
    Path("/home/ubuntu/nightfall-blood-hunt/assets/images/icon.png"),
    Path("/home/ubuntu/nightfall-blood-hunt/assets/images/splash-icon.png"),
    Path("/home/ubuntu/nightfall-blood-hunt/assets/images/favicon.png"),
    Path("/home/ubuntu/nightfall-blood-hunt/assets/images/android-icon-foreground.png"),
]


def main() -> None:
    with Image.open(SOURCE) as source:
        optimized = source.convert("RGBA").resize((512, 512), Image.Resampling.LANCZOS)
        for target in TARGETS:
            optimized.save(target, format="PNG", optimize=True, compress_level=9)
            print(f"{target.name}: {target.stat().st_size} bytes")


if __name__ == "__main__":
    main()
