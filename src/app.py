# importing libraries
from flask import g, Flask, request, render_template, flash, redirect, session, url_for
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.sql import func
from werkzeug.security import generate_password_hash, check_password_hash
from sqlalchemy import create_engine
from wtforms import SelectField
from flask_wtf import FlaskForm
from functools import wraps
import yaml
import os

# app init
app = Flask(__name__)

basedir = os.path.abspath(os.path.dirname(__file__))

# loading configuration data
config = yaml.load(open('config.yaml'), Loader=yaml.FullLoader)

app.config['SECRET_KEY'] = config['SECRET_KEY']
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///'+os.path.join(basedir, config['DATABASE'])
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
engine = create_engine(app.config['SQLALCHEMY_DATABASE_URI'], echo=False)

# After completing models use db.create_all() in pyconsole to create database...

# Database init
db = SQLAlchemy(app)

# # Models
class Flight(db.Model):
    __tablename__ = 'flight'
    flight_no = db.Column(db.String(15), primary_key=True)
    airline = db.Column(db.String(20))
    from_place = db.Column(db.String(100))
    to_place = db.Column(db.String(100))
    a_time = db.Column(db.String(20))
    d_time = db.Column(db.String(20))
    price = db.Column(db.Float)
    seats = db.Column(db.Integer)
    full = db.Column(db.Boolean)

class Booking(db.Model):
    __tablename__ = 'booking'
    book_id = db.Column(db.Integer, primary_key=True)
    p_name = db.Column(db.String(50))
    age = db.Column(db.Integer)
    from_place = db.Column(db.String(100))
    to_place = db.Column(db.String(100))
    no_seats = db.Column(db.Integer)
    a_time = db.Column(db.String(20))
    d_time = db.Column(db.String(20))
    payment = db.Column(db.Integer)
    booked_by = db.Column(db.String(50))
    user = db.Column(db.String(50))

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50))
    password = db.Column(db.String(80))
    first_name = db.Column(db.String(20))
    last_name = db.Column(db.String(20))
    email = db.Column(db.String(120)) 
    phone_number = db.Column(db.Integer)
    address = db.Column(db.String(100))
    admin = db.Column(db.Boolean)

# # # Form 
class Form(FlaskForm):
    fplace = SelectField('fplace', choices=list(set([i.from_place for i in Flight.query.all()])))
    tplace = SelectField('tplace', choices=list(set([i.to_place for i in Flight.query.all()])))
    airline = SelectField('airline', choices=list(set([i.airline for i in Flight.query.all()])))
    atime = SelectField('atime', choices=list(set([i.a_time for i in Flight.query.all()])))
    dtime = SelectField('dtime', choices=list(set([i.d_time for i in Flight.query.all()])))

# Wrapper class for login required
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'login' not in session:
            flash('You need to login', 'danger')
            return redirect(url_for('login', next=request.url))
        return f(*args, **kwargs)
    return decorated_function

# Flight Views
@app.route('/flight-get/<string:flight_no>', methods=['GET'])
@login_required
def flights_get(flight_no):
    qs = Flight.query.get(flight_no)
    return render_template('flight.html', qs=qs)

@app.route('/flight-all/<int:page_num>', methods=['GET'])
@login_required
def flights_all(page_num):
    qs = Flight.query.paginate(per_page=4,page=page_num,error_out=False)
    return render_template('flights_admin.html', qs=qs)

@app.route('/flight-insert/', methods=['GET','POST'])
@login_required
def flights_add():
    if session['admin'] != True:
        return render_template("admin_false.html")
    if request.method == 'POST':
        data = request.form
        insert = Flight(
            flight_no = data['fno'],
            airline = data['airline'],
            from_place = data['fplace'],
            to_place = data['tplace'],
            a_time = data['atime'],
            d_time = data['dtime'],
            price = float(data['price']),
            )
        db.session.add(insert)
        db.session.commit()
        flash("Data inserted into database", "success") 
    return render_template('insert.html')

