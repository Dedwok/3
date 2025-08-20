-- Создание базы данных
CREATE DATABASE IF NOT EXISTS TourismDB 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE TourismDB;

-- 1. Таблица стран (справочник)
CREATE TABLE Countries (
    CountryID INT AUTO_INCREMENT PRIMARY KEY,
    CountryName VARCHAR(100) NOT NULL,
    VisaRequired BOOLEAN DEFAULT FALSE,
    Climate VARCHAR(50),
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_country_name (CountryName)
) ENGINE=InnoDB;

-- 2. Таблица типов туров (справочник)
CREATE TABLE TourTypes (
    TourTypeID INT AUTO_INCREMENT PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL,
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_type_name (TypeName)
) ENGINE=InnoDB;

-- 3. Таблица клиентов (справочник)
CREATE TABLE Clients (
    ClientID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    PassportNumber VARCHAR(20) NOT NULL,
    BirthDate DATE,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    UNIQUE INDEX idx_passport (PassportNumber),
    INDEX idx_client_name (LastName, FirstName)
) ENGINE=InnoDB;

-- 4. Таблица услуг (справочник)
CREATE TABLE Services (
    ServiceID INT AUTO_INCREMENT PRIMARY KEY,
    ServiceName VARCHAR(100) NOT NULL,
    Description TEXT,
    BasePrice DECIMAL(10, 2) NOT NULL,
    DurationDays INT DEFAULT 1,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_service_name (ServiceName)
) ENGINE=InnoDB;

-- 5. Таблица заказов (переменная информация)
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    ClientID INT NOT NULL,
    TourTypeID INT NOT NULL,
    CountryID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    PersonsCount INT NOT NULL DEFAULT 1,
    TotalPrice DECIMAL(10, 2) NOT NULL,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('pending', 'confirmed', 'paid', 'completed', 'cancelled') DEFAULT 'pending',
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Внешние ключи
    FOREIGN KEY (ClientID) 
        REFERENCES Clients(ClientID) 
        ON UPDATE CASCADE,
        
    FOREIGN KEY (TourTypeID) 
        REFERENCES TourTypes(TourTypeID) 
        ON UPDATE CASCADE,
        
    FOREIGN KEY (CountryID) 
        REFERENCES Countries(CountryID) 
        ON UPDATE CASCADE,
    
    -- Индексы для ускорения запросов
    INDEX idx_order_dates (StartDate, EndDate),
    INDEX idx_order_status (Status),
    INDEX idx_order_client (ClientID),
    
    -- Проверки целостности данных
    CHECK (EndDate > StartDate),
    CHECK (PersonsCount > 0),
    CHECK (TotalPrice >= 0)
) ENGINE=InnoDB;

-- 6. Таблица связи заказов и услуг (многие ко многим)
CREATE TABLE OrderServices (
    OrderServiceID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ServiceID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    ActualPrice DECIMAL(10, 2) NOT NULL,
    Notes TEXT,
    
    -- Внешние ключи
    FOREIGN KEY (OrderID) 
        REFERENCES Orders(OrderID) 
        ON DELETE CASCADE,
        
    FOREIGN KEY (ServiceID) 
        REFERENCES Services(ServiceID) 
        ON UPDATE CASCADE,
    
    -- Уникальный индекс
    UNIQUE INDEX idx_order_service (OrderID, ServiceID),
    
    -- Проверки
    CHECK (Quantity > 0),
    CHECK (ActualPrice >= 0)
) ENGINE=InnoDB;

-- 7. Таблица сотрудников (дополнительный справочник)
CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Position VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    HireDate DATE NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_employee_name (LastName, FirstName)
) ENGINE=InnoDB;

