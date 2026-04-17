# Authentication & User Management

## Description

Handles user sign-up, login, identity, and profile data. Supports offline-first usage with optional sync.

## Requirements

* Email/phone authentication
* Offline guest mode
* Sync user data when online
* Profile (class level, subjects)

## Endpoints

* `POST /auth/register`
* `POST /auth/login`
* `GET /auth/me`
* `PATCH /auth/profile`

## Tools

* Django + DRF
* Firebase Auth (optional)
* PostgreSQL
