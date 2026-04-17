# Learning Content / Topics

## Description

Structured educational content (topics, lessons, explanations).

## Requirements

* Subject → Topic hierarchy
* Downloadable content packs
* Offline access
* Expandable sections

## Endpoints

* `GET /subjects`
* `GET /subjects/{id}/topics`
* `GET /topics/{id}`
* `GET /content-pack/{id}`

## Tools

* PostgreSQL (metadata)
* Cloudflare R2 (content storage)
