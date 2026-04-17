# Sync System

## Description

Synchronizes local data with the backend when internet is available.

## Requirements

* Conflict resolution
* Incremental sync
* Retry mechanism

## Endpoints

* `POST /sync/push`
* `GET /sync/pull`

## Tools

* Django backend
* Optional Firestore
