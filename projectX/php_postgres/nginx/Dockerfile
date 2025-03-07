FROM nginx:latest

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Create the directory if it doesn't exist
RUN mkdir -p /var/www/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy project files into the container
COPY . /var/www/html

# Set correct permissions and ownership
RUN chmod -R 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
