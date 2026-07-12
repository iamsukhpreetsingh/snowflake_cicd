-- objects/V1.1.6__test_validation_fail.sql
CREATE TABLE IF NOT EXISTS IDENTIFIER('{{ db }}.DEMO.TEST_FAIL_2') (
    id NUMBER
);
DROP TABLE IF EXISTS IDENTIFIER('{{ db }}.DEMO.TEST_FAIL_2');
