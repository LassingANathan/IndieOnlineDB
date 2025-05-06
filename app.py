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
    query1 = 'SELECT * FROM Reviews;'
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
    query1 = 'SELECT * FROM SaleOrders;'
    cur.execute(query1)
    
    # Retrieve results of query from the cursor
    saleOrdersResults = cur.fetchall()
        
    # Declare and execute query
    query2 = 'SELECT * FROM GameOrders;'
    cur.execute(query2)
    
    gameOrdersResults = cur.fetchall()

    # Render the orders page, passing the query results
    return render_template('orders.html', saleOrdersResults=saleOrdersResults, gameOrdersResults=gameOrdersResults)

@app.route('/gameOrders')
def gameOrders():
    # Create DB cursor
    cur = mysql.connection.cursor()
    
    # Declare and execute query
    query1 = 'SELECT * FROM GameOrders;'
    cur.execute(query1)
    
    # Retrieve results of query from the cursor
    results = cur.fetchall()

    # Render the gameOrders page, passing the query results
    return render_template('gameOrders.html', results=results)

# Listener
if __name__ == "__main__":

    #Start the app to run on a port of your choosing
    app.run(port=7909, debug=True)