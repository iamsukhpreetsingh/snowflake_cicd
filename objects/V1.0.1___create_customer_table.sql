CREATE TABLE IF NOT EXISTS IDENTIFIER('{{ db }}.DEMO.CUSTOMERS') (
    customer_id     NUMBER(38,0)   NOT NULL,
    customer_name   VARCHAR(200)   NOT NULL,
    customer_category  VARCHAR(200),
    phone_no           VARCHAR(255),
    signup_date     DATE           NOT NULL,
    is_active       BOOLEAN        DEFAULT TRUE,
    created_at      TIMESTAMP_NTZ  DEFAULT CURRENT_TIMESTAMP()
);