@app.route("/flight-get/update/<string:flight_no>", methods=['GET', 'POST'])
@login_required
def update(flight_no):
    if session['admin'] != True:
        return render_template("admin_false.html")
    qs = Flight.query.get(flight_no)
    if request.method == 'POST':    
        data = request.form
        flight_no = data['fno']
        airline = data['airline']
        from_place = data['from_place']
        to_place = data['to_place']
        a_time = data['a_time']
        d_time = data['d_time']
        price = float(data['price'])
        db.session.commit()
        flash("Data has been updated", "success")
        return redirect(url_for('flights_get', flight_no = flight_no))
    return render_template("update_flight.html", qs = qs)

@app.route("/flight-get/delete/<string:flight_no>",methods=['GET'])
@login_required
def delete_flight(flight_no):
    if session['admin'] != True:
        return render_template("admin_false.html")
    qs = Flight.query.get(flight_no)
    db.session.delete(qs)
    db.session.commit()
    flash(f"{qs.flight_no} data has been deleted", "success")
    return redirect(url_for('flights_all'))

# Booking View
@app.route('/flight-get/book/', methods=['GET','POST'])
@login_required
def booking():
    form = Form()
    if request.method == 'POST':
        fplace = request.form.get('fplace')
        tplace = request.form.get('tplace')
        airline = request.form.get('airline')
        atime = request.form.get('atime')
        dtime = request.form.get('dtime')
        data = request.form
        qs = Flight.query.filter_by(from_place=fplace, to_place=tplace, airline=airline, d_time=dtime).first()
        if qs:
            insert = Booking(
                p_name = data['pname'],
                age = data['age'],
                from_place = data['fplace'],
                to_place = data['tplace'],
                no_seats = data['nseats'],
                a_time = qs.a_time,
                d_time = data['dtime'],
                booked_by = session['username'],
                payment=qs.price*float(data['nseats']),   
                user = session['username'],             
                )
            pay = qs.price*float(data['nseats'])    
            db.session.add(insert)
            db.session.commit()
            qs2 = Booking.query.filter_by(from_place=fplace, to_place=tplace, d_time=dtime).first()
            flash("Data inserted into database", "success")
            return redirect(url_for('booking_all',page_num=1))
        else:
            flash('No Availability', 'danger')
    return render_template('book.html', form=form)

@app.route('/booking-get/<string:book_id>', methods=['GET'])
@login_required
def booking_get(book_id):
    qs1 = Booking.query.get(book_id)
    qs2 = Flight.query.filter_by(from_place=qs1.from_place, to_place=qs1.to_place, d_time=qs1.d_time).first()
    return render_template('booking.html', qs=qs1,fno=qs2.flight_no,airline=qs2.airline) #fno=flight_no,airline=airline

@app.route('/booking-all/<int:page_num>', methods=['GET'])
@login_required
def booking_all(page_num):
    flight_no=[]
    qs=Booking.query.all()
    qs1 = Booking.query.filter_by(user=session['username']).order_by(db.desc('book_id')).paginate(per_page=4,page=page_num,error_out=False)
    if qs:
        for i in qs1.items:
            if i.user==session['username']:
                qs2 = Flight.query.filter_by(from_place=i.from_place,to_place=i.to_place,d_time=i.d_time).first()
                flight_no.append(qs2.flight_no)
        return render_template('bookings.html', qs=qs1, flight_no=flight_no)
    else:
        return render_template('book_error.html')

@app.route("/book/delete/<string:book_id>",methods=['GET'])
@login_required
def delete_booking(book_id):
    qs = Booking.query.get(book_id)
    db.session.delete(qs)
    db.session.commit()
    flash(f"Booking has been successfully canceled", "success")
    return redirect(url_for('booking_all',page_num=1))

# Admin Views
@app.route("/user/")
@login_required
def users_get_all():
    if session['admin'] != True:
        return render_template("admin_false.html")
    qs = User.query.all()
    return render_template('users.html', qs=qs)

