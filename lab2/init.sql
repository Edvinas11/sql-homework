CREATE TABLE "Clients" (
    "Id" INTEGER GENERATED BY DEFAULT AS IDENTITY,
    "Name" TEXT NOT NULL,
    "Lastname" TEXT NOT NULL,
    "PersonalCode" TEXT NOT NULL,
    "BirthDate" DATE NOT NULL,
    "addressStreet" TEXT NOT NULL,
    "addressCity" TEXT NOT NULL,
    "addressZipCode" TEXT NOT NULL,
    CONSTRAINT "PK_Clients" PRIMARY KEY ("Id")
);

CREATE TABLE "Orders" (
    "OrderId" INTEGER GENERATED BY DEFAULT AS IDENTITY,
    "ClientId" INTEGER NOT NULL,
    "OrderDateStart" DATE NOT NULL DEFAULT CURRENT_DATE,
    "OrderDateEnd" DATE,
    "Price" DECIMAL(10, 2) CHECK ("Price" > 0),
    "Status" TEXT DEFAULT 'active',
    CONSTRAINT "PK_Orders" PRIMARY KEY ("OrderId"),
    CONSTRAINT "FK_Orders_Clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES "Clients" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Cars" (
    "Id" INTEGER GENERATED BY DEFAULT AS IDENTITY,
    "Brand" TEXT NOT NULL,
    "VIN" TEXT NOT NULL,
    "Model" TEXT NOT NULL,
    "Type" TEXT NOT NULL,
    "PricePerDay" DECIMAL(10, 2) NOT NULL,
    CONSTRAINT "PK_Cars" PRIMARY KEY ("Id")
);

CREATE TABLE "OrderCars" (
    "Id" INTEGER GENERATED BY DEFAULT AS IDENTITY,
    "OrderId" INTEGER NOT NULL,
    "CarId" INTEGER NOT NULL,
    "TotalPrice" DECIMAL(10, 2) NOT NULL,
    CONSTRAINT "PK_OrderCars" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_OrderCars_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES "Orders" ("OrderId") ON DELETE CASCADE,
    CONSTRAINT "FK_OrderCars_Cars_CarId" FOREIGN KEY ("CarId") REFERENCES "Cars" ("Id") ON DELETE CASCADE
);

CREATE UNIQUE INDEX "IX_Clients_PersonalCode" ON "Clients" ("PersonalCode");
CREATE UNIQUE INDEX "IX_Cars_VIN" ON "Cars" ("VIN");
CREATE INDEX "IX_Orders_ClientId" ON "Orders" ("ClientId");
CREATE INDEX "IX_OrderCars_OrderId" ON "OrderCars" ("OrderId");
CREATE INDEX "IX_OrderCars_CarsId" ON "OrderCars" ("CarId");

CREATE VIEW "ActiveOrders" AS
SELECT
    ord."OrderId",
    ord."ClientId",
    cli."Name" AS "ClientName",
    cli."Lastname" AS "ClientLastName",
    ord."OrderDateStart",
    ord."OrderDateEnd",
    ord."Status",
    ord."Price"
FROM "Orders" ord
INNER JOIN "Clients" cli
ON ord."ClientId" = cli."Id"
WHERE ord."Status" = 'active';

CREATE VIEW "CustomerAges" AS
SELECT
    "Id" AS "ClientId",
    "Name",
    "Lastname",
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, "BirthDate")) AS "Age"
FROM "Clients" cli;

CREATE MATERIALIZED VIEW "MaterializedCarRevenue" AS
SELECT
    car."Id" as "CarId",
    car."Brand",
    car."Model",
    COUNT(orc."Id") AS "TimesRented",
    SUM(orc."TotalPrice") AS "TotalRevenue"
FROM "Cars" car
LEFT JOIN "OrderCars" orc
ON car."Id" = orc."CarId"
GROUP BY car."Id",
    car."Brand",
    car."Model"
ORDER BY "TotalRevenue" DESC;

CREATE OR REPLACE FUNCTION refresh_materialized_car_revenue()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW "MaterializedCarRevenue";
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_refresh_materialized_car_revenue()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM refresh_materialized_car_revenue();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_sport_car_rental_age()
RETURNS TRIGGER AS $$
DECLARE
    customer_age INTEGER;
    car_type TEXT;
BEGIN
    SELECT "Type" INTO car_type
    FROM "Cars"
    WHERE "Id" = NEW."CarId";

    SELECT "Age" INTO customer_age
    FROM "CustomerAges"
    WHERE "ClientId" = (
        SELECT "ClientId"
        FROM "Orders"
        WHERE "OrderId" = NEW."OrderId"
    );

    IF car_type = 'Sport' AND customer_age < 22 THEN 
        RAISE EXCEPTION 'Sport cars cn only be rented by customers over 22 years old.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_sport_car_rental_age
BEFORE INSERT OR UPDATE ON "OrderCars"
FOR EACH ROW
EXECUTE FUNCTION check_sport_car_rental_age();

CREATE OR REPLACE FUNCTION prevent_overlapping_rentals()
RETURNS TRIGGER AS $$
DECLARE
    new_start DATE;
    new_end DATE;
BEGIN
    SELECT "OrderDateStart", "OrderDateEnd"
    INTO new_start, new_end
    FROM "Orders"
    WHERE "OrderId" = NEW."OrderId";

    IF EXISTS (
        SELECT 1
        FROM "Orders" ord
        INNER JOIN "OrderCars" orc
        ON ord."OrderId" = orc."OrderId"
        WHERE orc."CarId" = NEW."CarId"
        AND (
            -- new orderio pradzia startuoja tarp egzistuojancio
            new_start BETWEEN ord."OrderDateStart" AND ord."OrderDateEnd"
            OR
            -- new orderio pabaiga startuoja tarp egzistuojancio
            new_end BETWEEN ord."OrderDateStart" AND ord."OrderDateEnd"
            OR
            -- naujas orderis visiskai apima esama orderi
            ord."OrderDateStart" BETWEEN new_start AND new_end
        )
    ) THEN
        RAISE EXCEPTION 'Car is already rented for the selected period.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_prevent_overlapping_rentals
BEFORE INSERT OR UPDATE ON "OrderCars"
FOR EACH ROW
EXECUTE FUNCTION prevent_overlapping_rentals();