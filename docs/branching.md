# Branching Strategy – PokéDelivery

## Overview
This repository follows a structured branching strategy to ensure code quality,
stability, and clear separation of concerns. The strategy is designed to support
Continuous Integration (CI) and Continuous Deployment (CD) workflows.

## Main Branches

### main
- Represents the production-ready state
- Always deployable
- Protected branch
- Changes are only allowed via Pull Requests
- CI pipeline must pass before merging

### develop
- Integration branch for features
- Used for testing and validation
- Protected branch
- Pull Requests required for all changes

## Supporting Branches

### feature/*
- Used for developing new features or changes
- Always created from `develop`
- Example:
  - `feature/pokemon-endpoint`
  - `feature/docs-branching`
- Merged back into `develop` via Pull Request

### hotfix/*
- Used for critical fixes
- Created from `main`
- Merged back into `main` and `develop`

## Rules & Quality Gates
- No direct commits to `main` or `develop`
- At least one code review is required
- CI pipeline must succeed before merging
- All changes are traceable via Pull Requests

## Tooling
- Git for version control
- GitHub for repository hosting and Pull Requests
- Jenkins for CI/CD