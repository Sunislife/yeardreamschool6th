-- CREATE: 테이블 생성
CREATE TABLE IF NOT EXISTS users (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    name      TEXT    NOT NULL,
    email     TEXT    UNIQUE NOT NULL,
    age       INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- CREATE: 데이터 삽입
INSERT INTO users (name, email, age) VALUES ('홍길동', 'hong@example.com', 30);
INSERT INTO users (name, email, age) VALUES ('김철수', 'kim@example.com', 25);

-- READ: 조회
SELECT * FROM users;                          -- 전체 조회

-- DELETE: 삭제
DELETE FROM users;  -- 전체 삭제 (주의)