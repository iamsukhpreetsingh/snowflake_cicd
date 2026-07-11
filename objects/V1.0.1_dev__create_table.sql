CREATE TABLE IF NOT EXISTS IDENTIFIER('$DB_NAME' || '.FROM_DEV.CUSTOMERS') (
    customer_id     NUMBER(38,0)   NOT NULL,
    customer_name   VARCHAR(200)   NOT NULL,
    phone           VARCHAR(255),
    signup_date     DATE           NOT NULL,
    is_active       BOOLEAN        DEFAULT TRUE,
    created_at      TIMESTAMP_NTZ  DEFAULT CURRENT_TIMESTAMP()
);