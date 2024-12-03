DROP TRIGGER IF EXISTS trigger_prevent_overlapping_rentals ON "OrderCars";
DROP TRIGGER IF EXISTS trigger_check_sport_car_rental_age ON "OrderCars";

DROP FUNCTION IF EXISTS prevent_overlapping_rentals();
DROP FUNCTION IF EXISTS check_sport_car_rental_age();

DROP MATERIALIZED VIEW IF EXISTS "MaterializedCarRevenue";

DROP VIEW IF EXISTS "CustomerAges";
DROP VIEW IF EXISTS "ActiveOrders";

DROP TABLE IF EXISTS "OrderCars";
DROP TABLE IF EXISTS "Orders";
DROP TABLE IF EXISTS "Cars";
DROP TABLE IF EXISTS "Clients";

DROP INDEX IF EXISTS "IX_Cars_VIN";
DROP INDEX IF EXISTS "IX_Orders_ClientId";
DROP INDEX IF EXISTS "IX_OrderCars_CarId";
DROP INDEX IF EXISTS "IX_OrderCars_OrderId";
