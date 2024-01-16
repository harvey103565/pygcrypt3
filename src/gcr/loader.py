print(f"Programe loader >>> file: {__file__}; name: {__name__}; package: {__package__}")

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
            # use this extension-file but PyInit-function of another module:
            loader = importlib.machinery.ExtensionFileLoader(fullname, __file__)
            return importlib.util.spec_from_loader(fullname, loader)

# For illustrative purposes only.
SpamMetaPathFinder = importlib.machinery.PathFinder

# Setting up a meta path finder.
# Make sure to put the finder in the proper location in the list in terms of
# priority.
sys.meta_path.append(GcryMetaPathFinder(__package__))

