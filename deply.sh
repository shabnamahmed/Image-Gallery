#!/bin/bash

# Step 1: Build the Flutter web app
flutter build web

# Step 2: Deploy to GitHub Pages using gh-pages
npx gh-pages -d build/web
