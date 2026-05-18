# Myownlink

Myownlink is a url shortener service intended to accept a target URL, generate a public short URL, capture visit analytics, and expose a simple usage report.

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

Prepare the database:

```sh
docker compose -f docker-compose.local.yml up -d postgres
bin/rails db:prepare
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

Production deployment requires `DATABASE_URL` and a valid Rails master key:

```sh
DATABASE_URL=postgres://user:password@host:5432/myownlink_production
RAILS_MASTER_KEY=your_master_key
```

## Testing

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

## Deployment

> TBD

## Documentation

- Assignment requirements: `docs/REQUIREMENTS.md`
- Solution wiki: `docs/WIKI.md`
