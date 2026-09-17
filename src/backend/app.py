from flask import Flask, request, jsonify, send_from_directory, session
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
from database import db, User, Note, init_db
import os

app = Flask(__name__, static_folder='static', static_url_path='')
app.secret_key = 'tu-secret-key-cambiar-en-produccion'

# ============= CONFIGURACIÓN =============
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///team_portal.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(days=30)

# ============= INICIALIZACIONES =============
db.init_app(app)

CORS(app, resources={
    r"/api/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type"],
        "supports_credentials": True
    }
})

# ============= HELPERS =============

def get_current_user():
    """Obtener usuario actual de la sesión"""
    user_id = session.get('user_id')
    if user_id:
        user = User.query.get(user_id)
        if user and user.is_active:
            return user
    return None

def login_required(f):
    """Decorador para requerir login"""
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        user = get_current_user()
        if not user:
            return jsonify({'error': 'Debe iniciar sesión'}), 401
        return f(*args, **kwargs)
    return decorated

def admin_required(f):
    """Decorador para requerir admin"""
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        user = get_current_user()
        if not user or user.role != 'admin':
            return jsonify({'error': 'Acceso denegado'}), 403
        return f(*args, **kwargs)
    return decorated

# ============= CONTEXTO =============
with app.app_context():
    init_db()

# ============= RUTAS DE AUTENTICACIÓN =============

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()

    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'error': 'Email y contraseña requeridos'}), 400

    user = User.query.filter_by(email=data['email']).first()

    if not user or not check_password_hash(user.password_hash, data['password']):
        return jsonify({'error': 'Credenciales inválidas'}), 401

    if not user.is_active:
        return jsonify({'error': 'Usuario inactivo'}), 403

    session['user_id'] = user.id
    session.permanent = True

    return jsonify({
        'user': {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'role': user.role,
            'is_active': user.is_active
        }
    }), 200

@app.route('/api/auth/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({'message': 'Sesión cerrada'}), 200

@app.route('/api/auth/me', methods=['GET'])
def get_current_user_route():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'No autenticado'}), 401

    return jsonify({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'is_active': user.is_active
    }), 200

# ============= RUTAS DE USUARIOS =============

@app.route('/api/users', methods=['GET'])
@admin_required
def get_users():
    users = User.query.all()
    return jsonify([{
        'id': u.id,
        'name': u.name,
        'email': u.email,
        'role': u.role,
        'is_active': u.is_active,
        'created_at': u.created_at.isoformat()
    } for u in users]), 200

@app.route('/api/users', methods=['POST'])
@admin_required
def create_user():
    data = request.get_json()

    if not data or not data.get('name') or not data.get('email') or not data.get('password'):
        return jsonify({'error': 'Nombre, email y contraseña requeridos'}), 400

    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'El email ya existe'}), 409

    new_user = User(
        name=data['name'],
        email=data['email'],
        password_hash=generate_password_hash(data['password']),
        role=data.get('role', 'user'),
        is_active=True
    )

    db.session.add(new_user)
    db.session.commit()

    return jsonify({
        'id': new_user.id,
        'name': new_user.name,
        'email': new_user.email,
        'role': new_user.role,
        'is_active': new_user.is_active
    }), 201

@app.route('/api/users/<int:user_id>', methods=['PUT'])
@admin_required
def update_user(user_id):
    target_user = User.query.get(user_id)

    if not target_user:
        return jsonify({'error': 'Usuario no encontrado'}), 404

    data = request.get_json()

    if 'is_active' in data and not data['is_active'] and target_user.role == 'admin':
        active_admins = User.query.filter_by(role='admin', is_active=True).count()
        if active_admins <= 1:
            return jsonify({'error': 'Debe haber al menos un administrador activo'}), 400

    if 'name' in data:
        target_user.name = data['name']
    if 'role' in data:
        target_user.role = data['role']
    if 'is_active' in data:
        target_user.is_active = data['is_active']

    db.session.commit()

    return jsonify({
        'id': target_user.id,
        'name': target_user.name,
        'email': target_user.email,
        'role': target_user.role,
        'is_active': target_user.is_active
    }), 200

# ============= RUTAS DE NOTAS =============

@app.route('/api/notes', methods=['GET'])
@login_required
def get_notes():
    notes = Note.query.all()
    return jsonify([{
        'id': n.id,
        'title': n.title,
        'text': n.text,
        'status': n.status,
        'position_x': n.position_x,
        'position_y': n.position_y,
        'created_by': n.created_by,
        'created_at': n.created_at.isoformat()
    } for n in notes]), 200

@app.route('/api/notes', methods=['POST'])
@login_required
def create_note():
    user = get_current_user()
    data = request.get_json()

    if not data or not data.get('title'):
        return jsonify({'error': 'Título requerido'}), 400

    new_note = Note(
        title=data['title'],
        text=data.get('text', ''),
        status=data.get('status', 'Pendiente'),
        position_x=data.get('position_x', 0),
        position_y=data.get('position_y', 0),
        created_by=user.id
    )

    db.session.add(new_note)
    db.session.commit()

    return jsonify({
        'id': new_note.id,
        'title': new_note.title,
        'text': new_note.text,
        'status': new_note.status,
        'position_x': new_note.position_x,
        'position_y': new_note.position_y,
        'created_by': new_note.created_by,
        'created_at': new_note.created_at.isoformat()
    }), 201

@app.route('/api/notes/<int:note_id>', methods=['PUT'])
@login_required
def update_note(note_id):
    note = Note.query.get(note_id)

    if not note:
        return jsonify({'error': 'Nota no encontrada'}), 404

    data = request.get_json()

    if 'title' in data:
        note.title = data['title']
    if 'text' in data:
        note.text = data['text']
    if 'status' in data:
        note.status = data['status']
    if 'position_x' in data:
        note.position_x = data['position_x']
    if 'position_y' in data:
        note.position_y = data['position_y']

    note.updated_at = datetime.utcnow()
    db.session.commit()

    return jsonify({
        'id': note.id,
        'title': note.title,
        'text': note.text,
        'status': note.status,
        'position_x': note.position_x,
        'position_y': note.position_y,
        'created_by': note.created_by,
        'created_at': note.created_at.isoformat()
    }), 200

@app.route('/api/notes/<int:note_id>', methods=['DELETE'])
@login_required
def delete_note(note_id):
    note = Note.query.get(note_id)

    if not note:
        return jsonify({'error': 'Nota no encontrada'}), 404

    db.session.delete(note)
    db.session.commit()

    return jsonify({'message': 'Nota eliminada'}), 200

# ============= RUTAS DE DASHBOARD =============

@app.route('/api/dashboard/metrics', methods=['GET'])
@login_required
def get_metrics():
    total_notes = Note.query.count()

    pending = Note.query.filter_by(status='Pendiente').count()
    in_progress = Note.query.filter_by(status='En curso').count()
    done = Note.query.filter_by(status='Hecho').count()

    return jsonify({
        'total': total_notes,
        'distribution': {
            'Pendiente': pending,
            'En curso': in_progress,
            'Hecho': done
        }
    }), 200

# ============= RUTAS ESTÁTICAS =============

@app.route('/')
def serve_index():
    return send_from_directory('static', 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    try:
        return send_from_directory('static', path)
    except:
        return send_from_directory('static', 'index.html')

# ============= ERRORES =============

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'No encontrado'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Error interno del servidor'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
