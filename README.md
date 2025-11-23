# MESQUITA-PERSONAL-DOCKER-WEBSITES

## How to set up env secrets for MESQUITA-CONTACT-API

Set up `.env` file with secrets here, it will be passed via `docker-compose.yml` to the `mesquita-contact-api` service.

```env
TELEGRAM_BOT_TOKEN=your-telegram-bot-token
TELEGRAM_CHAT_ID=your-telegram-chat-id
SMTP_EMAIL_HOST=your-email-host
SMTP_EMAIL_PORT=your-email-host-port
SMTP_EMAIL_USER=your-email-user
SMTP_EMAIL_PASSWORD=your-email-password
FORM_RECIPIENT_EMAIL=your-form-recipient-email
CORS_ORIGINS=mydomain1.com,mydomain2.com,mydomain3.com
```

If CORS_ORIGINS are not provided it will accept requests from all domains.