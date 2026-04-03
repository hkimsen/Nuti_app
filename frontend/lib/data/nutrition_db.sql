CREATE TABLE foods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    calories FLOAT NOT NULL,
    protein FLOAT,
    carbs FLOAT,
    fat FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);