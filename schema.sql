-- Создание базы данных Туризм
CREATE DATABASE IF NOT EXISTS Tourism 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE Tourism;

-- 1. Таблица стран (справочник)
CREATE TABLE Countries (
    CountryID INT AUTO_INCREMENT PRIMARY KEY,
    CountryName VARCHAR(100) NOT NULL,
    VisaRequired BOOLEAN DEFAULT FALSE,
    Climate VARCHAR(50),
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Таблица типов туров (справочник)
CREATE TABLE TourTypes (
    TourTypeID INT AUTO_INCREMENT PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL,
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Таблица клиентов (справочник)
CREATE TABLE Clients (
    ClientID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20) NOT NULL,
    PassportNumber VARCHAR(20) NOT NULL,
    BirthDate DATE,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Таблица услуг (справочник)
CREATE TABLE Services (
    ServiceID INT AUTO_INCREMENT PRIMARY KEY,
    ServiceName VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE
);

-- 5. Таблица заказов (переменная информация)
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    ClientID INT NOT NULL,
    TourTypeID INT NOT NULL,
    CountryID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    PersonsCount INT NOT NULL DEFAULT 1,
    TotalPrice DECIMAL(10,2) NOT NULL,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('pending', 'confirmed', 'paid', 'completed', 'cancelled') DEFAULT 'pending',
    
    -- Внешние ключи
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (TourTypeID) REFERENCES TourTypes(TourTypeID),
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID),
    
    -- Проверки целостности
    CHECK (EndDate > StartDate),
    CHECK (PersonsCount > 0)
);

-- Таблица связи заказов и услуг (многие ко многим)
CREATE TABLE OrderServices (
    OrderID INT NOT NULL,
    ServiceID INT NOT NULL,
    Quantity INT DEFAULT 1,
    Price DECIMAL(10,2) NOT NULL,
    
    PRIMARY KEY (OrderID, ServiceID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);

-- Вставка тестовых данных
INSERT INTO Countries (CountryName, VisaRequired, Climate, Description) VALUES
('Турция', FALSE, 'умеренный', 'Популярное направление для пляжного отдыха'),
('Италия', TRUE, 'умеренный', 'Страна с богатой культурой и историей'),
('Египет', TRUE, 'жаркий', 'Отличные отели и древние пирамиды'),
('Греция', TRUE, 'средиземноморский', 'Колыбель европейской цивилизации');

INSERT INTO TourTypes (TypeName, Description) VALUES
('Пляжный', 'Отдых на море с проживанием в отеле'),
('Экскурсионный', 'Познавательные туры с экскурсиями'),
('Горнолыжный', 'Отдых в горах с катанием на лыжах'),
('Гастрономический', 'Туры с дегустацией местной кухни');

INSERT INTO Clients (FirstName, LastName, Email, Phone, PassportNumber, BirthDate) VALUES
('Иван', 'Иванов', 'ivanov@example.com', '+79101234567', '1234567890', '1985-03-15'),
('Петр', 'Петров', 'petrov@example.com', '+79107654321', '0987654321', '1990-07-22'),
('Мария', 'Сидорова', 'sidorova@example.com', '+79102345678', '1122334455', '1988-12-05');

INSERT INTO Services (ServiceName, Description, Price) VALUES
('Страховка', 'Медицинская страховка на время поездки', 500.00),
('Трансфер', 'Трансфер из аэропорта в отель и обратно', 1500.00),
('Экскурсия', 'Обзорная экскурсия по городу', 2000.00),
('Виза', 'Оформление визовых документов', 3000.00);

-- Создание заказов
INSERT INTO Orders (ClientID, TourTypeID, CountryID, StartDate, EndDate, PersonsCount, TotalPrice, Status) VALUES
(1, 1, 1, '2024-06-01', '2024-06-15', 2, 100000.00, 'confirmed'),
(2, 2, 2, '2024-07-10', '2024-07-20', 1, 150000.00, 'pending');

-- Добавление услуг к заказам
INSERT INTO OrderServices (OrderID, ServiceID, Quantity, Price) VALUES
(1, 1, 2, 1000.00),
(1, 2, 1, 1500.00),
(2, 1, 1, 500.00),
(2, 3, 3, 6000.00);

-- Создание индексов для оптимизации запросов
CREATE INDEX idx_orders_dates ON Orders(StartDate, EndDate);
CREATE INDEX idx_orders_status ON Orders(Status);
CREATE INDEX idx_clients_phone ON Clients(Phone);
CREATE INDEX idx_countries_name ON Countries(CountryName);

-- Представление для просмотра детальной информации о заказах
CREATE VIEW OrderDetails AS
SELECT 
    o.OrderID,
    CONCAT(c.FirstName, ' ', c.LastName) AS ClientName,
    c.Phone AS ClientPhone,
    co.CountryName,
    tt.TypeName AS TourType,
    o.StartDate,
    o.EndDate,
    o.PersonsCount,
    o.TotalPrice,
    o.Status,
    o.OrderDate
FROM Orders o
JOIN Clients c ON o.ClientID = c.ClientID
JOIN Countries co ON o.CountryID = co.CountryID
JOIN TourTypes tt ON o.TourTypeID = tt.TourTypeID;

-- Пример запроса для получения выручки по месяцам
SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    COUNT(*) AS OrdersCount,
    SUM(TotalPrice) AS TotalRevenue
FROM Orders 
WHERE Status IN ('confirmed', 'paid', 'completed')
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;
