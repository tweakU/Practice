Да, вы правы. 👍 Я сбился с нашего исходного плана и **самовольно переименовал Шаг 27**. Не будем подменять этапы.

Возвращаемся к правильному плану:

# 🔐 Шаг 27 — инструкция для вас как администратора

Здесь мы **не меняем код бота и не вносим новую функциональность**.

Цель — дать вам понятную эксплуатационную инструкцию: что делать, если бот работает нормально, что проверять при проблемах и какие команды использовать.

С учётом того, что вы не программист, я предлагаю сделать Шаг 27 в формате **«шпаргалка администратора»**.

## 27.1. Как проверить, работает ли бот

```bash
sudo systemctl status tg_bot --no-pager
```

Нормальный результат:

```text
Active: active (running)
```

Если бот работает — **ничего перезапускать не нужно**.

---

## 27.2. Как перезапустить бота

Если мы, например, внесли изменения в Python-код:

```bash
sudo systemctl restart tg_bot
```

Затем обязательно:

```bash
sudo systemctl status tg_bot --no-pager
```

И посмотреть последние сообщения:

```bash
sudo journalctl -u tg_bot -n 30 --no-pager
```

---

## 27.3. Как посмотреть лог бота

Последние 50 строк:

```bash
sudo journalctl -u tg_bot -n 50 --no-pager
```

Следить за логом в реальном времени:

```bash
sudo journalctl -u tg_bot -f
```

Выход из режима просмотра:

```text
Ctrl+C
```

### Важно

Не надо пугаться сообщений вроде:

```text
Update id=... is handled
```

Это нормальная работа aiogram.

А вот:

```text
ERROR
Traceback
Exception
```

уже требует внимания.

---

# 27.4. Как проверить PostgreSQL

```bash
sudo systemctl status postgresql --no-pager
```

Быстрая проверка:

```bash
sudo -u postgres pg_isready -d tg_bot
```

Нормальный результат:

```text
accepting connections
```

---

# 27.5. Как посмотреть пользователей

```bash
sudo -u postgres psql -d tg_bot
```

Внутри PostgreSQL:

```sql
SELECT
    telegram_id,
    username,
    confirmation_code,
    phrase_id,
    created_at,
    updated_at
FROM users
ORDER BY confirmation_code;
```

Выйти:

```text
\q
```

---

# 27.6. Как посмотреть, какой код будет выдан следующим

```bash
sudo -u postgres psql -d tg_bot -c "
SELECT * FROM counter;
"
```

Например:

```text
 id | next_code
----+----------
  1 | 7005
```

Это означает:

> следующий **новый** пользователь получит код `7005`.

Повторный `/start` существующего пользователя этот счётчик не увеличивает.

---

# 27.7. Как посмотреть количество пользователей

```bash
sudo -u postgres psql -d tg_bot -c "
SELECT COUNT(*) AS users_count
FROM users;
"
```

---

# 27.8. Как проверить резервные копии

```bash
sudo ls -lh /var/backups/tg_bot/
```

Проверить timer:

```bash
systemctl list-timers tg_bot_backup.timer
```

Принудительно сделать backup:

```bash
sudo systemctl start tg_bot_backup.service
```

После этого:

```bash
sudo ls -lh /var/backups/tg_bot/
```

---

# 27.9. Если бот внезапно перестал работать

**Не начинайте сразу менять Python-код.**

Действуем строго по порядку.

### Шаг A

```bash
sudo systemctl status tg_bot --no-pager
```

### Шаг B

```bash
sudo journalctl -u tg_bot -n 100 --no-pager
```

### Шаг C

Проверяем PostgreSQL:

```bash
sudo -u postgres pg_isready -d tg_bot
```

### Шаг D

Если PostgreSQL работает, пробуем:

```bash
sudo systemctl restart tg_bot
```

### Шаг E

Снова:

```bash
sudo systemctl status tg_bot --no-pager
```

---

# 27.10. Если сервер перезагрузился

Ничего вручную запускать не требуется.

У нас бот настроен через systemd:

```text
tg_bot.service
```

и он должен автоматически стартовать после загрузки системы.

Проверка:

```bash
systemctl is-enabled tg_bot
```

Ожидаем:

```text
enabled
```

Для backup timer:

```bash
systemctl is-enabled tg_bot_backup.timer
```

Ожидаем:

```text
enabled
```

---

# 27.11. Что категорически не делать

Это важная часть инструкции.

### ❌ Не удалять вручную записи из `users`

Не делать:

```sql
DELETE FROM users ...
```

если мы специально не договорились, зачем это нужно.

### ❌ Не менять `counter` вручную

Не делать:

```sql
UPDATE counter SET next_code = ...
```

без понимания последствий.

### ❌ Не менять `phrase_id` пользователей вручную

У нас действует правило:

```text
один пользователь → одна фраза
```

### ❌ Не запускать второй экземпляр бота вручную

Например не надо делать:

```bash
python /opt/tg_bot/app/main.py
```

параллельно с systemd.

Иначе могут появиться проблемы с двумя polling-процессами.

### ❌ Не менять `.env`

Особенно:

```text
BOT_TOKEN
DATABASE_PASSWORD
```

без необходимости.

---

# 27.12. Самое важное правило администратора

**Если что-то непонятно — сначала смотрим состояние, потом что-либо меняем.**

Запомните три команды:

```bash
sudo systemctl status tg_bot --no-pager
```

```bash
sudo journalctl -u tg_bot -n 50 --no-pager
```

```bash
sudo -u postgres pg_isready -d tg_bot
```

Этого уже достаточно для диагностики огромной доли типичных проблем.

---

# 27.13. Наша «аварийная карточка»

Можете даже сохранить себе этот блок:

```text
БОТ НЕ РАБОТАЕТ
================

1. Проверить:
sudo systemctl status tg_bot --no-pager

2. Посмотреть ошибку:
sudo journalctl -u tg_bot -n 100 --no-pager

3. Проверить PostgreSQL:
sudo -u postgres pg_isready -d tg_bot

4. Если PostgreSQL работает:
sudo systemctl restart tg_bot

5. Проверить снова:
sudo systemctl status tg_bot --no-pager
```

И **не удалять базу, не переустанавливать Python и не менять конфигурацию наугад**.

---
