FROM php:8.2-apache

# Copy application files
COPY index.php /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Apache will start automatically via the base image

