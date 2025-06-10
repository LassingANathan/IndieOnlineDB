-- The implementation of stored procedures, and general file/folder layout, is adapted from:
-- Source URL: https://canvas.oregonstate.edu/courses/1999601/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25352968
-- Accessed 5/22/2025

USE cs340_lassingn;

-- #######################
-- DELETE OPERATIONS
-- #######################

-- DELETE game
DROP PROCEDURE IF EXISTS sp_DeleteGame;
DELIMITER //
CREATE PROCEDURE sp_DeleteGame(IN g_id INT)
BEGIN

    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- delete a game based on the gameID (M-to-M relationship deletion)
        DELETE FROM Games WHERE gameID = g_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Games for id: ', g_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- #######################
-- INSERT OPERATIONS
-- #######################

-- INSERT game
DROP PROCEDURE IF EXISTS sp_InsertGame;
DELIMITER //
CREATE PROCEDURE sp_InsertGame(IN g_name VARCHAR(45), IN g_price DECIMAL(16,2))
BEGIN

    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Insert a new game
        INSERT INTO Games (name, price) VALUES (g_name, g_price);

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('Game could not be added.');
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- INSERT saleOrder
DROP PROCEDURE IF EXISTS sp_InsertSaleOrder;
DELIMITER //
CREATE PROCEDURE sp_InsertSaleOrder(IN so_id INT, IN so_date DATETIME)
BEGIN

    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Insert a new saleorder
        INSERT INTO SaleOrders (customerID, date) VALUES (so_id, STR_TO_DATE(so_date, '%Y-%m-%d'));

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('SaleOrder could not be added.');
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- INSERT gameOrder
DROP PROCEDURE IF EXISTS sp_InsertGameOrder;
DELIMITER //
CREATE PROCEDURE sp_InsertGameOrder(IN game_id INT, IN so_id INT, IN discount DECIMAL(8,2))
BEGIN

    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Insert a new gameorder
        INSERT INTO GameOrders (gameID, saleOrderID, discount) VALUES 
            (game_id, so_id, discount);

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('GameOrder could not be added.');
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- #######################
-- UPDATE OPERATIONS
-- #######################

-- UPDATE game name
DROP PROCEDURE IF EXISTS sp_UpdateGameName;
DELIMITER //
CREATE PROCEDURE sp_UpdateGameName(IN g_id INT, IN g_name VARCHAR(45))
BEGIN

    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Update the game
        UPDATE Games SET name = g_name WHERE gameID = g_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('Game could not be updated.');
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- UPDATE game price
DROP PROCEDURE IF EXISTS sp_UpdateGamePrice;
DELIMITER //
CREATE PROCEDURE sp_UpdateGamePrice(IN g_id INT, IN g_price DECIMAL(16,2))
BEGIN

    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Update the game
        UPDATE Games SET price = g_price WHERE gameID = g_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('Game could not be updated.');
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- UPDATE GameOrder
DROP PROCEDURE IF EXISTS sp_UpdateGameOrder;
DELIMITER //
CREATE PROCEDURE sp_UpdateGameOrder(IN go_id INT, IN game_id INT, IN discount DECIMAL(8,2))
BEGIN

    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Update the GameOrder
        UPDATE GameOrders SET gameID = game_id, discount = discount
        WHERE gameOrderID = go_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('GameOrder could not be updated.');
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- #######################
-- OTHER OPERATIONS
-- #######################

