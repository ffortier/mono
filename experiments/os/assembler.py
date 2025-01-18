from argparse import ArgumentParser, Namespace
from pathlib import Path
from io import BufferedReader, BufferedWriter


def parse_args():
    parser = ArgumentParser()
    parser.add_argument("-o", "--output", required=True)
    parser.add_argument("files", nargs="+")
    return parser.parse_args()


def transfer(input: Path, output: BufferedWriter):
    with open(input, "rb") as stream:
        while True:
            chunk = stream.read(4096)
            if len(chunk) == 0:
                break
            output.write(chunk)


def main(args: Namespace):
    files = [Path(input_file) for input_file in args.files]

    [boot] = filter(lambda file: file.name == "boot.bin", files)

    assert boot.stat().st_size == 512

    files.remove(boot)

    with open(args.output, "wb") as output:
        transfer(boot, output)

        for file in files:
            transfer(file, output)

        assert output.tell() < 512 * 101

        output.write(bytes([0] * (512 * 101 - output.tell())))


if __name__ == "__main__":
    main(parse_args())
