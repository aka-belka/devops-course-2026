# Конфигурация виртуальной машины devops-vm

## 1. Параметры машины
- Объём памяти: 2048 МБ
- Количество ядер: 2
- Объём диска: 25 ГБ

## 2. Сетевые интерфейсы
- Адаптер 1: NAT (10.0.2.15) — доступ в интернет.
- Адаптер 2: Host-only (192.168.56.101) — доступ с хостовой системы.

## 3. Правило проброса портов
- Порт хоста: 2222 -> Порт гостя: 2222 (SSH)

## 4. Учётные записи
- `student` — базовая учётная запись.
- `devops` — рабочая учётная запись, группа `sudo`, вход по ключу.

## 5. Служба SSH
- Порт: 2222
- Файл конфигурации: `/etc/ssh/sshd_config.d/99-hardening.conf`
- Директивы: `PermitRootLogin no`, `PasswordAuthentication no`, `MaxAuthTries 3`, `AllowUsers devops`.

## 6. Правила межсетевого экрана
- Политики: `deny incoming`, `allow outgoing`.
- Разрешено: 2222/tcp (LIMIT), 80/tcp, 443/tcp.

## 7. Снимки состояния
- `01-clean-install`
- `02-keys-configured`
- `03-ssh-hardened`
- `03-ufw-configured`

## 8. Веб-сервер
- Устанавливаемый пакет: `nginx`
- Путь к конфигурации ресурса: `/etc/nginx/sites-available/devops-site`
- Каталог ресурса: `/var/www/devops-site` (владелец `devops:devops`, права 755)
- Пути к сертификату и ключу: `/etc/ssl/certs/devops.crt` (644), `/etc/ssl/private/devops.key` (600 root)
- Команда формирования сертификата: `sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/devops.key -out /etc/ssl/certs/devops.crt -subj "/CN=devops.local" -addext "subjectAltName=DNS:devops.local"`
- Срок действия: 365 дней.

## 9. Контейнеризация
- Способ установки Docker Engine: официальный репозиторий Docker (не docker.io).
- Участники группы `docker`: `devops`.
- Расположение проекта на сервере: `/home/devops/app`.
- Расположение файла `.env` и его права: `/home/devops/app/.env` (права 600).
- Публикуемые порты и адреса: `127.0.0.1:5000` (только локально).
- Именованные тома: `app_db_data`.
- Конфигурация обратного прокси-сервера: Nginx проксирует запросы с `https://devops.local/app/` на `http://127.0.0.1:5000/`.