-- RESET database
DROP PROCEDURE IF EXISTS sp_ResetDatabase;
DELIMITER //
CREATE PROCEDURE sp_ResetDatabase()
BEGIN
    -- Disable foreign key checks
    START TRANSACTION;
    SET FOREIGN_KEY_CHECKS=0;
    SET AUTOCOMMIT = 0;

    -- Clear all necessary tables first
    DROP TABLE IF EXISTS Customers;
    DROP TABLE IF EXISTS Games;
    DROP TABLE IF EXISTS Reviews;
    DROP TABLE IF EXISTS SaleOrders;
    DROP TABLE IF EXISTS GameOrders;

    -- Create Customers table, with a PK, first name, last name, and unique email
    CREATE TABLE Customers (
        customerID INT NOT NULL UNIQUE AUTO_INCREMENT,
        first_name VARCHAR(45),
        last_name VARCHAR(45),
        email VARCHAR(45) UNIQUE NOT NULL,
        
        PRIMARY KEY (customerID)
    );

    -- Insert sample customers, Nathan Lassing with email lassing@oregonstate.edu, Berenice Rubalcaba with email rubal@oregonstate.edu,
    -- Stacy FakeName with email stacyfn@gmail.com, and Michael Curry with email currymichael@yahoo.net
    INSERT INTO Customers (first_name, last_name, email)
    VALUES ('Nathan', 'Lassing', 'lassingn@oregonstate.edu'),
    ('Berenice', 'Rubalcaba', 'rubal@oregonstate.edu'),
    ('Stacy', 'FakeName', 'stacyfn@gmail.com'),
    ('Michael', 'Curry', 'currymichael@yahoo.net');

    -- Create Games table, with a PK, name, and price
    CREATE TABLE Games (
        gameID INT NOT NULL UNIQUE AUTO_INCREMENT,
        name VARCHAR(45) NOT NULL,
        price DECIMAL(16,2) NOT NULL,
        
        PRIMARY KEY (gameID)
    );

    -- Insert sample games, Cyberpunk 2077 costing 59.99, The Elder Scrolls IV: Oblivion Remastered costing 49.99, Overwatch 2 costing 0.0,
    -- Stellaris costing 39.99, and Left 4 Dead 2 costing 9.99
    INSERT INTO Games (name, price)
    VALUES ('Cyberpunk 2077', 59.99),
    ('The Elder Scrolls IV: Oblivion Remastered', 49.99),
    ('Overwatch 2', 0.0),
    ('Stellaris', 39.99),
    ('Left 4 Dead 2', 9.99);

    -- Create Reviews table, with a PK, ID of the reviewed game, ID of the reviewing customer, a star rating for the review (0-5 stars),
    -- and the (text) content of the review. The combination of the game and the reviewer must be unique (i.e., a customer cannot
    -- review the same game twice)
    CREATE TABLE Reviews (
        reviewID INT NOT NULL UNIQUE AUTO_INCREMENT,
        gameID INT NOT NULL,
        customerID INT NOT NULL,
        starRating TINYINT NOT NULL,
        content TEXT,
        CONSTRAINT unqGameCustomer UNIQUE (gameID, customerID),
        
        FOREIGN KEY (gameID) REFERENCES Games(gameID) ON DELETE CASCADE,
        FOREIGN KEY (customerID) REFERENCES Customers(customerID),
        PRIMARY KEY (reviewID)
    );

    -- Insert sample reviews, a 5 star review for Cyberpunk 2077 from Nathan Lassing, a 4 star review for Stellaris from Nathan Lassing, 
    -- and a 0 star review for Overwatch 2 from  Stacy FakeName. The Overwatch 2 review has no text, but the other reviews have a short sentence
    INSERT INTO Reviews (gameID, customerID, starRating, content)
    VALUES ((SELECT gameID FROM Games WHERE name = 'Cyberpunk 2077'), (SELECT customerID from Customers WHERE first_name = 'Nathan' AND last_name = 'Lassing'), 5, 'Should\'ve been delayed. Much better now.'),
    ((SELECT gameID FROM Games WHERE name = 'Stellaris'), (SELECT customerID from Customers WHERE first_name = 'Nathan' AND last_name = 'Lassing'), 4, 'Good, but DLCs are overpriced even on sale'),
    ((SELECT gameID FROM Games WHERE name = 'Overwatch 2'), (SELECT customerID from Customers WHERE first_name = 'Stacy' AND last_name = 'FakeName'), 0, NULL);

    -- Create SaleOrders table, which represents complete transactions (i.e., checking out a cart), with a PK, ID of the buying customer,
    -- and the date the transaction occurred
    CREATE TABLE SaleOrders (
        saleOrderID INT NOT NULL UNIQUE AUTO_INCREMENT,
        customerID INT NOT NULL,
        date DATETIME NOT NULL,
        
        FOREIGN KEY (customerID) REFERENCES Customers(customerID),
        PRIMARY KEY (saleOrderID)
    );

    -- Insert sample saleOrders, Nathan Lassing made a purchase on 2025-04-30, Nathan Lassing made a purchase on 2020-02-27,
    -- Stacy FakeName made a purchase on 2019-07-19
    INSERT INTO SaleOrders (customerID, date)
    VALUES ((SELECT customerID FROM Customers WHERE first_name = 'Nathan' AND last_name = 'Lassing'), STR_TO_DATE('2025-04-30', '%Y-%m-%d')),
    ((SELECT customerID FROM Customers WHERE first_name = 'Nathan' AND last_name = 'Lassing'), STR_TO_DATE('2020-02-27', '%Y-%m-%d')),
    ((SELECT customerID FROM Customers WHERE first_name = 'Stacy' AND last_name = 'FakeName'), STR_TO_DATE('2019-07-19', '%Y-%m-%d'));

    -- Create GameOrders table, which represents individual game purchases (a SaleOrder may have multiple GameOrders associated, meaning
    -- the customer's cart had multiple games), with a PK, ID of the purchased game, ID of the saleOrder this this purchase, 
    -- and the discount at which this game was bought at (in percentages)
    CREATE TABLE GameOrders (
        gameOrderID INT NOT NULL UNIQUE AUTO_INCREMENT,
        gameID INT NOT NULL,
        saleOrderID INT NOT NULL,
        discount DECIMAL(8,2) NOT NULL,
        
        FOREIGN KEY (gameID) REFERENCES Games(gameID) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (saleOrderID) REFERENCES SaleOrders(saleOrderID),
        PRIMARY KEY (gameOrderID)
    );

    -- Insert sample gameOrders. In one saleOrder, someone purchased Cyberpunk 2077 at no discount and Left 4 Dead 2 at a 90% discount,
    -- in another saleOrder, someone purchased Stellaris at a 20% discount,
    -- in another saleOrder, someone purchased Left 4 Dead 2 at no discount
    -- NOTE: above I describe each gameOrder as "*someone* purchased", as we cannot know which customer is associated with a gameOrder from this table alone.
    -- To find out, we'd have to go to the matching saleOrder entry and see which customer is associated with the saleOrder. This is done to prevent data redundancy
    INSERT INTO GameOrders (gameID, saleOrderID, discount)
    VALUES ((SELECT gameID from Games WHERE name = 'Cyberpunk 2077'), (SELECT saleOrderID FROM SaleOrders WHERE customerID = 1 AND date = STR_TO_DATE('2025-04-30', '%Y-%m-%d')), 0.0),
    ((SELECT gameID from Games WHERE name = 'Left 4 Dead 2'), (SELECT saleOrderID FROM SaleOrders WHERE customerID = 1 AND date = STR_TO_DATE('2025-04-30', '%Y-%m-%d')), 90.0),
    ((SELECT gameID from Games WHERE name = 'Stellaris'), (SELECT saleOrderID FROM SaleOrders WHERE customerID = 1 AND date = STR_TO_DATE('2020-02-27', '%Y-%m-%d')), 20.0),
    ((SELECT gameID from Games WHERE name = 'Left 4 Dead 2'), (SELECT saleOrderID FROM SaleOrders WHERE customerID = 3 AND date = STR_TO_DATE('2019-07-19', '%Y-%m-%d')), 0.0);

    -- Renable foreign key checks
    SET FOREIGN_KEY_CHECKS=1;
    COMMIT;

END //
DELIMITER ;