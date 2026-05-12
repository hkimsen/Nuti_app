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

INSERT INTO foods (name, category, calories, protein, carbs, fat)
VALUES
-- CARB
('Cơm trắng', 'carb', 130, 2.7, 28, 0.3),
('Gạo lứt sống', 'carb', 345, 7.5, 72.8, 2.7),
('Khoai lang tươi', 'carb', 119, 0.8, 28.5, 0.1),
('Khoai tây tươi', 'carb', 77, 2, 17.5, 0.1),
('Bún tươi', 'carb', 110, 1.7, 25.7, 0),
('Phở tươi', 'carb', 123, 2.4, 27.3, 0.1),
('Bánh mì trắng', 'carb', 265, 9, 49, 3.2),
('Yến mạch', 'carb', 389, 16.9, 66.3, 6.9),
('Ngô nếp luộc', 'carb', 167, 5, 35, 1),

-- PROTEIN
('Ức gà sống', 'protein', 110, 23, 0, 1.2),
('Thịt bò nạc', 'protein', 118, 21, 0, 3.8),
('Thịt lợn nạc', 'protein', 139, 19, 0, 7),
('Trứng gà (1 quả)', 'protein', 155, 13, 1.1, 11),
('Cá hồi tươi', 'protein', 202, 20, 0, 13),
('Cá rô phi', 'protein', 96, 20, 0, 1.7),
('Tôm tươi', 'protein', 99, 24, 0, 0.3),
('Đậu phụ', 'protein', 76, 8.1, 1.9, 4.8),
('Thịt vịt nạc', 'protein', 132, 18, 0, 6),

-- VEGETABLE
('Bông cải xanh', 'vegetable', 34, 2.8, 6.6, 0.4),
('Bắp cải', 'vegetable', 25, 1.3, 5.8, 0.1),
('Rau muống', 'vegetable', 18, 3.2, 2.1, 0.1),
('Rau mồng tơi', 'vegetable', 14, 2, 1.4, 0.1),
('Cà chua', 'vegetable', 18, 0.9, 3.9, 0.2),
('Dưa chuột', 'vegetable', 15, 0.7, 3.6, 0.1),
('Cà rốt', 'vegetable', 41, 0.9, 9.6, 0.2),

-- FRUIT
('Chuối tiêu', 'fruit', 89, 1.1, 22.8, 0.3),
('Táo tây', 'fruit', 52, 0.3, 13.8, 0.2),
('Bơ sáp', 'fruit', 160, 2, 8.5, 14.7),
('Ổi', 'fruit', 68, 2.6, 14.3, 1),
('Cam', 'fruit', 47, 0.9, 11.8, 0.1);