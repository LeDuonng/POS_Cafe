from datetime import datetime, timedelta
from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
CORS(app)


def get_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost',
            database='coffeeapp',
            user='root',
            password=''  # Replace with your password if any
        )
        if connection.is_connected():
            print("Connected to MySQL")
            return connection
        else:
            print("Failed to connect to MySQL")
            return None
    except Error as e:
        print("Error while connecting to MySQL", e)
        return None

def fetch_data(query, params=None):
    connection = get_connection()
    if connection:
        try:
            cursor = connection.cursor()
            if params:
                cursor.execute(query, params)  # Thực hiện truy vấn với tham số
            else:
                cursor.execute(query)  # Thực hiện truy vấn không có tham số
            rows = cursor.fetchall()
            return rows
        except Error as e:
            print("Error while fetching data", e)
            return []
        finally:
            cursor.close()
            connection.close()
            print("MySQL connection is closed")
    return []

def execute_query(query, data):
    connection = get_connection()
    if connection:
        try:
            cursor = connection.cursor()
            cursor.execute(query, data)
            connection.commit()
            return cursor.lastrowid
        except Error as e:
            print("Error while executing query", e)
            return None
        finally:
            cursor.close()
            connection.close()
            print("MySQL connection is closed")
    return None

def update_query(query, data):
    connection = get_connection()
    if connection:
        try:
            cursor = connection.cursor()
            cursor.execute(query, data)
            connection.commit()
            # print(cursor.statement)

            return cursor.rowcount
        except Error as e:
            print("Error while executing query", e)
            return None
        finally:
            cursor.close()
            connection.close()
            print("MySQL connection is closed")
    return None

def delete_query(query, data):
    connection = get_connection()
    if connection:
        try:
            cursor = connection.cursor()
            cursor.execute(query, data)
            connection.commit()
            return cursor.rowcount
        except Error as e:
            print("Error while executing query", e)
            return None
        finally:
            cursor.close()
            connection.close()
            print("MySQL connection is closed")
    return None

@app.route('/users', methods=['GET'])
def get_users():
    query = "SELECT id, username, password, role, name, email, phone, address, image FROM users where del = 0"
    rows = fetch_data(query)
    users = [{'id': row[0], 'username': row[1], 'password': row[2], 'role': row[3], 'name': row[4], 'email': row[5], 'phone': row[6], 'address': row[7] , 'image': row[8]} for row in rows]
    return jsonify(users)

@app.route('/staff', methods=['GET'])
def get_staff():
    query = "SELECT id, user_id, salary, DATE_FORMAT(start_date, '%Y-%m-%d') as start_date, position FROM staff where del = 0"
    rows = fetch_data(query)
    staff = [{'id': row[0], 'user_id': row[1], 'salary': row[2], 'start_date': row[3], 'position': row[4]} for row in rows]
    return jsonify(staff)

@app.route('/tables', methods=['GET'])
def get_tables():
    query = "SELECT id, name, floor, area, status FROM tables where del = 0"
    rows = fetch_data(query)
    tables = [{'id': row[0], 'name': row[1], 'floor': row[2], 'area': row[3], 'status': row[4]} for row in rows]
    return jsonify(tables)

@app.route('/menu', methods=['GET'])
def get_menu():
    query = "SELECT id, name, description, price, image, category FROM menu where del = 0 and topping = 0"
    rows = fetch_data(query)
    menu = [{'id': row[0], 'name': row[1], 'description': row[2], 'price': row[3], 'image': row[4], 'category': row[5]} for row in rows]
    return jsonify(menu)

@app.route('/topping', methods=['GET'])
def get_topping():
    query = "SELECT id, name, description, price, image, category FROM menu where del = 0 and topping = 1"
    rows = fetch_data(query)
    menu = [{'id': row[0], 'name': row[1], 'description': row[2], 'price': row[3], 'image': row[4], 'category': row[5]} for row in rows]
    return jsonify(menu)

@app.route('/topping', methods=['POST'])
def add_topping():
    data = request.json
    query = "INSERT INTO menu (name, description, price, image, category, topping) VALUES (%s, %s, %s, %s, %s, 1)"
    topping_id = execute_query(query, (data['name'], data['description'], data['price'], data['image'], data['category']))
    return jsonify({'id': topping_id}), 201

