# Flutter 웹 애플리케이션 서버 배포 가이드

이 문서는 Flutter 웹 애플리케이션을 `/eutilinks/` 경로에서 실행하고 파일들을 `www/html/eutilinks/` 디렉토리에 배치하는 방법에 대해 설명합니다.

## 1. Flutter 웹 빌드 설정

### 1.1 base href 설정

Flutter 웹 애플리케이션을 특정 경로(예: `/eutilinks/`)에서 실행하려면 `web/index.html` 파일의 base href를 설정해야 합니다. 기본적으로 `index.html` 파일에는 다음과 같은 코드가 있습니다:

```html
<base href="$FLUTTER_BASE_HREF">
```

이 플레이스홀더는 빌드 시 `--base-href` 옵션으로 지정한 값으로 대체됩니다.

### 1.2 웹 애플리케이션 빌드

다음 명령어를 사용하여 웹 애플리케이션을 빌드합니다:

```bash
flutter build web --base-href=/eutilinks/ --release
```

이 명령어는 다음과 같은 작업을 수행합니다:
- `--base-href=/eutilinks/` 옵션은 `$FLUTTER_BASE_HREF` 플레이스홀더를 `/eutilinks/`로 대체합니다.
- `--release` 옵션은 최적화된 릴리스 빌드를 생성합니다.

빌드가 완료되면 `build/web/` 디렉토리에 웹 애플리케이션 파일들이 생성됩니다.

## 2. 웹 서버 배포 방법

### 2.1 파일 복사 방법

빌드된 파일들을 웹 서버의 `www/html/eutilinks/` 디렉토리로 복사하는 방법은 다음과 같습니다:

#### 2.1.1 서버에서 직접 복사

서버에 직접 접속하여 다음 명령어를 실행합니다:

```bash
# 디렉토리 생성
mkdir -p /var/www/html/eutilinks

# 파일 복사
cp -r /path/to/your/build/web/* /var/www/html/eutilinks/
```

#### 2.1.2 SCP를 사용한 원격 복사

로컬 컴퓨터에서 다음 명령어를 사용하여 빌드된 파일들을 서버로 전송합니다:

```bash
scp -r build/web/* username@your-server:/var/www/html/eutilinks/
```

#### 2.1.3 FTP/SFTP를 사용한 파일 전송

FileZilla와 같은 FTP 클라이언트를 사용하여 다음과 같이 파일을 전송합니다:

1. FTP 클라이언트를 열고 서버에 연결합니다.
2. 로컬 디렉토리를 `build/web/`로 이동합니다.
3. 원격 디렉토리를 `/var/www/html/eutilinks/`로 이동합니다.
4. 모든 파일을 선택하여 업로드합니다.

### 2.2 웹 서버 설정

#### 2.2.1 Apache 웹 서버 설정

Apache 웹 서버를 사용하는 경우, 다음과 같은 설정을 추가합니다:

1. `/etc/apache2/sites-available/` 디렉토리에 설정 파일을 생성하거나 수정합니다:

```apache
Alias "/eutilinks" "/var/www/html/eutilinks"
<Directory "/var/www/html/eutilinks">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
```

2. 설정을 활성화하고 Apache를 재시작합니다:

```bash
sudo a2ensite your-config-file
sudo systemctl restart apache2
```

#### 2.2.2 Nginx 웹 서버 설정

Nginx 웹 서버를 사용하는 경우, 다음과 같은 설정을 추가합니다:

1. `/etc/nginx/sites-available/` 디렉토리에 설정 파일을 생성하거나 수정합니다:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /eutilinks/ {
        alias /var/www/html/eutilinks/;
        try_files $uri $uri/ /eutilinks/index.html;
    }
}
```

2. 설정을 활성화하고 Nginx를 재시작합니다:

```bash
sudo ln -s /etc/nginx/sites-available/your-config-file /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

### 2.3 URL 리다이렉션 및 라우팅 처리

Flutter 웹 애플리케이션에서 라우팅을 사용하는 경우, 서버에서 모든 요청을 `index.html`로 리다이렉션하도록 설정해야 합니다. 이를 위해 다음과 같은 설정을 추가할 수 있습니다:

#### 2.3.1 Apache에서 .htaccess 설정

`/var/www/html/eutilinks/` 디렉토리에 `.htaccess` 파일을 생성하고 다음 내용을 추가합니다:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /eutilinks/
    RewriteRule ^index\.html$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /eutilinks/index.html [L]
</IfModule>
```

#### 2.3.2 Nginx에서 리다이렉션 설정

Nginx 설정 파일에 다음 내용을 추가합니다:

```nginx
location /eutilinks/ {
    alias /var/www/html/eutilinks/;
    try_files $uri $uri/ /eutilinks/index.html;
}
```

## 3. 배포 후 확인

배포가 완료되면 웹 브라우저에서 다음 URL로 접속하여 애플리케이션이 정상적으로 실행되는지 확인합니다:

```
http://your-domain.com/eutilinks/
```

## 4. 문제 해결

### 4.1 404 오류가 발생하는 경우

- 웹 서버 설정이 올바른지 확인합니다.
- 파일 권한이 적절하게 설정되어 있는지 확인합니다:
  ```bash
  sudo chown -R www-data:www-data /var/www/html/eutilinks
  sudo chmod -R 755 /var/www/html/eutilinks
  ```

### 4.2 리소스 로딩 오류가 발생하는 경우

- 개발자 도구의 콘솔을 확인하여 오류 메시지를 확인합니다.
- `base href` 설정이 올바른지 확인합니다.
- 상대 경로가 올바르게 사용되고 있는지 확인합니다.

### 4.3 라우팅 오류가 발생하는 경우

- 서버 설정에서 모든 요청이 `index.html`로 리다이렉션되는지 확인합니다.
- Flutter 라우터 설정에서 `base` 경로가 올바르게 설정되어 있는지 확인합니다.

## 5. 추가 참고 사항

### 5.1 자동화된 배포 스크립트

배포 과정을 자동화하기 위해 다음과 같은 스크립트를 사용할 수 있습니다:

```bash
#!/bin/bash

# Flutter 웹 빌드
flutter build web --base-href=/eutilinks/ --release

# 서버에 파일 복사
rsync -avz --delete build/web/ username@your-server:/var/www/html/eutilinks/

# 권한 설정 (SSH를 통해 실행)
ssh username@your-server "sudo chown -R www-data:www-data /var/www/html/eutilinks && sudo chmod -R 755 /var/www/html/eutilinks"

echo "배포가 완료되었습니다."
```

### 5.2 HTTPS 설정

보안을 강화하기 위해 HTTPS를 설정하는 것이 좋습니다. Let's Encrypt를 사용하여 무료 SSL 인증서를 발급받을 수 있습니다:

```bash
sudo apt-get install certbot
sudo certbot --apache -d your-domain.com
```

또는 Nginx를 사용하는 경우:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 5.3 캐싱 설정

성능 향상을 위해 정적 파일에 대한 캐싱을 설정할 수 있습니다:

#### Apache에서 캐싱 설정

```apache
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType application/font-woff "access plus 1 year"
    ExpiresByType application/font-woff2 "access plus 1 year"
    ExpiresByType application/x-font-ttf "access plus 1 year"
</IfModule>
```

#### Nginx에서 캐싱 설정

```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf)$ {
    expires 1y;
    add_header Cache-Control "public, max-age=31536000";
}
``` 