-- 8. Таблица назначений менеджеров на заказы
CREATE TABLE OrderManagers (
    OrderManagerID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    EmployeeID INT NOT NULL,
    AssignmentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Notes TEXT,
    
    -- Внешние ключи
    FOREIGN KEY (OrderID) 
        REFERENCES Orders(OrderID) 
        ON DELETE CASCADE,
        
    FOREIGN KEY (EmployeeID) 
        REFERENCES Employees(EmployeeID) 
        ON UPDATE CASCADE,
    
    UNIQUE INDEX idx_order_manager (OrderID)
) ENGINE=InnoDB;

-- Вставка тестовых данных
INSERT INTO Countries (CountryName, VisaRequired, Climate, Description) VALUES
('Турция', FALSE, 'умеренный', 'Популярное направление для пляжного отдыха'),
('Италия', TRUE, 'умеренный', 'Страна с богатой культурой и историей'),
('Египет', TRUE, 'жаркий', 'Отличные отели и древние пирамиды'),
('Греция', TRUE, 'средиземноморский', 'Колыбель европейской цивилизации'),
('ОАЭ', TRUE, 'пустынный', 'Современные мегаполисы и роскошные отели');

INSERT INTO TourTypes (TypeName, Description) VALUES
('Пляжный', 'Отдых на море с проживанием в отеле'),
('Экскурсионный', 'Познавательные туры с экскурсиями'),
('Горнолыжный', 'Отдых в горах с катанием на лыжах'),
('Гастрономический', 'Туры с дегустацией местной кухни'),
('Активный', 'Походы, рафтинг, дайвинг и другие активности');

INSERT INTO Services (ServiceName, Description, BasePrice, DurationDays) VALUES
('Страховка', 'Медицинская страховка на время поездки', 500.00, 1),
('Трансфер', 'Трансфер из аэропорта в отель и обратно', 1500.00, 1),
('Экскурсия', 'Обзорная экскурсия по городу', 2000.00, 1),
('Виза', 'Оформление визовых документов', 3000.00, 7),
('SPA-процедуры', 'Комплекс SPA-процедур в отеле', 5000.00, 1);

INSERT INTO Clients (FirstName, LastName, Email, Phone, PassportNumber, BirthDate) VALUES
('Иван', 'Иванов', 'ivanov@example.com', '+79101234567', '1234567890', '1985-03-15'),
('Петр', 'Петров', 'petrov@example.com', '+79107654321', '0987654321', '1990-07-22'),
('Мария', 'Сидорова', 'sidorova@example.com', '+79102345678', '1122334455', '1988-12-05'),
('Анна', 'Кузнецова', 'kuznetsova@example.com', '+79103456789', '5566778899', '1992-04-18');

INSERT INTO Employees (FirstName, LastName, Position, Email, Phone, HireDate) VALUES
('Ольга', 'Смирнова', 'Менеджер по туризму', 'smirnova@tourism.com', '+79991234567', '2020-01-15'),
('Дмитрий', 'Васильев', 'Старший менеджер', 'vasilev@tourism.com', '+79992345678', '2018-05-10'),
('Екатерина', 'Попова', 'Ассистент менеджера', 'popova@tourism.com', '+79993456789', '2021-03-20');

-- Создание представлений для удобства

-- Представление для просмотра заказов с детальной информацией
CREATE VIEW OrderDetails AS
SELECT 
    o.OrderID,
    CONCAT(c.FirstName, ' ', c.LastName) AS ClientName,
    c.Email AS ClientEmail,
    c.Phone AS ClientPhone,
    tt.TypeName AS TourType,
    co.CountryName,
    o.StartDate,
    o.EndDate,
    o.PersonsCount,
    o.TotalPrice,
    o.Status,
    o.OrderDate,
    DATEDIFF(o.EndDate, o.StartDate) AS DurationDays
FROM Orders o
JOIN Clients c ON o.ClientID = c.ClientID
JOIN TourTypes tt ON o.TourTypeID = tt.TourTypeID
JOIN Countries co ON o.CountryID = co.CountryID;

