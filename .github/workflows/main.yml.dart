# This is a basic workflow to help you get started with Actions
name: CI

# Controls when the workflow will run
on:
# Triggers the workflow on push or pull request events but only for the main branch
push:
branches: [main, release, develop]
paths-ignore:
- '**/README.md'
pull_request:
branches: [main, release, develop]

# Allows you to run this workflow manually from the Actions tab
workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
# This workflow contains a single job called "build"
build:
name: flutter build
# The type of runner that the job will run on
runs-on: ubuntu-latest
steps:
- uses: actions/checkout@v2
- uses: actions/setup-java@v1
with:
java-version: '12.x'
- uses: subosito/flutter-action@v1
- run: flutter pub get
- run: flutter analyze
- run: flutter test