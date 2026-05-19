# Running the Legacy Rails Reference App

This Docker setup is for UI/UX and domain archaeology only. The app is Rails 4.2 on Ruby 2.2 and should not be exposed publicly or treated as production software.

## Start

Build the image:

```sh
docker compose build
```

Prepare the database:

```sh
docker compose run --rm web bundle exec rake db:schema:load db:seed
```

Start the app:

```sh
docker compose up web
```

Open:

```text
http://localhost:3000
```

## Notes

- The web app is exposed on port `3000`.
- PostgreSQL is exposed on host port `5433` to avoid colliding with local Postgres.
- Solr is exposed on host port `8983`, but search may need extra legacy tuning.
- Docker uses `linux/amd64` because old Ruby images may not support Apple Silicon natively.
- The Docker image copies `config/database.docker.yml` and `config/sunspot.docker.yml` over the legacy configs inside the image only.

## Stop and Reset

Stop containers:

```sh
docker compose down
```

Remove generated data:

```sh
docker compose down --volumes
```

