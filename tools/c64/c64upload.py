from os import environ
from argparse import ArgumentParser
from ftplib import FTP
from pathlib import PosixPath, Path
from urllib.parse import quote
import requests

C64HOST = environ.get("C64HOST")


if __name__ == "__main__":
    parser = ArgumentParser(description="Deploy a D64 image to a C64 via C64HOST")
    parser.add_argument("source", help="Path to the D64 image file to deploy")
    parser.add_argument(
        "--host",
        default=C64HOST,
        help="C64 host command (default from C64HOST env variable)",
    )
    parser.add_argument(
        "--mount", action="store_true", help="Mount the program after upload"
    )
    parser.add_argument(
        "--run", action="store_true", help="Run the program after upload"
    )
    args = parser.parse_args()

    if not args.host:
        print("Error: Missing host.")
        exit(1)

    source_path = Path(args.source)
    target_path = PosixPath("Temp") / source_path.name

    print(f"Deploying {source_path} to C64 host {args.host}...")

    ftp = FTP(args.host)

    ftp.login()

    with open(source_path, "rb") as f:
        ftp.storbinary(f"STOR {target_path}", f)

    ftp.dir("Temp")
    ftp.quit()
    print("Deployment complete.")

    if args.mount:
        print("Mounting program on C64...")

        requests.put(
            f"http://{args.host}/v1/drives/a:mount?image={quote(str(target_path))}"
        )

    if args.run:
        print("Running program on C64...")

        requests.put(
            f"http://{args.host}/v1/runners:run_prg?file={quote(str(target_path))}"
        )
