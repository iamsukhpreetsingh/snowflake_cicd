CREATE TABLE IF NOT EXISTS IDENTIFIER('{{ db }}.EXTERNAL_STAGING.PRODUCTS') (
    product_id       NUMBER IDENTITY(1,1),
    product_name     VARCHAR(200) NOT NULL,
    product_category VARCHAR(100),
    product_brand    VARCHAR(100),
    unit_price       NUMBER(10,2) NOT NULL,
    stock_quantity   NUMBER(10,0) DEFAULT 0,
    is_available     BOOLEAN DEFAULT TRUE,
    created_at       TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
