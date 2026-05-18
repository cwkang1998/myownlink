# Myownlink

Myownlink is a url shortener service intended to accept a target URL, generate a public short URL, capture visit analytics, and expose a simple usage report.

## Dependencies

- Ruby 3.4.9
- Rails 8.1.3
- Bundler / RubyGems
- Docker

The app uses the default Rails 8 stack with Propshaft, Importmap, Turbo, Stimulus, Tailwind CSS, Puma, Solid Cache, Solid Queue, and Solid Cable.

## Guide

Install Ruby 3.4.9 first, then install the project dependencies:

```sh
bundle install
```

Prepare the database:

```sh
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

This project uses SQLite by default. Development and test databases are stored under `storage/`.

No external services are required for local development at this stage. Production deployment requires a valid Rails master key:

```sh
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

