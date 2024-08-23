---- Создаётся через role
-- CREATE DATABASE IF NOT EXISTS logs;

CREATE TABLE IF NOT EXISTS logs.file_log(
    message String
)
ENGINE = MergeTree()
ORDER BY tuple()
;
