# Myownlink

Myownlink is a url shortener service intended to accept a target URL, generate a public short URL, capture visit analytics, and expose a simple usage report.

The application is currently deployed at [`myownl.ink`](https://myownl.ink).

## Dependencies

- Ruby 3.4.9
- Rails 8.1.3
- Bundler / RubyGems
- PostgreSQL 18, or Docker for the local Postgres container

The app uses the default Rails 8 stack with PostgreSQL, Propshaft, Importmap, Turbo, Stimulus, Tailwind CSS, Puma, Solid Cache, Solid Queue, and Solid Cable.

## Guide

Install Ruby 3.4.9 first, then install the project dependencies:

```sh
bundle install
```

Prepare the local database:

```sh
docker compose -f docker-compose.local.yml up -d postgres
bin/rails db:prepare
bin/rails db:migrate
```

Start the development server:

```sh
bin/dev
```

The app will be available at:

```text
http://localhost:3000
```

`bin/dev` runs the Rails server and the Tailwind CSS watcher through `Procfile.dev`.

## Configuration

This project uses PostgreSQL by default. For local development, `docker-compose.local.yml` starts a Postgres container with these defaults:

```text
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=myownlink
POSTGRES_PASSWORD=password
POSTGRES_DB=myownlink_development
POSTGRES_TEST_DB=myownlink_test
```

Production deployment requires similar configs, a valid Rails master key, `APP_HOST` and `RAILS_ENV=production`:

```sh
RAILS_ENV=production
POSTGRES_HOST=db.production_host.com
POSTGRES_PORT=5432
POSTGRES_USER=myownlink
POSTGRES_PASSWORD=production_password
POSTGRES_DB=myownlink_production
APP_HOST=myownl.ink
RAILS_MASTER_KEY=your_master_key
```

Optional production settings:

```text
RAILS_LOG_LEVEL=info
RAILS_MAX_THREADS=5
POSTGRES_CACHE_DB=myownlink_production_cache
POSTGRES_QUEUE_DB=myownlink_production_queue
POSTGRES_CABLE_DB=myownlink_production_cable
```

Configure separate Solid Cache, Solid Queue, and Solid Cable databases only if the deployment uses separate databases for those roles.

### Docker Compose Files

| File | Purpose |
| --- | --- |
| `docker-compose.local.yml` | Starts the development PostgreSQL database used by `bin/rails db:prepare` and `bin/dev`. |
| `docker-compose.test.yml` | Starts the test PostgreSQL database used by `bin/rails test` and `bin/rails test:system`. |

## Testing

Before running the test, make sure to have your testing database up and running. This can be done as such:

```sh
docker compose -f docker-compose.test.yml up -d postgres --wait
```

For a first run, or after schema changes, prepare the test database:

```sh
bin/rails db:test:prepare
```

Run the Rails test suite:

```sh
bin/rails test
```

Run system tests:

```sh
bin/rails test:system
```

Run the full local CI script:

```sh
bin/ci
```

The CI script runs setup, RuboCop, bundler-audit, importmap audit, Brakeman, Rails tests, and seed validation.

Tests default to a single worker locally, mainly due to pg segfaults. To opt into parallel test workers:

```sh
PARALLEL_WORKERS=4 bin/rails test
```

> Note: if you want a fresh run of the test with a new test database, you can do `docker compose -f docker-compose.test.yml down -v` to remove the volume associated.

## Common Commands

```sh
bin/rails db:prepare
bin/rails db:test:prepare
bin/rails test
bin/rails test:system
bin/rubocop
bin/brakeman --quiet
bin/ci
```

## Deployment

Currently the full stack of the application is hosted on [render.com](https://render.com), which includes:

- The Rails application
- The PostgreSQL database

The application will be deployed automatically when code is pushed to the `main` branch.

Database migrations are not assumed to run automatically. If the deployment platform does not run migrations as part of its deploy command, run:

```sh
bin/rails db:migrate
```

## Documentation

- Assignment requirements: `docs/REQUIREMENTS.md`
- Solution wiki: `docs/WIKI.md`
