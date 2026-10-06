import pytest

from tests.factories import LAS_AMERICAS, VILLA_LIBERTAD, BranchFactory


@pytest.fixture(autouse=True)
def branches(db: None) -> None:
    """Negocio con dos sucursales activas, el escenario por defecto de estos tests."""
    BranchFactory(code=VILLA_LIBERTAD)
    BranchFactory(code=LAS_AMERICAS)
