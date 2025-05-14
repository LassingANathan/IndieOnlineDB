from flask import Flask, render_template, json, redirect, url_for
from flask_mysqldb import MySQL
from flask import request
import os

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'classmysql.engr.oregonstate.edu'
app.config['MYSQL_USER'] = 'cs340_USERNAME'
app.config['MYSQL_PASSWORD'] = 'PASSWORD'
app.config['MYSQL_DB'] = 'cs340_USERNAME'
app.config['MYSQL_CURSORCLASS'] = "DictCursor"

mysql = MySQL(app)

# Routes
@app.route('/')
def root():
    return render_template('root.html')

@app.route('/games')
def games():
    # Create DB cursor
    cur = mysql.connection.cursor()
    
    # Declare and execute query
    query1 = 'SELECT * FROM Games;'
    cur.execute(query1)
    
    # Retrieve results of query from the cursor
    results = cur.fetchall()

    # Render the Games page, passing the query results
    return render_template('games.html', results=results)

@app.route('/customers')
def customers():
    # Create DB cursor
    cur = mysql.connection.cursor()
    
    # Declare and execute query
    query1 = 'SELECT * FROM Customers;'
    cur.execute(query1)
    
    # Retrieve results of query from the cursor
    results = cur.fetchall()

    # Render the Customers page, passing the query results
    return render_template('customers.html', results=results)

@app.route('/reviews')
def reviews():
    # Create DB cursor
    cur = mysql.connection.cursor()
    
    # Declare and execute query
    query1 = """SELECT Reviews.reviewID, Games.name, Customers.first_name, Customers.last_name, Reviews.starRating, Reviews.content
            FROM Reviews
            JOIN Games ON Reviews.gameID = Games.gameID
            JOIN Customers ON Reviews.customerID = Customers.customerID;""" 
    cur.execute(query1)
    
    # Retrieve results of query from the cursor
    results = cur.fetchall()

    # Render the reviews page, passing the query results
    return render_template('reviews.html', results=results)

@app.route('/orders')
def orders():
    # Create DB cursor
    cur = mysql.connection.cursor()
    
    # Declare and execute query
    query1 = """SELECT SaleOrders.saleOrderID, Customers.first_name, Customers.last_name, SaleOrders.date
            FROM SaleOrders
            JOIN Customers ON SaleOrders.CustomerID = Customers.CustomerID;"""
    cur.execute(query1)
    
    # Retrieve results of query from the cursor
    saleOrdersResults = cur.fetchall()
        
    # Declare and execute query
    query2 = """SELECT GameOrders.gameOrderID, Games.name, GameOrders.saleOrderID, GameOrders.discount
            FROM GameOrders
            JOIN Games ON GameOrders.GameID = Games.GameID;"""
    cur.execute(query2)
    
    gameOrdersResults = cur.fetchall()

    # Render the orders page, passing the query results
    return render_template('orders.html', saleOrdersResults=saleOrdersResults, gameOrdersResults=gameOrdersResults)

# Listener
if __name__ == "__main__":

    #Start the app to run on a port of your choosing
    app.run(port=7909, debug=True)