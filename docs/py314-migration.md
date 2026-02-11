# Python 3.14 Migration Checklist

## Scope

- Service runtime on Python 3.14
- Forked `pd3f` package from private index
- No API route/payload changes in this service

## Preconditions

1. Publish modernized forked `pd3f` package to private index.
2. Verify fork removed `parsr-client` dependency path.
3. Update `[[tool.poetry.source]]` URL in `pyproject.toml`.

## Dependency workflow

```bash
poetry env use 3.14
poetry lock --regenerate
poetry install
```

Optional compatibility smoke checks:

```bash
poetry env use 3.12 && poetry lock --regenerate
poetry env use 3.13 && poetry lock --regenerate
```

## Verification

1. Static check:

```bash
python3 -m py_compile pd3f/app.py
```

2. Unit tests:

```bash
poetry run pytest
```

3. Runtime build:

```bash
./dev.sh --build
```

4. End-to-end API smoke:

- `POST /` with PDF upload
- Poll `GET /update/<id>` until `text` or `failed`
- Confirm output artifacts via `/files/<filename>`

## Rollout

1. Release forked `pd3f`.
2. Release this service image.
3. Watch error/failure rates in `/update/<id>` and service logs.

## Rollback

1. Redeploy previous service image tag.
2. Reset dependency to previous lockfile commit.
