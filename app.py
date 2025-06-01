# The implementation of stored procedures, and general file/folder layout, is adapted from:
# Source URL: https://canvas.oregonstate.edu/courses/1999601/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25352968
# Accessed 5/22/2025

from flask import Flask, render_template, json, redirect, url_for
from flask_mysqldb import MySQL
from flask import request
import os
import database.db_connector as db

PORT = 7910
app = Flask(__name__)

### GET routes
# Homepage
@app.route('/')
def root():
    return render_template('root.html')

# Games page
@app.route('/games')
def games():
    # Connect to db, create cursor
    dbConnection = db.connectDB()
    
    # Declare and execute query
    query1 = 'SELECT gameID, name, price FROM Games;'
    results = db.query(dbConnection, query1).fetchall()

    # Render the Games page, passing the query results
    return render_template('games.html', results=results)

# Customers page
@app.route('/customers')
def customers():
    # Connect to db, create cursor
    dbConnection = db.connectDB()
    
    # Declare and execute query
    query1 = 'SELECT customerID, first_name, last_name, email FROM Customers'
    results = db.query(dbConnection, query1).fetchall()

    # Render the Customers page, passing the query results
    return render_template('customers.html', results=results)

# Reviews page
@app.route('/reviews')
def reviews():
    # Connect to db, create cursor
    dbConnection = db.connectDB()
    
    # Declare and execute query
    query1 = """SELECT Reviews.reviewID AS ReviewID, Games.name AS Game,
        CONCAT(Customers.first_name, ' ', Customers.last_name) AS Customer,
        Reviews.starRating AS StarRating, Reviews.content AS Content
        FROM Reviews
        JOIN Games ON Reviews.gameID = Games.gameID
        JOIN Customers ON Reviews.customerID = Customers.customerID;""" 
    results = db.query(dbConnection, query1).fetchall()

    # Render the reviews page, passing the query results
    return render_template('reviews.html', results=results)

# Orders page
@app.route('/orders')
def orders():
    # Connect to db, create cursor
    dbConnection = db.connectDB()
    
    # Declare and execute query
    query1 = """SELECT SaleOrders.saleOrderID AS SaleOrderID,
        CONCAT(Customers.first_name, ' ', Customers.last_name) AS Customer,
        DATE_FORMAT(SaleOrders.date, '%%Y-%%m-%%d') AS Date FROM SaleOrders
        JOIN Customers ON SaleOrders.customerID = Customers.customerID;"""
    
    # Retrieve results of query from the cursor
    saleOrdersResults = db.query(dbConnection, query1).fetchall()
    
    # Declare and execute query
    query2 = """SELECT customerID, CONCAT(first_name, ' ', last_name) AS Customer_Name
            FROM Customers
            ORDER BY last_name, first_name;"""
    
    orderedCustomers = db.query(dbConnection, query2).fetchall()
    
    # Declare and execute query
    query3 = """SELECT GameOrders.gameOrderID, Games.name, GameOrders.saleOrderID, GameOrders.discount
            FROM GameOrders
            JOIN Games ON GameOrders.GameID = Games.GameID;"""
    
    gameOrdersResults = db.query(dbConnection, query3).fetchall()
    
    # Declare and execute query
    query4 = """SELECT GameID, name
            FROM Games
            ORDER BY name;"""
    
    orderedGames = db.query(dbConnection, query4).fetchall()

    # Render the orders page, passing the query results
    return render_template('orders.html', saleOrdersResults=saleOrdersResults, orderedCustomers=orderedCustomers, gameOrdersResults=gameOrdersResults, orderedGames=orderedGames)

### POST routes

# RESET request
@app.route('/reset', methods=["POST"])
def resetDB():
    # Connect to db, create cursor
    dbConnection = db.connectDB()
    
    # Declare and execute query
    query1 = "CALL sp_ResetDatabase;"
    db.query(dbConnection, query1)
    
    print("Reset!!!!")
    
    # Redirect the user to the updated webpage
    return redirect("/")

# DELETE game request
@app.route('/games/delete', methods=["POST"])
def deleteGame():
    # Connect to db, create cursor
    dbConnection = db.connectDB()
    
    # Get data from form
    gameID = request.form["delete_GameID"]
    
    # Declare and execute query
    query1 = "CALL sp_DeleteGame(%s);"
    db.query(dbConnection, query1, (gameID,))
    
    # Redirect the user to the updated webpage
    return redirect("/games")

# INSERT game request
@app.route('/games/update', methods=["POST"])
def insertGame():
    # Connect to db, create cursor
    dbConnection = db.connectDB()
    
    # Get data from form
    gameName = request.form["insert_Name"]
    gamePrice = request.form["insert_Price"]
    
    print(type(gamePrice))
    
    # Declare and execute query
    query1 = "CALL sp_InsertGame(%s, %s);"
    db.query(dbConnection, query1, (gameName, gamePrice))
    
    # Redirect the user to the updated webpage
    return redirect("/games")

# Listener
if __name__ == "__main__":

    #Start the app to run on a port of your choosing
    app.run(port=PORT, debug=True)