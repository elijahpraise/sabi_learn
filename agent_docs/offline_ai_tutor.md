# Offline AI Tutor

## Description

Chat-based AI tutor that explains topics, simplifies concepts, and answers questions.

## Requirements

* Chat interface
* Precomputed explanations (offline)
* API fallback when online
* Prompt variations (simplify, examples, quiz)
* Store chat history locally

## Endpoints

* `POST /ai/ask`
* `POST /ai/explain-topic`

## Tools

* OpenAI API (online mode)
* Local storage (SQLite)
* Precomputed content packs (R2)
