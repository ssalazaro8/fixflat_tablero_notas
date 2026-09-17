from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from werkzeug.security import generate_password_hash

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default='user', nullable=False)  # 'admin' o 'user'
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    def __repr__(self):
        return f'<User {self.email}>'

class Note(db.Model):
    __tablename__ = 'notes'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    text = db.Column(db.Text, default='', nullable=False)
    status = db.Column(db.String(20), default='Pendiente', nullable=False)  # 'Pendiente', 'En curso', 'Hecho'
    position_x = db.Column(db.Integer, default=0, nullable=False)
    position_y = db.Column(db.Integer, default=0, nullable=False)
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    def __repr__(self):
        return f'<Note {self.title}>'

def init_db():
    """Inicializar base de datos con datos de demostración"""
    db.create_all()

    # Verificar si ya existen usuarios
    if User.query.first() is None:
        # Crear admin de demostración
        admin = User(
            name='Admin Demo',
            email='admin@demo.com',
            password_hash=generate_password_hash('admin123'),
            role='admin',
            is_active=True
        )

        # Crear usuario normal de demostración
        user = User(
            name='Usuario Demo',
            email='user@demo.com',
            password_hash=generate_password_hash('user123'),
            role='user',
            is_active=True
        )

        db.session.add(admin)
        db.session.add(user)
        db.session.commit()

        # Crear algunas notas de demostración
        demo_notes = [
            Note(
                title='Implementar autenticación',
                text='Agregar sistema de login y registro',
                status='En curso',
                position_x=50,
                position_y=50,
                created_by=admin.id
            ),
            Note(
                title='Diseñar interfaz',
                text='Crear el layout del tablero',
                status='Hecho',
                position_x=350,
                position_y=50,
                created_by=user.id
            ),
            Note(
                title='Integración con AWS',
                text='Configurar Lambda y S3',
                status='Pendiente',
                position_x=650,
                position_y=300,
                created_by=admin.id
            )
        ]

        for note in demo_notes:
            db.session.add(note)

        db.session.commit()
