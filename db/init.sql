USE snippet_db;

CREATE TABLE snippets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    content TEXT,
    copy_count INT DEFAULT 0, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE snippet_tags (
    snippet_id INT,
    tag_id INT,
    FOREIGN KEY (snippet_id) REFERENCES snippets(id),
    FOREIGN KEY (tag_id) REFERENCES tags(id)
);

INSERT INTO snippets (title, content, copy_count)
VALUES
('Hello World', 'print("Hello, World!")', 0),
('Factorial Function', 'def factorial(n): return 1 if n == 0 else n * factorial(n-1)', 0);

INSERT INTO tags (name)
VALUES
('python'),
('beginner'),
('recursion');

INSERT INTO snippet_tags (snippet_id, tag_id)
VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 3);