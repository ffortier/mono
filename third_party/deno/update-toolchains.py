import os
import ast
from ast import NodeVisitor, NodeTransformer
from pathlib import Path
from dataclasses import dataclass
from subprocess import run, PIPE


@dataclass
class HttpArchive:
    name: str
    urls: list[str]
    sha256: str


class HttpArchiveVisitor(NodeVisitor):
    archives: list[HttpArchive]

    def __init__(self):
        super().__init__()
        self.archives = []

    def visit_Call(self, node):
        if not isinstance(node.func, ast.Name):
            return
        if node.func.id != "http_archive":
            return

        kwargs = {
            kw.arg: eval(ast.unparse(kw.value))
            for kw in node.keywords
            if kw.arg in ["name", "sha256", "urls"]
        }

        self.archives.append(HttpArchive(**kwargs))


class DenoRepoTransformer(NodeTransformer):
    value: ast.Expr

    def __init__(self, value: ast.Expr):
        super().__init__()
        self.value = value

    def visit_Assign(self, node):
        if len(node.targets) != 1:
            return node
        if not isinstance(node.targets[0], ast.Name):
            return node
        if node.targets[0].id != "_DENO_REPOS":
            return node

        node.value = self.value
        return node


def workspace_directory() -> Path:
    wd = os.getenv("BUILD_WORKSPACE_DIRECTORY")
    assert wd, "Expected to run with bazel"
    return Path(wd)


def find_http_archived(module_file: Path) -> list[HttpArchive]:
    with open(module_file) as f:
        module = ast.parse(f.read())

    visitor = HttpArchiveVisitor()
    visitor.visit(module)

    return visitor.archives


def to_ast(value: any):
    if isinstance(value, dict):
        return ast.Dict(
            keys=[ast.Constant(k) for k in value.keys()],
            values=[to_ast(v) for v in value.values()],
        )
    if isinstance(value, list):
        return ast.List(elts=[to_ast(v) for v in value])

    assert isinstance(value, str)

    return ast.Constant(value)


def update_extension(extension_file: Path, http_archives: list[HttpArchive]):
    deno_repos = {a.name: {"urls": a.urls, "sha256": a.sha256} for a in http_archives}

    with open(extension_file) as f:
        extension = ast.parse(f.read())

    transformer = DenoRepoTransformer(to_ast(deno_repos))

    transformer.visit(extension)

    code = ast.unparse(extension)

    with open(extension_file, "w") as f:
        f.write(code)


def buildifier(extension_file: Path):
    run(
        args=[os.getenv("BUILDIFIER", "buildifier"), extension_file],
        stderr=PIPE,
        stdout=PIPE,
    ).check_returncode()


def main():
    wd = workspace_directory()

    module_file = wd.joinpath("third_party", "deno", "toolchains.MODULE.bazel")
    extension_file = wd.joinpath("third_party", "deno", "extension.bzl")

    http_archives = find_http_archived(module_file)
    update_extension(extension_file, http_archives)
    buildifier(extension_file)


if __name__ == "__main__":
    main()
