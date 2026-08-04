# ==========================================
# STAGE 1: Build Angular Code using Node.js
# ==========================================
FROM node:20-alpine AS build

# Set working directory inside the container
WORKDIR /app

# Copy package files first to optimize layer caching
COPY package*.json ./

# Install npm dependencies inside container
RUN npm install

# Copy rest of the project source code
COPY . .

# Build the production static files
RUN npm run build -- --configuration=production

# ==========================================
# STAGE 2: Serve using Lightweight Nginx
# ==========================================
FROM nginx:alpine

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled static files from Stage 1 to Nginx default public path
COPY --from=build /app/dist/angular-docker-app/browser /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx web server inside container
CMD ["nginx", "-g", "daemon off;"]

#tests
