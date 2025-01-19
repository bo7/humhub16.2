# HumHub Docker Setup

Docker setup for HumHub 1.16.2 with Gallery module.

## Requirements
- Docker
- Docker Compose

## Installation
1. Clone this repository
2. Copy `.env.example` to `.env` and adjust values
3. Run `docker-compose up -d`
4. Access HumHub at http://localhost:3418

## Configuration
- NGINX runs on port 3418
- MariaDB 10.11 for database
- PHP 8.2-FPM for processing

## Volume Management
Docker volumes are used to persist data:
- `humhub_data`: Contains HumHub application files
- `db_data`: Contains MariaDB database files

### Backup volumes:
# Backup database
docker-compose exec db mysqldump -u root -p humhub > backup.sql

# Backup volumes
docker run --rm -v humhub_data:/source -v $(pwd)/backup:/backup alpine tar czf /backup/humhub_data.tar.gz -C /source .
docker run --rm -v db_data:/source -v $(pwd)/backup:/backup alpine tar czf /backup/db_data.tar.gz -C /source .

### Restore volumes:
# Restore database
cat backup.sql | docker-compose exec -T db mysql -u root -p humhub

# Restore volumes
docker run --rm -v humhub_data:/target -v $(pwd)/backup:/backup alpine tar xzf /backup/humhub_data.tar.gz -C /target
docker run --rm -v db_data:/target -v $(pwd)/backup:/backup alpine tar xzf /backup/db_data.tar.gz -C /target

## External NGINX Setup

### 1. Install NGINX if not already installed:
sudo apt update
sudo apt install nginx

### 2. Create NGINX configuration:
sudo nano /etc/nginx/sites-available/thailand.zybo.cloud

Add this configuration:
server {
    listen 80;
    listen [::]:80;
    server_name thailand.zybo.cloud;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name thailand.zybo.cloud;

    # SSL configuration (will be added by Certbot)
    ssl_certificate /etc/letsencrypt/live/thailand.zybo.cloud/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/thailand.zybo.cloud/privkey.pem;

    # SSL optimization
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Proxy settings
    location / {
        proxy_pass http://127.0.0.1:3418;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Upload size
    client_max_body_size 64M;
}

### 3. Enable the site:
sudo ln -s /etc/nginx/sites-available/thailand.zybo.cloud /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default  # Remove default site if exists
sudo nginx -t  # Test configuration
sudo systemctl reload nginx

## SSL Certificate Setup

### 1. Install Certbot:
sudo apt update
sudo apt install certbot python3-certbot-nginx

### 2. Obtain and install SSL certificate:
sudo certbot --nginx -d thailand.zybo.cloud

### 3. Verify auto-renewal:
sudo certbot renew --dry-run

### 4. Check certificate status:
sudo certbot certificates

## Modules
- Gallery module pre-installed

## Maintenance
- View logs: `docker-compose logs -f`
- Check container status: `docker-compose ps`
- Restart services: `docker-compose restart`
- Update containers: `docker-compose pull && docker-compose up -d`
- Check NGINX status: `sudo systemctl status nginx`
- Check SSL expiry: `sudo certbot certificates`

## Troubleshooting
- Check NGINX error logs: `sudo tail -f /var/log/nginx/error.log`
- Check NGINX access logs: `sudo tail -f /var/log/nginx/access.log`
- Test NGINX config: `sudo nginx -t`
- Check SSL certificate: `sudo certbot certificates`
- Check Docker logs: `docker-compose logs -f` 