-- Представление для финансовой отчетности
CREATE VIEW FinancialReport AS
SELECT 
    YEAR(o.OrderDate) AS Year,
    MONTH(o.OrderDate) AS Month,
    COUNT(o.OrderID) AS OrdersCount,
    SUM(o.TotalPrice) AS TotalRevenue,
    AVG(o.TotalPrice) AS AverageOrderValue
FROM Orders o
WHERE o.Status IN ('confirmed', 'paid', 'completed')
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate);

-- Создание хранимых процедур

-- Процедура для создания нового заказа
DELIMITER //
CREATE PROCEDURE CreateNewOrder(
    IN p_ClientID INT,
    IN p_TourTypeID INT,
    IN p_CountryID INT,
    IN p_StartDate DATE,
    IN p_EndDate DATE,
    IN p_PersonsCount INT,
    IN p_TotalPrice DECIMAL(10,2)
)
BEGIN
    INSERT INTO Orders (
        ClientID, TourTypeID, CountryID, 
        StartDate, EndDate, PersonsCount, TotalPrice
    ) VALUES (
        p_ClientID, p_TourTypeID, p_CountryID,
        p_StartDate, p_EndDate, p_PersonsCount, p_TotalPrice
    );
    
    SELECT LAST_INSERT_ID() AS NewOrderID;
END //
DELIMITER ;

-- Процедура для обновления статуса заказа
DELIMITER //
CREATE PROCEDURE UpdateOrderStatus(
    IN p_OrderID INT,
    IN p_NewStatus VARCHAR(20)
)
BEGIN
    UPDATE Orders 
    SET Status = p_NewStatus, 
        UpdatedAt = CURRENT_TIMESTAMP
    WHERE OrderID = p_OrderID;
END //
DELIMITER ;

-- Создание триггеров

-- Триггер для автоматического обновления общей суммы при изменении услуг
DELIMITER //
CREATE TRIGGER before_order_update
BEFORE UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.TotalPrice < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TotalPrice cannot be negative';
    END IF;
END //
DELIMITER ;

-- Триггер для логирования изменений статуса заказов
CREATE TABLE OrderStatusLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    OldStatus VARCHAR(20),
    NewStatus VARCHAR(20),
    ChangeDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ChangedBy VARCHAR(100),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

DELIMITER //
CREATE TRIGGER after_order_status_update
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF OLD.Status != NEW.Status THEN
        INSERT INTO OrderStatusLog (OrderID, OldStatus, NewStatus, ChangedBy)
        VALUES (NEW.OrderID, OLD.Status, NEW.Status, CURRENT_USER());
    END IF;
END //
DELIMITER ;

-- Создание пользователей и назначение прав

CREATE USER 'tourism_manager'@'localhost' IDENTIFIED BY 'manager_password';
GRANT SELECT, INSERT, UPDATE ON TourismDB.* TO 'tourism_manager'@'localhost';

CREATE USER 'tourism_report'@'localhost' IDENTIFIED BY 'report_password';
GRANT SELECT ON TourismDB.OrderDetails TO 'tourism_report'@'localhost';
GRANT SELECT ON TourismDB.FinancialReport TO 'tourism_report'@'localhost';

CREATE USER 'tourism_admin'@'localhost' IDENTIFIED BY 'admin_password';
GRANT ALL PRIVILEGES ON TourismDB.* TO 'tourism_admin'@'localhost';

FLUSH PRIVILEGES;

-- Индексы для оптимизации производительности
CREATE INDEX idx_orders_dates ON Orders(StartDate, EndDate);
CREATE INDEX idx_clients_active ON Clients(IsActive);
CREATE INDEX idx_services_active ON Services(IsActive);
CREATE INDEX idx_orders_status_date ON Orders(Status, OrderDate);

-- Комментарии к таблицам и полям
ALTER TABLE Countries COMMENT = 'Справочник стран для туров';
ALTER TABLE Clients COMMENT = 'Справочник клиентов турагентства';
ALTER TABLE Orders COMMENT = 'Основная таблица заказов туров';
