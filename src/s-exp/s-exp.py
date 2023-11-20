


from typing import Iterator


class SExpression():


    def __init__(self, *args: list[bytes], **kwargs: dict[bytes, bytes]) -> None:
        pass

    def __iter__(self) -> Iterator:
        pass

    def __next__(self) -> str:
        pass

    def __repr__(self) -> str:
        """
            export the string form of the S-Expression
        """
        pass

    def __len__(self) -> int:
        """
            return the item count number of the S-Expression, in the list perspect of view (including car)
        """
        pass

    def __getattr__(self, name: str=None) -> tuple[bytes]:
        """
            S-Express has a basic form (car . cdr)
            use object.car or object.cdr to get corresponding value
        """
        pass

    def __setattr__(self) -> tuple[bytes]:
        """
            S-Express has a basic form (car . cdr)
            use object.car = 'some-name' or object.cdr = 'some-value' to set its value
        """
        pass

    def __getitem__(self, key: str=None) -> tuple[bytes]:
        """
            use object['car-name'] to get cdr
        """
        pass

    def __setitem__(self) -> tuple[bytes]:
        """
            use object['car-name'] = 'cdr-value' to set cdr value
        """
        pass

    def size(self) -> int:
        """
            return the S-Expression's memory footprint in bytes
        """
