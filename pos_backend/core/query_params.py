"""Lectura de parámetros de query string."""

TRUE_VALUES = frozenset({"1", "true", "True"})


def is_true(value: str | None) -> bool:
    """Interpreta un parámetro booleano; ausente o cualquier otro valor es False."""
    return value in TRUE_VALUES
