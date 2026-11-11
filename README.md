## Этап 6. SSH и SCP — безопасная передача файлов

Для безопасной передачи файлов проекта на удалённый сервер используется протокол SSH (Secure Shell). Он обеспечивает шифрование соединения и позволяет выполнять удалённые команды и передавать файлы.

### 1. Генерация SSH-ключей

Для создания пары ключей используется команда:

```bash
ssh-keygen -t ed25519 -C "devops-deploy"
```

В результате создаются два файла:

- `id_ed25519` — приватный ключ. Хранится только на локальном компьютере и не передаётся другим пользователям.
- `id_ed25519.pub` — публичный ключ. Используется для настройки авторизации на сервере.

### 2. Копирование публичного ключа

Для добавления публичного ключа на удалённый сервер используется:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@SERVER_IP
```

В Windows PowerShell, если команда `ssh-copy-id` отсутствует, можно использовать:

```powershell
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | ssh user@SERVER_IP "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

После настройки проверяется подключение:

```bash
ssh user@SERVER_IP
```

### 3. Передача файлов проекта через SCP

Для начала создаётся архив проекта. Из него исключаются Git-история, логи и файлы захвата сетевого трафика:

```bash
tar --exclude=.git --exclude='*.log' --exclude='*.pcap' --exclude='*.pcapng' -czf infra-monitoring-project.tar.gz .
```

Передача архива на сервер выполняется командой:

```bash
scp infra-monitoring-project.tar.gz user@SERVER_IP:/tmp/
```

На сервере архив распаковывается:

```bash
ssh user@SERVER_IP
mkdir -p ~/infra-monitoring-project
tar -xzf /tmp/infra-monitoring-project.tar.gz -C ~/infra-monitoring-project
```

### 4. Альтернативный способ: TAR + SSH

Архив можно передать напрямую через SSH без предварительного сохранения на диске:

```bash
tar --exclude=.git --exclude='*.log' --exclude='*.pcap' --exclude='*.pcapng' -czf - . | ssh user@SERVER_IP "mkdir -p ~/infra-monitoring-project && tar -xzf - -C ~/infra-monitoring-project"
```

### 5. Запуск проекта на удалённом сервере

После передачи файлов выполняется подключение к серверу:

```bash
ssh user@SERVER_IP
```

Запуск проекта:

```bash
cd ~/infra-monitoring-project
docker compose up -d
```

Проверка состояния контейнеров и доступности сервиса:

```bash
docker ps
curl http://localhost:80
```

Ожидаемый ответ:

```text
Monitoring Service Active
```

Таким образом, SSH используется для безопасной авторизации и удалённого управления сервером, а SCP и TAR позволяют передавать файлы проекта по защищённому соединению.