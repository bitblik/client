# Stage 1: Build the Flutter web application
# Use an official Flutter image that includes the SDK
FROM instrumentisto/flutter:3.35.3 AS build

# Set working directory INSIDE the client directory structure for the build
WORKDIR /app

# Copy client pubspec files and get dependencies first to leverage Docker cache
#COPY pubspec.* ./

# Copy the rest of the client source code
# Since WORKDIR is /app, copy current dir (.) which contains client code
COPY . ./

RUN flutter pub get

# Ensure web support is enabled (might be redundant if already enabled)
RUN flutter config --enable-web

# Build the web application
RUN flutter build web --release --no-web-resources-cdn

# Stage 2: Serve the built web application using Nginx
FROM nginx:stable-alpine

# Copy the built web application from the build stage to Nginx html directory
# The output directory for flutter build web is build/web relative to WORKDIR
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy the default config.js (can be overridden by mounting a volume or using entrypoint)
COPY --from=build /app/web/config.js /usr/share/nginx/html/config.js

# Copy the custom Nginx configuration (from the client directory)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint script for generating config.js from environment variables
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose port 80
EXPOSE 80

# Use entrypoint script to generate config.js from env vars, then start Nginx
ENTRYPOINT ["/docker-entrypoint.sh"]