@app.route("/user/<id>")
@login_required
def users_get_one(id):
    if session['admin'] != True:
        return render_template("admin_false.html")
    qs = User.query.get(id)
    return render_template('user_detail.html', qs=qs)

@app.route("/user/delete/<id>")
@login_required
def delete_user(id):
    if session['admin'] != True:
        return render_template("admin_false.html")
    qs = User.query.get(id)
    db.session.delete(qs)
    db.session.commit()
    flash(f"{ qs.username } has been removed!", "success")
    return redirect(url_for('users_get_all'))

@app.route("/user/update_status/<id>", methods=['GET','POST'])
@login_required
def update_user_status(id):
    if session['admin'] != True:
        return render_template("admin_false.html")
    qs = User.query.get(id)
    session['other_admin']=qs.admin
    if request.method == 'POST':
        is_checked = request.form.get('admin_status')
        qs.admin = bool(is_checked)
        db.session.commit()
    return render_template('user_admin.html', qs=qs)

# Profile Views
@app.route("/Profile/", methods=['GET', 'POST'])
@login_required
def profile():
    name = session.get('username')
    qs = User.query.filter_by(username = name).first()
    if request.method == 'POST':
        data = request.form
        if data['uname']:
            qs.username = data['uname']
        if data['mail']:
            qs.email = data['mail']
        if data['fname']:
            f_name = request.form['fname']
        if data['lname']:
            l_name = request.form['lname']
        if data['pnum']:
            p_num = request.form['pnum']
        if data['address']:
            address = request.form['address']
        if data['passw']:
            qs.password = generate_password_hash(data['passw'])
        flash("Profile has been updated", "success")
        db.session.commit()
    return render_template('profile_data.html', qs=qs)


# Basic Views
@app.route('/register/', methods=['GET','POST'])
def register():
    if request.method == "POST":
        uname = request.form['uname']
        qs = User.query.filter_by(username = uname).first()
        print(qs)
        if qs:
            flash("User already exists", "danger")
            return render_template("register.html") 
        mail = request.form['mail']
        qs = User.query.filter_by(email = mail).first()
        if qs:
            flash("Email ID already exists", "danger")
            return render_template("register.html")
        f_name = request.form['fname']
        l_name = request.form['lname']
        p_num = request.form['pnum']
        address = request.form['address']
        passw = request.form['passw']
        confpassw = request.form['confpassw']
        if passw == confpassw:
            if len(passw)>7:
                register = User(username = uname, email = mail, first_name=f_name, last_name=l_name, phone_number=p_num, address=address, password = generate_password_hash(passw), admin = None)
                db.session.add(register)
                db.session.commit()
                return redirect(url_for('login'))
            else:
                flash("Password must have a minimum of 8 characters", 'danger')
                return render_template("register.html")
        else:
            flash('Passwords do not match', 'danger')
            return render_template("register.html")
    return render_template("register.html")

@app.route('/login/', methods=["GET", "POST"])
def login():
    if request.method == "POST":
        uname = request.form["uname"]
        passw = request.form["passw"]
        login = User.query.filter_by(username=uname).first()
        if login is not None:
            if check_password_hash(login.password, passw):
                session['login'] = True
                login_status = True
                session['username'] = login.username
                session['email'] = login.email
                session['admin'] = login.admin
                admin_status = login.admin
                flash('Welcome ' + session['username'] +'! You have been successfully logged in', 'success')
                return redirect(url_for("home"))
            else:
                flash('Incorrect Password', 'danger')
                return render_template('login.html')
        else:
            flash('User does not exist', 'danger')
    return render_template("login.html")

@app.route('/logout/')
@login_required
def logout():
    login_status = False
    session.pop('username')
    session.pop('email')
    session.pop('admin')
    session.pop('login')
    flash("You have been logged out", 'info')
    return redirect(url_for('login'))

@app.route("/about/")
def about():
    return render_template('about.html')

@app.route("/")
def home():
    return render_template('index.html')


if __name__ == "__main__":
    app.run(debug=True)
