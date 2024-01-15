print(f"Programe entry point: file: {__file__}; name: {__name__}; package: {__package__}")

import sys
import importlib.machinery
import importlib.util

from os.path import dirname
from importlib.abc import MetaPathFinder



class GcryMetaPathFinder(MetaPathFinder):

    def __init__(self, package_name) -> None:
        super().__init__()
        self.package_name = package_name

    def find_spec(self, fullname, path, target=None):
        if fullname.startswith(self.package_name):
            print(f"loading module {fullname} from {__file__}")
            # use this extension-file but PyInit-function of another module:
            loader = importlib.machinery.ExtensionFileLoader(fullname, __file__)
            # loader = importlib.machinery.ExtensionFileLoader(fullname, f"{dirname(__file__)}/pygcr.cpython-311-x86_64-linux-gnu.so")
            return importlib.util.spec_from_loader(fullname, loader)

# For illustrative purposes only.
SpamMetaPathFinder = importlib.machinery.PathFinder

# Setting up a meta path finder.
# Make sure to put the finder in the proper location in the list in terms of
# priority.
sys.meta_path.append(GcryMetaPathFinder(__package__))

