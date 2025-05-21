# Stage 1: Build the Flutter web application
# Use an official Flutter image that includes the SDK
FROM instrumentisto/flutter:3.32.0 AS build

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
# Note: Ensure the base URL in ApiService is correct for the containerized environment
# or use build arguments/environment variables to configure it.
# Example using build-arg:
# ARG API_BASE_URL=http://localhost:8080
# RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL
RUN flutter build web --release --no-web-resources-cdn

# Stage 2: Serve the built web application using Nginx
FROM nginx:stable-alpine

# Copy the built web application from the build stage to Nginx html directory
# The output directory for flutter build web is build/web relative to WORKDIR
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy the custom Nginx configuration (from the client directory)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
