INSERT INTO "Clients" ("Name", "Lastname", "PersonalCode", "BirthDate", "addressStreet", "addressCity", "addressZipCode")
VALUES
    ('John', 'Doe', '1234567890', '2005-01-15', '123 Elm St', 'Metropolis', '12345'),
    ('Jane', 'Smith', '9876543210', '1990-08-05', '456 Oak St', 'Gotham', '67890'),
    ('Alice', 'Johnson', '1122334455', '1995-03-25', '789 Pine St', 'Starling City', '11223'),
    ('Bob', 'Brown', '2233445566', '1980-06-10', '321 Maple St', 'Central City', '44556');

INSERT INTO "Cars" ("Brand", "VIN", "Model", "Type", "PricePerDay")
VALUES
    ('Toyota', 'VIN123456', 'Corolla', 'Sedan', 50.00),
    ('BMW', 'VIN987654', 'X5', 'SUV', 100.00),
    ('Porsche', 'VIN543210', '911 Carrera', 'Sport', 300.00),
    ('Mazda', 'VIN112233', 'MX-5', 'Sport', 150.00),
    ('Ford', 'VIN445566', 'Focus', 'Hatchback', 40.00);

INSERT INTO "Orders" ("ClientId", "OrderDateStart", "OrderDateEnd", "Price", "Status")
VALUES
    (1, '2024-01-01', '2024-01-05', 200.00, 'active'),
    (2, '2024-01-10', '2024-01-12', 300.00, 'unactive'),
    (3, '2024-01-15', '2024-01-20', 600.00, 'active'),
    (4, '2024-02-01', '2024-02-05', 150.00, 'unactive');

INSERT INTO "OrderCars" ("OrderId", "CarId", "TotalPrice")
VALUES
    (1, 1, 200.00),
    (2, 2, 300.00),
    (3, 3, 600.00),
    (4, 4, 150.00);

-- test age restriction
-- INSERT INTO "Orders" ("ClientId", "OrderDateStart", "OrderDateEnd", "Price", "Status")
-- VALUES
--     (1, '2024-01-05', '2024-01-15', 500.00, 'active');
-- 
-- INSERT INTO "OrderCars" ("OrderId", "CarId", "TotalPrice")
-- VALUES
--     (5, 3, 300.00);

-- test overlapping order dates
INSERT INTO "Orders" ("ClientId", "OrderDateStart", "OrderDateEnd", "Price", "Status")
VALUES
    (1, '2024-04-04', '2024-04-5', 300.00, 'active'),
    (2, '2024-04-01', '2024-01-10', 500.00, 'active');

INSERT INTO "OrderCars" ("OrderId", "CarId", "TotalPrice")
VALUES
    (5, 2, 300.00),
    (6, 2, 500.00);

INSERT INTO "Orders" ("ClientId", "OrderDateStart", "OrderDateEnd", "Price", "Status")
VALUES
    (1, '2024-06-01', '2024-06-5', 300.00, 'active'),
    (2, '2024-06-02', '2024-01-3', 500.00, 'active');

INSERT INTO "OrderCars" ("OrderId", "CarId", "TotalPrice")
VALUES
    (7, 2, 300.00),
    (8, 2, 500.00);