@app.route('/topping/<int:id>', methods=['PUT'])
def update_topping(id):
    data = request.json
    query = "UPDATE menu SET name=%s, description=%s, price=%s, image=%s, category=%s WHERE id=%s AND topping=1"
    rowcount = update_query(query, (data['name'], data['description'], data['price'], data['image'], data['category'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/topping/<int:id>', methods=['DELETE'])
def delete_topping(id):
    query = "UPDATE menu SET del = 1 WHERE id=%s AND topping=1"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200



@app.route('/ingredients', methods=['GET'])
def get_ingredients():
    query = "SELECT id, name, unit, quantity FROM ingredients where del = 0"
    rows = fetch_data(query)
    ingredients = [{'id': row[0], 'name': row[1], 'unit': row[2], 'quantity': row[3]} for row in rows]
    return jsonify(ingredients)

@app.route('/orders', methods=['GET'])
def get_orders():
    query = "SELECT id, table_id, customer_id, staff_id, DATE_FORMAT(order_date, '%Y-%m-%d') as order_date, status FROM orders where del = 0"
    rows = fetch_data(query)
    orders = [{'id': row[0], 'table_id': row[1], 'customer_id': row[2], 'staff_id': row[3], 'order_date': row[4], 'status': row[5]} for row in rows]
    return jsonify(orders)

@app.route('/order_items', methods=['GET'])
def get_order_items():
    query = "SELECT id, order_id, menu_id, quantity, price FROM order_items where del = 0"
    rows = fetch_data(query)
    order_items = [{'id': row[0], 'order_id': row[1], 'menu_id': row[2], 'quantity': row[3], 'price': row[4]} for row in rows]
    return jsonify(order_items)

@app.route('/bills', methods=['GET'])
def get_bills():
    query = "SELECT id, order_id, total_amount, payment_method, DATE_FORMAT(payment_date, '%Y-%m-%d') as payment_date FROM bills where del = 0"
    rows = fetch_data(query)
    bills = [{'id': row[0], 'order_id': row[1], 'total_amount': row[2], 'payment_method': row[3], 'payment_date': row[4]} for row in rows]
    return jsonify(bills)

@app.route('/inventory', methods=['GET'])
def get_inventory():
    query = "SELECT id, ingredient_id, quantity, DATE_FORMAT(last_updated, '%Y-%m-%d') as last_updated FROM inventory where del = 0"
    rows = fetch_data(query)
    inventory = [{'id': row[0], 'ingredient_id': row[1], 'quantity': row[2], 'last_updated': row[3]} for row in rows]
    return jsonify(inventory)

@app.route('/customer_points', methods=['GET'])
def get_customer_points():
    query = "SELECT id, user_id, SUM(points) as points FROM customer_points  where del = 0 GROUP BY user_id"
    rows = fetch_data(query)
    customer_points = [{'id': row[0], 'user_id': row[1], 'points': row[2]} for row in rows]
    return jsonify(customer_points)


@app.route('/users', methods=['POST'])
def add_user():
    data = request.json
    query = "INSERT INTO users (username, password, role, name, email, phone, address) VALUES (%s, %s, %s, %s, %s, %s, %s)"
    user_id = execute_query(query, (data['username'], data['password'], data['role'], data['name'], data['email'], data['phone'], data['address']))
    return jsonify({'id': user_id}), 201

@app.route('/users/<int:id>', methods=['PUT'])
def update_user(id):
    data = request.json
    query = "UPDATE users SET username=%s, password=%s, role=%s, name=%s, email=%s, phone=%s, address=%s WHERE id=%s"
    rowcount = update_query(query, (data['username'], data['password'], data['role'], data['name'], data['email'], data['phone'], data['address'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/users/<int:id>', methods=['DELETE'])
def delete_user(id):
    query = "UPDATE users SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/staff', methods=['POST'])
def add_staff():
    data = request.json
    query = "INSERT INTO staff (user_id, salary, start_date, position) VALUES (%s, %s, %s, %s)"
    staff_id = execute_query(query, (data['user_id'], data['salary'], data['start_date'], data['position']))
    return jsonify({'id': staff_id}), 201

@app.route('/staff/<int:id>', methods=['PUT'])
def update_staff(id):
    data = request.json
    query = "UPDATE staff SET user_id=%s, salary=%s, start_date=%s, position=%s WHERE id=%s"
    rowcount = update_query(query, (data['user_id'], data['salary'], data['start_date'], data['position'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/staff/<int:id>', methods=['DELETE'])
def delete_staff(id):
    query = "UPDATE staff SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/tables', methods=['POST'])
def add_table():
    data = request.json
    query = "INSERT INTO tables (name, floor, area, status) VALUES (%s, %s, %s, %s)"
    table_id = execute_query(query, (data['name'], data['floor'], data['area'], data['status']))
    return jsonify({'id': table_id}), 201

@app.route('/tables/<int:id>', methods=['PUT'])
def update_table(id):
    data = request.json
    query = "UPDATE tables SET name=%s, floor=%s, area=%s, status=%s WHERE id=%s"
    rowcount = update_query(query, (data['name'], data['floor'], data['area'], data['status'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/tables/<int:id>', methods=['DELETE'])
def delete_table(id):
    query = "UPDATE tables SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/menu', methods=['POST'])
def add_menu_item():
    data = request.json
    query = "INSERT INTO menu (name, description, price, image, category) VALUES (%s, %s, %s, %s, %s)"
    menu_id = execute_query(query, (data['name'], data['description'], data['price'], data['image'], data['category']))
    return jsonify({'id': menu_id}), 201

@app.route('/menu/<int:id>', methods=['PUT'])
def update_menu_item(id):
    data = request.json
    query = "UPDATE menu SET name=%s, description=%s, price=%s, image=%s, category=%s WHERE id=%s"
    rowcount = update_query(query, (data['name'], data['description'], data['price'], data['image'], data['category'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/menu/<int:id>', methods=['DELETE'])
def delete_menu_item(id):
    # First, delete any order_items that reference this menu item
    delete_order_items_query = "UPDATE order_items SET del = 1 WHERE menu_id=%s"
    delete_order_items_rowcount = update_query(delete_order_items_query, (id,))
    
    # Then, delete the menu item itself
    delete_menu_query = "UPDATE menu SET del = 1 WHERE id=%s"
    delete_menu_rowcount = update_query(delete_menu_query, (id,))
    
    return jsonify({'rows_affected': delete_menu_rowcount}), 200

@app.route('/ingredients', methods=['POST'])
def add_ingredient():
    data = request.json
    query = "INSERT INTO ingredients (name, unit, quantity) VALUES (%s, %s, %s)"
    ingredient_id = execute_query(query, (data['name'], data['unit'], data['quantity']))
    return jsonify({'id': ingredient_id}), 

@app.route('/ingredients/<int:id>', methods=['PUT'])
def update_ingredient(id):
    data = request.json
    query = "UPDATE ingredients SET name=%s, unit=%s, quantity=%s WHERE id=%s"
    rowcount = update_query(query, (data['name'], data['unit'], data['quantity'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/ingredients/<int:id>', methods=['DELETE'])
def delete_ingredient(id):
    query = "UPDATE ingredients SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/orders', methods=['POST'])
def add_order():
    data = request.json
    if 'table_id' in data and 'customer_id' in data:
        query = "INSERT INTO orders (table_id, customer_id, staff_id, order_date, status, description) VALUES (%s, %s, %s, %s, %s, %s)"
        order_id = execute_query(query, (data['table_id'], data['customer_id'], data['staff_id'], data['order_date'], data['status'], data['description']))
    elif 'table_id' in data:
        query = "INSERT INTO orders (table_id, staff_id, order_date, status, description) VALUES (%s, %s, %s, %s, %s)"
        order_id = execute_query(query, (data['table_id'], data['staff_id'], data['order_date'], data['status'], data['description']))
    elif 'customer_id' in data:
        query = "INSERT INTO orders (customer_id, staff_id, order_date, status, description) VALUES (%s, %s, %s, %s, %s)"
        order_id = execute_query(query, (data['customer_id'], data['staff_id'], data['order_date'], data['status'], data['description']))
    else:
        query = "INSERT INTO orders (staff_id, order_date, status, description) VALUES (%s, %s, %s, %s)"
        order_id = execute_query(query, (data['staff_id'], data['order_date'], data['status'], data['description']))
    return jsonify({'id': order_id}), 201

@app.route('/orders/<int:id>', methods=['PUT'])
def update_order(id):
    data = request.json
    query = "UPDATE orders SET table_id=%s, customer_id=%s, staff_id=%s, order_date=%s, status=%s WHERE id=%s"
    rowcount = update_query(query, (data['table_id'], data['customer_id'], data['staff_id'], data['order_date'], data['status'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/orders/<int:id>', methods=['DELETE'])
def delete_order(id):
    query = "UPDATE orders SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/order_items', methods=['POST'])
def add_order_item():
    data = request.json
    query = "INSERT INTO order_items (order_id, menu_id, quantity, price, description) VALUES (%s, %s, %s, %s, %s)"
    order_item_id = execute_query(query, (data['order_id'], data['menu_id'], data['quantity'], data['price'], data['description']))
    return jsonify({'id': order_item_id}), 201

@app.route('/order_items/<int:id>', methods=['PUT'])
def update_order_item(id):
    data = request.json
    query = "UPDATE order_items SET order_id=%s, menu_id=%s, quantity=%s, price=%s WHERE id=%s"
    rowcount = update_query(query, (data['order_id'], data['menu_id'], data['quantity'], data['price'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/order_items/<int:id>', methods=['DELETE'])
def delete_order_item(id):
    query = "UPDATE order_items SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/bills', methods=['POST'])
def add_bill():
    data = request.json
    query = "INSERT INTO bills (order_id, total_amount, payment_method, payment_date) VALUES (%s, %s, %s, %s)"
    bill_id = execute_query(query, (data['order_id'], data['total_amount'], data['payment_method'], data['payment_date']))
    return jsonify({'id': bill_id}), 201

@app.route('/bills/<int:id>', methods=['PUT'])
def update_bill(id):
    data = request.json
    query = "UPDATE bills SET order_id=%s, total_amount=%s, payment_method=%s, payment_date=%s WHERE id=%s"
    rowcount = update_query(query, (data['order_id'], data['total_amount'], data['payment_method'], data['payment_date'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/bills/<int:id>', methods=['DELETE'])
def delete_bill(id):
    query = "UPDATE bills SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/inventory', methods=['POST'])
def add_inventory():
    data = request.json
    query = "INSERT INTO inventory (ingredient_id, quantity, last_updated) VALUES (%s, %s, %s)"
    inventory_id = execute_query(query, (data['ingredient_id'], data['quantity'], data['last_updated']))
    return jsonify({'id': inventory_id}), 201

@app.route('/inventory/<int:id>', methods=['PUT'])
def update_inventory(id):
    data = request.json
    query = "UPDATE inventory SET ingredient_id=%s, quantity=%s, last_updated=%s WHERE id=%s"
    rowcount = update_query(query, (data['ingredient_id'], data['quantity'], data['last_updated'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/inventory/<int:id>', methods=['DELETE'])
def delete_inventory(id):
    query = "UPDATE inventory SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/customer_points', methods=['POST'])
def add_customer_points():
    data = request.json
    # Check if the user already has points
    check_query = "SELECT points FROM customer_points WHERE user_id=%s AND del = 0"
    existing_points = fetch_data(check_query, (data['user_id'],))
    
    if existing_points:
        # Update the existing points
        query = "UPDATE customer_points SET points = points + %s WHERE user_id=%s AND del = 0"
        customer_points_id = update_query(query, (data['points'], data['user_id']))
    else:
        # Insert new points
        query = "INSERT INTO customer_points (user_id, points) VALUES (%s, %s)"
        customer_points_id = execute_query(query, (data['user_id'], data['points']))
    return jsonify({'id': customer_points_id}), 201

@app.route('/promotion_points', methods=['POST'])
def update_promotion_points():
    data = request.json
    # Check if the user already has points
    check_query = "SELECT points FROM customer_points WHERE user_id=%s AND del = 0"
    existing_points = fetch_data(check_query, (data['user_id'],))
    
    if existing_points :
        # Update the existing points
        new_points = existing_points[0][0] - data['points']
        query = "UPDATE customer_points SET points =  %s WHERE user_id=%s AND del = 0"
        customer_points_id = update_query(query, (new_points, data['user_id']))
    else:
        return jsonify({'message': 'Not enough points'}), 400
    return jsonify({'id': customer_points_id}), 201

@app.route('/customer_points/<int:id>', methods=['PUT'])
def update_customer_points(id):
    data = request.json
    query = "UPDATE customer_points SET user_id=%s, points=%s WHERE id=%s"
    rowcount = update_query(query, (data['user_id'], data['points'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/customer_points/<int:id>', methods=['GET'])
def get_customer_points_by_id(id):
    query = "SELECT id, user_id, points FROM customer_points WHERE id=%s AND del = 0"
    rows = fetch_data(query, (id,))
    if rows:
        customer_points = {'id': rows[0][0], 'user_id': rows[0][1], 'points': rows[0][2]}
        return jsonify(customer_points)
    else:
        return jsonify({'message': 'Customer points not found'}), 404

@app.route('/customer_points/<int:id>', methods=['DELETE'])
def delete_customer_points(id):
    query = "UPDATE customer_points SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/menu/<int:id>', methods=['GET'])
def get_menu_item(id):
    query = "SELECT id, name, description, price, image, category FROM menu WHERE id=%s AND del = 0"
    rows = fetch_data(query % id)
    menu_item = [{'id': row[0], 'name': row[1], 'description': row[2], 'price': row[3], 'image': row[4], 'category': row[5]} for row in rows]
    return jsonify(menu_item)

@app.route('/users/<int:id>', methods=['GET'])
def get_user(id):
    query = "SELECT id, username, password, role, name, email, phone, address, image FROM users WHERE id=%s AND del = 0"
    rows = fetch_data(query % id)
    user = {'id': rows[0][0], 'username': rows[0][1], 'password': rows[0][2], 'role': rows[0][3], 'name': rows[0][4], 'email': rows[0][5], 'phone': rows[0][6], 'address': rows[0][7] , 'image': rows[0][8]}
    return jsonify(user)

@app.route('/tables/<int:id>', methods=['GET'])
def get_table(id):
    query = "SELECT id, name, floor, area, status FROM tables WHERE id=%s AND del = 0"
    rows = fetch_data(query % id)
    table = {'id': rows[0][0], 'name': rows[0][1], 'floor': rows[0][2], 'area': rows[0][3], 'status': rows[0][4]}
    return jsonify(table)

@app.route('/staff/<int:id>', methods=['GET'])
def get_staff_member(id):
    query = "SELECT id, user_id, salary, start_date, position FROM staff WHERE id=%s AND del = 0"
    rows = fetch_data(query % id)
    if rows:
        staff_member = {
            'id': rows[0][0],
            'user_id': rows[0][1],
            'salary': rows[0][2],
            'start_date': rows[0][3].strftime('%d-%m-%Y') if rows[0][3] else None,
            'position': rows[0][4]
        }
        return jsonify(staff_member)
    else:
        return jsonify({'message': 'Staff member not found'}), 404

@app.route('/ingredients/search', methods=['GET'])
def search_ingredients():
    name = request.args.get('name', None)
    if name:
        query = "SELECT id, name, unit, quantity FROM ingredients WHERE del = 0 AND name COLLATE utf8mb4_general_ci LIKE %s"
        rows = fetch_data(query, (f"%{name}%",))
    else:
        query = "SELECT id, name, unit, quantity FROM ingredients WHERE del = 0"
        rows = fetch_data(query)
    ingredients = [{'id': row[0], 'name': row[1], 'unit': row[2], 'quantity': row[3]} for row in rows]
    return jsonify(ingredients)

@app.route('/orders/search', methods=['GET'])
def search_orders():
    id = request.args.get('id', None)
    if id:
        query = """
            SELECT o.id, o.table_id, t.name as table_name, o.customer_id, c.name as customer_name, 
               o.staff_id, s.name as staff_name, o.order_date, o.status, o.description
            FROM orders o
            LEFT JOIN tables t ON o.table_id = t.id
            LEFT JOIN users c ON o.customer_id = c.id
            LEFT JOIN users s ON o.staff_id = s.id
            WHERE o.del = 0 AND (
            c.name COLLATE utf8mb4_general_ci LIKE %s OR 
            s.name COLLATE utf8mb4_general_ci LIKE %s OR 
            t.name COLLATE utf8mb4_general_ci LIKE %s OR 
            o.order_date LIKE %s OR 
            o.description LIKE %s OR 
            o.id LIKE %s
            )
        """
        search_term = f"%{id}%"
        rows = fetch_data(query, (search_term, search_term, search_term, search_term, search_term, search_term))
    else:
        query = """
            SELECT o.id, o.table_id, t.name as table_name, o.customer_id, c.name as customer_name, 
                   o.staff_id, s.name as staff_name, o.order_date, o.status, o.description
            FROM orders o
            LEFT JOIN tables t ON o.table_id = t.id
            LEFT JOIN users c ON o.customer_id = c.id
            LEFT JOIN users s ON o.staff_id = s.id
            WHERE o.del = 0
        """
        rows = fetch_data(query)
    
    orders = [
        {
            'id': row[0],
            'table_id': row[1],
            'table_name': row[2],
            'customer_id': row[3],
            'customer_name': row[4],
            'staff_id': row[5],
            'staff_name': row[6],
            'order_date': row[7].strftime('%Y-%m-%d %H:%M:%S') if row[7] else None,
            'status': row[8],
            'description': row[9]
        }
        for row in rows
    ]
    return jsonify(orders)

@app.route('/order_items/search', methods=['GET'])
def search_order_items():
    order_id = request.args.get('order_id', None)
    textsearch = request.args.get('textsearch', None)
    
    if not order_id:
        return jsonify({'error': 'order_id is required'}), 400
    
    if textsearch:
        query = """
            SELECT oi.id, oi.order_id, oi.menu_id, m.name as menu_name, oi.quantity, oi.price, oi.description, m.del  
            FROM order_items oi
            JOIN menu m ON oi.menu_id = m.id
            WHERE  oi.order_id = %s AND m.name COLLATE utf8mb4_general_ci LIKE %s
        """
        rows = fetch_data(query, (order_id, f"%{textsearch}%"))
    else:
        query = """
            SELECT oi.id, oi.order_id, oi.menu_id, m.name as menu_name, oi.quantity, oi.price, oi.description, m.del   
            FROM order_items oi
            JOIN menu m ON oi.menu_id = m.id
            WHERE  oi.order_id = %s
        """
        rows = fetch_data(query, (order_id,))
    
    order_items = [{'id': row[0], 'order_id': row[1], 'menu_id': row[2], 'menu_name': row[3], 'quantity': row[4], 'price': row[5], 'description': row[6], 'del': row[7]} for row in rows]
    return jsonify(order_items)

@app.route('/bills/search', methods=['GET'])
def search_bills():
    payment_method = request.args.get('payment_method', None)
    if payment_method:
        query = """
        SELECT id, order_id + 1, total_amount, payment_method, payment_date, promotion_code 
        FROM bills 
        WHERE del = 0 
        AND (total_amount LIKE %s OR payment_date LIKE %s OR order_id LIKE %s)
        """
        search_term = f"%{payment_method}%"
        rows = fetch_data(query, (search_term, search_term, search_term))
    else:
        query = "SELECT id, order_id + 1, total_amount, payment_method, payment_date, promotion_code FROM bills WHERE del = 0"
        rows = fetch_data(query)
    bills = [{'id': row[0], 'order_id': row[1], 'total_amount': row[2], 'payment_method': row[3], 'payment_date': row[4].strftime('%Y-%m-%d %H:%M:%S') if row[4] else None, 'promotion_code': row[5]} for row in rows]
    return jsonify(bills)




@app.route('/customer_points/search', methods=['GET'])
def search_customer_points():
    name = request.args.get('name', None)
    if name:
        query = """
            SELECT cp.id, cp.user_id, cp.points, u.name
            FROM customer_points cp
            JOIN users u ON cp.user_id = u.id
            WHERE u.name COLLATE utf8mb4_general_ci LIKE %s AND cp.del = 0
        """
        rows = fetch_data(query, (f"%{name}%",))
    else:
        query = """
            SELECT cp.id, cp.user_id, cp.points, u.name
            FROM customer_points cp
            JOIN users u ON cp.user_id = u.id
            WHERE cp.del = 0
        """
        rows = fetch_data(query)
    
    customer_points = [{'id': row[0], 'user_id': row[1], 'points': row[2], 'user_name': row[3]} for row in rows]
    return jsonify(customer_points)

@app.route('/authenticate', methods=['POST'])
def authenticate_user():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    
    query = "SELECT id, name, role FROM users WHERE username=%s AND password=%s AND del = 0"
    rows = fetch_data(query % (f"'{username}'", f"'{password}'"))
    
    results = [{'id': row[0], 'name': row[1], 'role': row[2]} for row in rows]
    return jsonify(results)

@app.route('/register', methods=['POST'])
def register_user():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    name = data.get('name')
    email = data.get('email')
    phone = data.get('phone')
    address = data.get('address')
    
    # Check if username or email already exists
    check_user_query = "SELECT id FROM users WHERE username=%s OR email=%s"
    existing_user = fetch_data(check_user_query % (f"'{username}'", f"'{email}'"))
    
    if existing_user:
        return jsonify({'message': 'Username or email already exists'}), 400
    
    # Insert new user
    query = "INSERT INTO users (username, password, role, name, email, phone, address) VALUES (%s, %s, 'customer', %s, %s, %s, %s)"
    user_id = execute_query(query, (username, password, name, email, phone, address))
    
    return jsonify({'id': user_id}), 201

@app.route('/topping/distinct', methods=['GET'])
def get_topping_distinct():
    query = "SELECT category, COUNT(*) AS total_items FROM menu WHERE topping = 0 AND del = 0 GROUP BY category"
    rows = fetch_data(query)
    menu = [{'category': row[0], 'total_items': row[1]} for row in rows]
    return jsonify(menu) 

@app.route('/menu/category', methods=['GET'])
def get_menu_category():
    category = request.args.get('category', None)
    if category:
        query = "SELECT id, name, description, price, image, category, del FROM menu WHERE del = 0 AND topping = 0 AND (name COLLATE utf8mb4_general_ci LIKE %s OR category COLLATE utf8mb4_general_ci LIKE %s)"
        rows = fetch_data(query, ( f"%{category}%", f"%{category}%"))  # Truyền tham số dưới dạng tuple
    else:
        query = "SELECT id, name, description, price, image, category, del FROM menu WHERE del = 0 AND topping = 0"
        rows = fetch_data(query) 
    
    menu = [{'id': row[0], 'name': row[1], 'description': row[2], 'price': row[3], 'image': row[4], 'category': row[5], 'del': row[6]} for row in rows]
    return jsonify(menu)

@app.route('/table/distinct', methods=['GET'])
def get_table_distinct():
    query = "SELECT DISTINCT area, COUNT(*) AS total_tables FROM tables WHERE del = 0 GROUP BY area;"
    rows = fetch_data(query)
    menu = [{'area': row[0], 'total_tables': row[1]} for row in rows]
    return jsonify(menu) 

@app.route('/table/area', methods=['GET'])
def get_table_area():
    area = request.args.get('area', None)
    if area:
        query = "SELECT id, name, floor, area, status FROM tables WHERE del = 0 AND area = %s"
        rows = fetch_data(query % f"'{area}'")
    else:
        query = "SELECT id, name, floor, area, status FROM tables WHERE del = 0"
        rows = fetch_data(query)
    
    tables = [{'id': row[0], 'name': row[1], 'floor': row[2], 'area': row[3], 'status': row[4]} for row in rows]
    return jsonify(tables)  

@app.route('/config', methods=['GET'])
def get_config():
    query = "SELECT id, `key`, `value`, description FROM config"
    rows = fetch_data(query)
    config = [{'id': row[0], 'key': row[1], 'value': row[2], 'description': row[3]} for row in rows]
    return jsonify(config)

@app.route('/config', methods=['POST'])
def add_config():
    data = request.json
    query = "INSERT INTO config (`key`, `value`, description) VALUES (%s, %s, %s)"
    config_id = execute_query(query, (data['key'], data['value'], data['description']))
    return jsonify({'id': config_id}), 201

@app.route('/config/<int:id>', methods=['PUT'])
def update_config(id):
    data = request.json
    description = data.get('description', '')  # Provide a default value if 'description' is missing
    query = "UPDATE config SET `key`=%s, `value`=%s, description=%s WHERE id=%s"
    rowcount = update_query(query, (data['key'], data['value'], description, id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/orders/last', methods=['GET'])
def get_last_order():
    query = "SELECT id FROM orders ORDER BY order_date DESC LIMIT 1"
    rows = fetch_data(query)
    if rows:
        order = {
            'id': rows[0][0]

        }
        return jsonify(order)
    else:
        return jsonify({'message': 'No orders found'}), 404

@app.route('/users/search', methods=['GET'])
def search_users():
    search_term = request.args.get('search_term', None)
    if search_term:
        like_term = f"%{search_term}%"  # Tạo chuỗi tìm kiếm với wildcard
        query = """
            SELECT id, username, name, email, phone, address, role 
            FROM users 
            WHERE (username LIKE %s 
            OR name LIKE %s 
            OR email LIKE %s 
            OR phone LIKE %s 
            OR address LIKE %s) 
            AND del = 0
        """
        rows = fetch_data(query, (like_term, like_term, like_term, like_term, like_term))
    else:
        query = "SELECT id, username, name, email, phone, address, role FROM users WHERE del = 0"
        rows = fetch_data(query)
    
    users = [{'id': row[0], 'username': row[1], 'name': row[2], 'email': row[3], 'phone': row[4], 'address': row[5] , 'role': row[6]} for row in rows]
    return jsonify(users)

# Promotions
@app.route('/promotions', methods=['GET'])
def get_promotions():
    query = "SELECT id, name, description, start_date, end_date, discount_type, discount_value, min_order_value, code_limit, usage_limit, active FROM promotions WHERE del = 0"
    rows = fetch_data(query)
    promotions = [{'id': row[0], 'name': row[1], 'description': row[2], 'start_date': row[3].strftime('%Y-%m-%d') if row[3] else None, 'end_date': row[4].strftime('%Y-%m-%d') if row[4] else None, 'discount_type': row[5], 'discount_value': row[6], 'min_order_value': row[7], 'code_limit': row[8], 'usage_limit': row[9], 'active': row[10]} for row in rows]
    return jsonify(promotions)

@app.route('/promotionscustomer', methods=['GET'])
def get_promotions_customer():
    query = """
        SELECT id, name, description, start_date, end_date, discount_type, discount_value, min_order_value, code_limit, usage_limit, active
        FROM promotions
        WHERE del = 0
        AND active = 1
        AND usage_limit != 0
        AND code_limit != 0
        AND CURDATE() BETWEEN start_date AND end_date
    """
    rows = fetch_data(query)
    promotions = [
        {
            'id': row[0],
            'name': row[1],
            'description': row[2],
            'start_date': row[3].strftime('%Y-%m-%d') if row[3] else None,
            'end_date': row[4].strftime('%Y-%m-%d') if row[4] else None,
            'discount_type': row[5],
            'discount_value': row[6],
            'min_order_value': row[7],
            'code_limit': row[8],
            'usage_limit': row[9],
            'active': row[10],
        }
        for row in rows
    ]
    return jsonify(promotions)


@app.route('/promotions/<int:id>', methods=['GET'])
def get_promotion(id):
    query = "SELECT id, name, description, start_date, end_date, discount_type, discount_value, min_order_value, code_limit, usage_limit, active FROM promotions WHERE id=%s AND del = 0"
    rows = fetch_data(query, (id,))
    if rows:
        promotion = {'id': rows[0][0], 'name': rows[0][1], 'description': rows[0][2], 'start_date': rows[0][3].strftime('%Y-%m-%d') if rows[0][3] else None, 'end_date': rows[0][4].strftime('%Y-%m-%d') if rows[0][4] else None, 'discount_type': rows[0][5], 'discount_value': rows[0][6], 'min_order_value': rows[0][7], 'code_limit': rows[0][8], 'usage_limit': rows[0][9], 'active': rows[0][10]}
        return jsonify(promotion)
    else:
        return jsonify({'message': 'Promotion not found'}), 404

@app.route('/promotions', methods=['POST'])
def add_promotion():
    data = request.json
    query = "INSERT INTO promotions (name, description, start_date, end_date, discount_type, discount_value, min_order_value, code_limit, usage_limit, active) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
    promotion_id = execute_query(query, (data['name'], data['description'], data['start_date'], data['end_date'], data['discount_type'], data['discount_value'], data['min_order_value'], data['code_limit'], data['usage_limit'], data['active']))
    return jsonify({'id': promotion_id}), 201

@app.route('/promotions/<int:id>', methods=['PUT'])
def update_promotion(id):
    data = request.json
    query = "UPDATE promotions SET name=%s, description=%s, start_date=%s, end_date=%s, discount_type=%s, discount_value=%s, min_order_value=%s, code_limit=%s, usage_limit=%s, active=%s WHERE id=%s"
    rowcount = update_query(query, (data['name'], data['description'], data['start_date'], data['end_date'], data['discount_type'], data['discount_value'], data['min_order_value'], data['code_limit'], data['usage_limit'], data['active'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/promotions/<int:id>', methods=['DELETE'])
def delete_promotion(id):
    query = "UPDATE promotions SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200


@app.route('/promotionscustomer/search/<string:search_term>', methods=['GET'])
def search_promotions_customer(search_term):
    like_term = f"%{search_term}%"
    query = """
        SELECT id, name, description, start_date, end_date, discount_type, discount_value, min_order_value, code_limit, usage_limit, active
        FROM promotions
        WHERE (name LIKE %s OR description LIKE %s)
        AND del = 0
        AND active = 1
        AND usage_limit != 0
        AND code_limit != 0
        AND CURDATE() BETWEEN start_date AND end_date
    """
    rows = fetch_data(query, (like_term, like_term))
    promotions = [
        {
            'id': row[0],
            'name': row[1],
            'description': row[2],
            'start_date': row[3].strftime('%Y-%m-%d') if row[3] else None,
            'end_date': row[4].strftime('%Y-%m-%d') if row[4] else None,
            'discount_type': row[5],
            'discount_value': row[6],
            'min_order_value': row[7],
            'code_limit': row[8],
            'usage_limit': row[9],
            'active': row[10],
        }
        for row in rows
    ]
    return jsonify(promotions)


# Promotion Codes
@app.route('/promotion_codes', methods=['GET'])
def get_promotion_codes():
    query = "SELECT id, promotion_id, code, is_used, used_by, used_at FROM promotion_codes WHERE del = 0"
    rows = fetch_data(query)
    promotion_codes = [{'id': row[0], 'promotion_id': row[1], 'code': row[2], 'is_used': row[3], 'used_by': row[4], 'used_at': row[5].strftime('%Y-%m-%d %H:%M:%S') if row[5] else None} for row in rows]
    return jsonify(promotion_codes)

@app.route('/promotion_codes/<int:id>', methods=['GET'])
def get_promotion_code(id):
    query = "SELECT id, promotion_id, code, is_used, used_by, used_at FROM promotion_codes WHERE id=%s AND del = 0"
    rows = fetch_data(query, (id,))
    if rows:
        promotion_code = {'id': rows[0][0], 'promotion_id': rows[0][1], 'code': rows[0][2], 'is_used': rows[0][3], 'used_by': rows[0][4], 'used_at': rows[0][5].strftime('%Y-%m-%d %H:%M:%S') if rows[0][5] else None}
        return jsonify(promotion_code)
    else:
        return jsonify({'message': 'Promotion code not found'}), 404

@app.route('/promotion_codes', methods=['POST'])
def add_promotion_code():
    data = request.json
    query = "INSERT INTO promotion_codes (promotion_id, code, is_used, used_by, used_at) VALUES (%s, %s, %s, %s, %s)"
    promotion_code_id = execute_query(query, (data['promotion_id'], data['code'], data['is_used'], data['used_by'], data['used_at']))
    return jsonify({'id': promotion_code_id}), 201

@app.route('/promotion_codes/<int:id>', methods=['PUT'])
def update_promotion_code(id):
    data = request.json
    query = "UPDATE promotion_codes SET promotion_id=%s, code=%s, is_used=%s, used_by=%s, used_at=%s WHERE id=%s"
    rowcount = update_query(query, (data['promotion_id'], data['code'], data['is_used'], data['used_by'], data['used_at'], id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/promotion_codes/<int:id>', methods=['DELETE'])
def delete_promotion_code(id):
    query = "UPDATE promotion_codes SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/promotion_codes/search/<string:search_term>', methods=['GET'])
def search_promotion_codes(search_term):
    like_term = f"%{search_term}%"
    query = f"""
        SELECT id, promotion_id, code, is_used, used_by, used_at
        FROM promotion_codes
        WHERE code LIKE '{like_term}'
        AND del = 0
    """
    rows = fetch_data(query)
    promotion_codes = [{'id': row[0], 'promotion_id': row[1], 'code': row[2], 'is_used': row[3], 'used_by': row[4], 'used_at': row[5].strftime('%Y-%m-%d %H:%M:%S') if row[5] else None} for row in rows]
    return jsonify(promotion_codes)


@app.route('/staff/search', methods=['GET'])
def search_staff():
    position = request.args.get('position', None)
    if position:
        query = """
            SELECT s.id, s.user_id, s.salary, s.start_date, s.position, u.name
            FROM staff s
            JOIN users u ON s.user_id = u.id
            WHERE s.del = 0 AND (u.name COLLATE utf8mb4_general_ci LIKE %s OR s.start_date LIKE %s OR s.position COLLATE utf8mb4_general_ci LIKE %s)
        """
        search_term = f"%{position}%"
        rows = fetch_data(query, (search_term, search_term, search_term))
    else:
        query = """
            SELECT s.id, s.user_id, s.salary, s.start_date, s.position, u.name
            FROM staff s
            JOIN users u ON s.user_id = u.id
            WHERE s.del = 0
        """
        rows = fetch_data(query)
    staff = [{'id': row[0], 'user_id': row[1], 'salary': row[2], 'start_date': row[3].strftime('%Y-%m-%d') if row[3] else None, 'position': row[4], 'user_name': row[5]} for row in rows]
    return jsonify(staff)

@app.route('/tables/search', methods=['GET'])
def search_tables():
    search_term = request.args.get('search_term', None)
    if search_term:
        query = """
            SELECT id, name, floor, area, status 
            FROM tables 
            WHERE del = 0 
            AND (name COLLATE utf8mb4_general_ci LIKE %s 
            OR floor COLLATE utf8mb4_general_ci LIKE %s 
            OR area COLLATE utf8mb4_general_ci LIKE %s)
        """
        rows = fetch_data(query, (f"%{search_term}%", f"%{search_term}%", f"%{search_term}%"))
    else:
        query = "SELECT id, name, floor, area, status FROM tables WHERE del = 0"
        rows = fetch_data(query)
    tables = [{'id': row[0], 'name': row[1], 'floor': row[2], 'area': row[3], 'status': row[4]} for row in rows]
    return jsonify(tables)



@app.route('/inventory/search', methods=['GET'])
def search_inventory():
    ingredient_id = request.args.get('ingredient_id', None)
    if ingredient_id:
        query = """
            SELECT i.id, i.ingredient_id, ing.name, i.quantity, i.last_updated 
            FROM inventory i
            JOIN ingredients ing ON i.ingredient_id = ing.id
            WHERE i.del = 0 AND (ing.name COLLATE utf8mb4_general_ci LIKE %s OR i.last_updated LIKE %s)
        """
        rows = fetch_data(query, (f"%{ingredient_id}%", f"%{ingredient_id}%"))
    else:
        query = """
            SELECT i.id, i.ingredient_id, ing.name, i.quantity, i.last_updated 
            FROM inventory i
            JOIN ingredients ing ON i.ingredient_id = ing.id
            WHERE i.del = 0
        """
        rows = fetch_data(query)
    inventory = [{'id': row[0], 'ingredient_id': row[1], 'ingredient_name': row[2], 'quantity': row[3], 'last_updated': row[4].strftime('%Y-%m-%d %H:%M:%S') if row[4] else None} for row in rows]
    return jsonify(inventory)



@app.route('/promotions/search', methods=['GET'])
def search_promotions():
    name = request.args.get('name', None)
    if name:
        query = "SELECT id, name, description, start_date, end_date, discount_type, discount_value, min_order_value, code_limit, usage_limit, active FROM promotions WHERE del = 0 AND name COLLATE utf8mb4_general_ci LIKE %s"
        rows = fetch_data(query, (f"%{name}%",))
    else:
        query = "SELECT id, name, description, start_date, end_date, discount_type, discount_value, min_order_value, code_limit, usage_limit, active FROM promotions WHERE del = 0"
        rows = fetch_data(query)
    promotions = [{'id': row[0], 'name': row[1], 'description': row[2], 'start_date': row[3].strftime('%Y-%m-%d') if row[3] else None, 'end_date': row[4].strftime('%Y-%m-%d') if row[4] else None, 'discount_type': row[5], 'discount_value': row[6], 'min_order_value': row[7], 'code_limit': row[8], 'usage_limit': row[9], 'active': row[10]} for row in rows]
    return jsonify(promotions)



@app.route('/topping/search', methods=['GET'])
def search_topping():
    name = request.args.get('name', None)
    if name:
        query = "SELECT id, name, description, price, image, category FROM menu WHERE (name COLLATE utf8mb4_general_ci LIKE %s OR description COLLATE utf8mb4_general_ci LIKE %s OR category COLLATE utf8mb4_general_ci LIKE %s) AND topping = 1 AND del = 0"
        rows = fetch_data(query, (f"%{name}%", f"%{name}%", f"%{name}%"))
    else:
        query = "SELECT id, name, description, price, image, category FROM menu WHERE topping = 1 AND del = 0"
        rows = fetch_data(query)
    toppings = [{'id': row[0], 'name': row[1], 'description': row[2], 'price': row[3], 'image': row[4], 'category': row[5]} for row in rows]
    return jsonify(toppings)


@app.route('/reports/revenue/daily', methods=['GET'])
def get_daily_revenue():
    date_str = request.args.get('date')
    try:
        date_obj = datetime.strptime(date_str, '%Y-%m-%d')
    except (ValueError, TypeError):
        return jsonify({'error': 'Invalid date format. Please use YYYY-MM-DD.'}), 400

    query = """
        SELECT 
            SUM(CASE WHEN payment_method = 'cash' THEN total_amount ELSE 0 END) as total_cash,
            SUM(CASE WHEN payment_method = 'card' THEN total_amount ELSE 0 END) as total_card
        FROM bills
        WHERE DATE(payment_date) = %s AND del = 0
    """
    rows = fetch_data(query, (date_obj,))
    if rows and rows[0][0] is not None: # Check if any data exists for the given date.
        daily_revenue = {
            'total_cash': rows[0][0],
            'total_card': rows[0][1],
        }
        return jsonify(daily_revenue)
    else:
        return jsonify({'message': 'No revenue data found for this date'}), 404


@app.route('/reports/revenue/range', methods=['GET'])
def get_revenue_by_range():
    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')

    try:
        start_date = datetime.strptime(start_date_str, '%Y-%m-%d')
        end_date = datetime.strptime(end_date_str, '%Y-%m-%d') + timedelta(days=1)
    except (ValueError, TypeError):
        return jsonify({'error': 'Invalid date format. Please use YYYY-MM-DD.'}), 400

    query = """
        SELECT 
            DATE(payment_date) as payment_date,
            SUM(total_amount) as total_revenue
        FROM bills
        WHERE payment_date >= %s AND payment_date <= %s AND del = 0
        GROUP BY payment_date
    """    
    rows = fetch_data(query, (start_date, end_date))

    revenue_data = [{'date': row[0].strftime('%Y-%m-%d'), 'total_revenue': row[1]} for row in rows]

    return jsonify(revenue_data)



@app.route('/reports/revenue/category', methods=['GET'])
def get_revenue_by_category():
    query = """
        SELECT m.category, SUM(oi.quantity * oi.price) AS total_revenue
        FROM order_items oi
        JOIN menu m ON oi.menu_id = m.id
        WHERE oi.del = 0
        GROUP BY m.category
    """
    rows = fetch_data(query)
    revenue_by_category = [{'category': row[0], 'total_revenue': row[1]} for row in rows]
    return jsonify(revenue_by_category)

@app.route('/reports/revenue/category/range', methods=['GET'])
def get_revenue_by_category_range():
    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')

    try:
        start_date = datetime.strptime(start_date_str, '%Y-%m-%d')
        end_date = datetime.strptime(end_date_str, '%Y-%m-%d')
    except (ValueError, TypeError):
        return jsonify({'error': 'Invalid date format. Please use YYYY-MM-DD.'}), 400

    query = """
        SELECT m.category, SUM(oi.quantity * oi.price) AS total_revenue
        FROM order_items oi
        JOIN menu m ON oi.menu_id = m.id
        JOIN orders o ON oi.order_id = o.id
        WHERE oi.del = 0 AND o.order_date >= %s AND o.order_date <= %s
        GROUP BY m.category
    """
    rows = fetch_data(query, (start_date, end_date))
    revenue_by_category = [{'category': row[0], 'total_revenue': row[1]} for row in rows]
    return jsonify(revenue_by_category)

##dựa theo reports/revenue/range làm /reports/revenue/staff cũng dựa theo các khoảng thời gian
@app.route('/reports/revenue/staff/range', methods=['GET'])
def get_revenue_by_staff_range():
    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')

    try:
        start_date = datetime.strptime(start_date_str, '%Y-%m-%d')
        end_date = datetime.strptime(end_date_str, '%Y-%m-%d') + timedelta(days=1)
    except (ValueError, TypeError):
        return jsonify({'error': 'Invalid date format. Please use YYYY-MM-DD.'}), 400

    query = """
    SELECT 
        s.id AS staff_id,
        u.name AS staff_name,
        SUM(b.total_amount) AS total_revenue
    FROM bills AS b
    JOIN orders AS o ON b.order_id = o.id
    JOIN staff AS s ON o.staff_id = s.id
    JOIN users AS u ON s.user_id = u.id
    WHERE b.del = 0 AND o.order_date >= %s AND o.order_date <= %s
    GROUP BY s.id, u.name
    """
    rows = fetch_data(query, (start_date, end_date))
    revenue_by_staff = [{'staff_id': row[0], 'staff_name': row[1], 'total_revenue': row[2]} for row in rows]
    return jsonify(revenue_by_staff)

@app.route('/getnameuserbyid/<int:id>', methods=['GET'])
def get_name_user_by_id(id):
    query = "SELECT name FROM users WHERE id=%s "
    rows = fetch_data(query, (id,))
    results = {'name': rows[0][0]}
    return jsonify(results)

@app.route('/getnameingredientbyid/<int:id>', methods=['GET'])
def get_name_ingredient_by_id(id):
    query = "SELECT name FROM ingredients WHERE id=%s "
    rows = fetch_data(query, (id,))
    results = {'name': rows[0][0]}
    return jsonify(results)

@app.route('/getnamemenuitembyid/<int:id>', methods=['GET'])
def get_name_menu_item_by_id(id):
    query = "SELECT name FROM menu WHERE id=%s"
    rows = fetch_data(query, (id,))
    results = {'name': rows[0][0]}
    return jsonify(results)

@app.route('/getnametablebyid/<int:id>', methods=['GET'])
def get_name_table_by_id(id):
    query = "SELECT name FROM tables WHERE id=%s "
    rows = fetch_data(query, (id,))
    results = {'name': rows[0][0]}
    return jsonify(results)

@app.route('/getnamepromotionbyid/<int:id>', methods=['GET'])
def get_name_promotion_by_id(id):
    query = "SELECT name FROM promotions WHERE id=%s"
    rows = fetch_data(query, (id,))
    results = {'name': rows[0][0]}
    return jsonify(results)

@app.route('/getnamestaffbyid/<int:id>', methods=['GET'])
def get_name_staff_by_id(id):
    query = """
        SELECT 
            users.name
        FROM 
            staff
        INNER JOIN 
            users ON staff.user_id = users.id
        WHERE 
            staff.id = %s 
    """    
    rows = fetch_data(query, (id,))
   
    results = {'user_name': rows[0][0]}
    return jsonify(results)

    
@app.route('/tables/<int:id>/status', methods=['PUT'])
def update_table_status(id):
    data = request.json
    new_status = data.get('status')
    if new_status is None:
        return jsonify({'error': 'Status is required'}), 400

    query = "UPDATE tables SET status=%s WHERE id=%s AND del = 0"
    rowcount = update_query(query, (new_status, id))
    return jsonify({'rows_affected': rowcount}), 200



@app.route('/orders/merge_change_table', methods=['PUT'])
def merge_table():
    data = request.json
    old_table_id = data.get('old_table_id')
    new_table_id = data.get('new_table_id')
    if old_table_id is None or new_table_id is None:
        return jsonify({'error': 'Old table ID and new table ID are required'}), 400

    # Tìm kiếm đơn hàng dựa theo table_id cũ
    query = "SELECT id FROM orders WHERE table_id=%s ORDER BY order_date DESC LIMIT 1"
    rows = fetch_data(query, (old_table_id,))
    if not rows:
        return jsonify({'message': 'No orders found for this table'}), 404

    order_id = rows[0][0]

    # Update the order with the new table ID
    update_order_query = "UPDATE orders SET table_id=%s WHERE id=%s AND del = 0"
    update_order_rowcount = update_query(update_order_query, (new_table_id, order_id))

    # Update the status of the new table
    update_new_table_query = "UPDATE tables SET status='occupied' WHERE id=%s AND del = 0"
    update_new_table_rowcount = update_query(update_new_table_query, (new_table_id,))

    # Update the status of the old table
    update_old_table_query = "UPDATE tables SET status='available' WHERE id=%s AND del = 0"
    update_old_table_rowcount = update_query(update_old_table_query, (old_table_id,))

    return jsonify({
        'order_updated': update_order_rowcount,
        'new_table_updated': update_new_table_rowcount,
        'old_table_updated': update_old_table_rowcount
    }), 200

@app.route('/discounted_products', methods=['GET'])
def get_discounted_products():
    query = """
        SELECT m.id, m.name, m.price, pd.discount_type, pd.discount_value, pd.start_date, pd.end_date, pd.active
        FROM menu m
        JOIN product_discounts pd ON m.discount_id = pd.id
        WHERE
             pd.del = 0
            AND CURRENT_DATE BETWEEN pd.start_date AND pd.end_date
            AND m.del = 0
    """
    rows = fetch_data(query)
    discounted_products = [
        {
            'id': row[0],
            'name': row[1],
            'price': row[2],
            'discount_type': row[3],
            'discount_value': row[4],
            'start_date': row[5].strftime('%Y-%m-%d') if row[5] else None,
            'end_date': row[6].strftime('%Y-%m-%d') if row[6] else None,
            'active': row[7]
        }
        for row in rows
    ]
    return jsonify(discounted_products)

@app.route('/discounted_products', methods=['POST'])
def add_discounted_product():
    data = request.json
    menu_id = data.get('menu_id')
    discount_type = data.get('discount_type')
    discount_value = data.get('discount_value')
    start_date = data.get('start_date')
    end_date = data.get('end_date')
    active = data.get('active')

    if not all([menu_id, discount_type, discount_value, start_date, end_date]):
        return jsonify({'error': 'All fields are required'}), 400

    # Insert into product_discounts
    insert_discount_query = """
        INSERT INTO product_discounts (menu_id, discount_type, discount_value, start_date, end_date, active)
        VALUES (%s, %s, %s, %s, %s, %s)
    """
    discount_id = execute_query(insert_discount_query, (menu_id, discount_type, discount_value, start_date, end_date, active))

    if discount_id:
        # Update menu to link the product with the discount
        update_menu_query = """
            UPDATE menu
            SET has_discount = TRUE, discount_id = %s
            WHERE id = %s
        """
        update_rowcount = update_query(update_menu_query, (discount_id, menu_id))
        return jsonify({'discount_id': discount_id, 'rows_affected': update_rowcount}), 201
    else:
        return jsonify({'error': 'Failed to add discount'}), 500

@app.route('/discounted_products/<int:id>', methods=['PUT'])
def update_discounted_product(id):
    data = request.json
    discount_type = data.get('discount_type')
    discount_value = data.get('discount_value')
    start_date = data.get('start_date')
    end_date = data.get('end_date')
    active = data.get('active')

    if not all([discount_type, discount_value, start_date, end_date, active is not None]):
        return jsonify({'error': 'All fields are required'}), 400

    query = """
        UPDATE product_discounts
        SET discount_type=%s, discount_value=%s, start_date=%s, end_date=%s, active=%s
        WHERE id=%s AND del = 0
    """
    
    rowcount = update_query(query, (discount_type, discount_value, start_date, end_date, active, id))
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/discounted_products/<int:id>', methods=['DELETE'])
def delete_discounted_product(id):
    # First, update the menu item to remove the discount
    update_menu_query = "UPDATE menu SET has_discount = FALSE, discount_id = NULL WHERE discount_id = %s"
    update_menu_rowcount = update_query(update_menu_query, (id,))

    # Then, mark the discount as deleted
    query = "UPDATE product_discounts SET del = 1 WHERE id=%s"
    rowcount = update_query(query, (id,))
    
    return jsonify({
        'menu_items_updated': update_menu_rowcount,
        'discount_deleted': rowcount
    }), 200

@app.route('/promotions/<int:id>/use', methods=['PUT'])
def use_promotion_code(id):
    query = "SELECT code_limit FROM promotions WHERE id=%s AND del = 0"
    rows = fetch_data(query, (id,))
    
    if not rows:
        return jsonify({'message': 'Promotion not found'}), 404
    
    usage_limit = rows[0][0]
    
    if usage_limit <= 0:
        return jsonify({'message': 'Promotion code usage limit reached'}), 400
    
    update_query_str = "UPDATE promotions SET code_limit = code_limit - 1 WHERE id=%s AND del = 0"
    rowcount = update_query(update_query_str, (id,))
    
    return jsonify({'rows_affected': rowcount}), 200

@app.route('/users/<int:id>/password', methods=['PUT'])
def update_password(id):
    data = request.json
    new_password = data.get('new_password')
    if not new_password:
        return jsonify({'error': 'New password is required'}), 400

    query = "UPDATE users SET password=%s WHERE id=%s AND del = 0"
    rowcount = update_query(query, (new_password, id))
    return jsonify({'rows_affected': rowcount}), 200


@app.route('/billss/search', methods=['GET'])
def search_billss():
    payment_method = request.args.get('payment_method', None)
    if payment_method:
        query = """
        SELECT b.id, b.order_id + 1 as order_id, b.total_amount, b.payment_method, b.payment_date, b.promotion_code, 
            o.table_id, t.name as table_name, o.customer_id, c.name as customer_name, 
            o.staff_id, s.name as staff_name, o.order_date, o.status, o.description 
        FROM bills b
        JOIN orders o ON b.order_id = o.id
        LEFT JOIN tables t ON o.table_id = t.id
        LEFT JOIN users c ON o.customer_id = c.id
        LEFT JOIN users s ON o.staff_id = s.id
        WHERE b.del = 0 AND (
            c.name COLLATE utf8mb4_general_ci LIKE %s OR 
            s.name COLLATE utf8mb4_general_ci LIKE %s OR 
            t.name COLLATE utf8mb4_general_ci LIKE %s OR 
            b.payment_date LIKE %s
            OR b.id - 1 LIKE %s
        )
        """
        search_term = f"%{payment_method}%"
        rows = fetch_data(query, (search_term, search_term, search_term, search_term, search_term))
    else:
        query = """
        SELECT b.id, b.order_id + 1 as order_id, b.total_amount, b.payment_method, b.payment_date, b.promotion_code, 
            o.table_id, t.name as table_name, o.customer_id, c.name as customer_name, 
            o.staff_id, s.name as staff_name, o.order_date, o.status, o.description 
        FROM bills b
        JOIN orders o ON b.order_id = o.id
        LEFT JOIN tables t ON o.table_id = t.id
        LEFT JOIN users c ON o.customer_id = c.id
        LEFT JOIN users s ON o.staff_id = s.id
        WHERE b.del = 0
        """
        rows = fetch_data(query)
    
    bills = [
        {
            'id': row[0],
            'order_id': row[1],
            'total_amount': row[2],
            'payment_method': row[3],
            'payment_date': row[4].strftime('%Y-%m-%d %H:%M:%S') if row[4] else None,
            'promotion_code': row[5],
            'table_id': row[6],
            'table_name': row[7],
            'customer_id': row[8],
            'customer_name': row[9],
            'staff_id': row[10],
            'staff_name': row[11],
            'order_date': row[12].strftime('%Y-%m-%d %H:%M:%S') if row[12] else None,
            'status': row[13],
            'description': row[14]
        }
        for row in rows
    ]
    return jsonify(bills)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
