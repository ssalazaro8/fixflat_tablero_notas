// ============= CONFIGURACIÓN GLOBAL =============

const API_BASE = 'http://localhost:5000/api';
let currentUser = null;
let currentNoteId = null;
let currentUserId = null;
let draggedNote = null;

// ============= INICIALIZACIÓN =============

document.addEventListener('DOMContentLoaded', () => {
    checkAuth();
    setupEventListeners();
});

async function checkAuth() {
    try {
        const response = await fetch(`${API_BASE}/auth/me`, {
            credentials: 'include'
        });

        if (response.ok) {
            currentUser = await response.json();
            showMainScreen();
            updateUserInfo();
            loadNotes();
        } else {
            showLoginScreen();
        }
    } catch (error) {
        showLoginScreen();
    }
}

function setupEventListeners() {
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }

    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', (e) => switchTab(e.target.dataset.tab));
    });

    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', handleLogout);
    }

    const newNoteBtn = document.getElementById('new-note-btn');
    if (newNoteBtn) {
        newNoteBtn.addEventListener('click', () => {
            currentNoteId = null;
            openNoteModal();
        });
    }

    const noteForm = document.getElementById('note-form');
    if (noteForm) {
        noteForm.addEventListener('submit', handleSaveNote);
    }

    const newUserBtn = document.getElementById('new-user-btn');
    if (newUserBtn) {
        newUserBtn.addEventListener('click', () => {
            currentUserId = null;
            openUserModal();
        });
    }

    const userForm = document.getElementById('user-form');
    if (userForm) {
        userForm.addEventListener('submit', handleSaveUser);
    }

    const refreshBtn = document.getElementById('refresh-metrics');
    if (refreshBtn) {
        refreshBtn.addEventListener('click', loadMetrics);
    }
}

// ============= AUTENTICACIÓN =============

async function handleLogin(e) {
    e.preventDefault();

    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const errorDiv = document.getElementById('login-error');

    try {
        const response = await fetch(`${API_BASE}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ email, password })
        });

        const data = await response.json();

        if (!response.ok) {
            errorDiv.textContent = data.error || 'Error al iniciar sesión';
            errorDiv.classList.add('show');
            return;
        }

        currentUser = data.user;
        showMainScreen();
        updateUserInfo();
        loadNotes();

    } catch (error) {
        console.error('Error:', error);
        errorDiv.textContent = 'Error de conexión';
        errorDiv.classList.add('show');
    }
}

async function handleLogout() {
    try {
        await fetch(`${API_BASE}/auth/logout`, {
            method: 'POST',
            credentials: 'include'
        });
    } catch (error) {
        console.error('Error:', error);
    }

    currentUser = null;
    showLoginScreen();
}

// ============= INTERFAZ =============

function showLoginScreen() {
    document.getElementById('login-screen').classList.add('active');
    document.getElementById('main-screen').classList.remove('active');
}

function showMainScreen() {
    document.getElementById('login-screen').classList.remove('active');
    document.getElementById('main-screen').classList.add('active');

    const adminTab = document.getElementById('admin-tab');
    if (adminTab) {
        if (currentUser && currentUser.role !== 'admin') {
            adminTab.style.display = 'none';
        } else {
            adminTab.style.display = 'block';
            loadUsers();
        }
    }

    switchTab('dashboard');
}

function updateUserInfo() {
    const userInfo = document.getElementById('user-info');
    if (userInfo && currentUser) {
        const role = currentUser.role === 'admin' ? 'Administrador' : 'Usuario';
        userInfo.textContent = `${currentUser.name} (${role})`;
    }
}

function switchTab(tabName) {
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });

    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });

    const tabContent = document.getElementById(tabName);
    if (tabContent) {
        tabContent.classList.add('active');
    }

    const tabBtn = document.querySelector(`[data-tab="${tabName}"]`);
    if (tabBtn) {
        tabBtn.classList.add('active');
    }

    if (tabName === 'board') {
        loadNotes();
    } else if (tabName === 'dashboard') {
        loadMetrics();
    } else if (tabName === 'users') {
        loadUsers();
    }
}

// ============= NOTAS =============

async function loadNotes() {
    try {
        const response = await fetch(`${API_BASE}/notes`, {
            credentials: 'include'
        });

        if (!response.ok) throw new Error('Error al cargar notas');

        const notes = await response.json();
        renderNotes(notes);
    } catch (error) {
        console.error('Error:', error);
    }
}

function renderNotes(notes) {
    const canvas = document.getElementById('notes-canvas');
    if (!canvas) return;

    canvas.innerHTML = '';
    notes.forEach(note => {
        canvas.appendChild(createNoteElement(note));
    });
}

function createNoteElement(note) {
    const noteEl = document.createElement('div');
    noteEl.className = `note status-${note.status.toLowerCase().replace(' ', '-')}`;
    noteEl.dataset.id = note.id;
    noteEl.style.left = note.position_x + 'px';
    noteEl.style.top = note.position_y + 'px';

    noteEl.innerHTML = `
        <div class="note-header">
            <div class="note-title" contenteditable="true">${escapeHtml(note.title)}</div>
            <div class="note-actions">
                <button class="note-btn" onclick="editNote(${note.id})" title="Editar">✏️</button>
                <button class="note-btn" onclick="deleteNote(${note.id})" title="Eliminar">🗑️</button>
            </div>
        </div>
        <div class="note-text" contenteditable="true">${escapeHtml(note.text)}</div>
        <div class="note-footer">
            <div class="note-status" onclick="cycleStatus(this, ${note.id})">${note.status}</div>
            <button class="note-save" onclick="saveNotePosition(${note.id})">Guardar</button>
        </div>
    `;

    makeNoteDraggable(noteEl, note.id);
    return noteEl;
}

function makeNoteDraggable(noteEl, noteId) {
    let posX = 0, posY = 0, mouseX = 0, mouseY = 0;

    noteEl.addEventListener('mousedown', (e) => {
        if (e.target.contentEditable === 'true' || e.target.classList.contains('note-btn') ||
            e.target.classList.contains('note-status') || e.target.classList.contains('note-save')) {
            return;
        }

        draggedNote = noteEl;
        noteEl.classList.add('dragging');

        mouseX = e.clientX;
        mouseY = e.clientY;
        posX = noteEl.offsetLeft;
        posY = noteEl.offsetTop;

        document.addEventListener('mousemove', moveNote);
        document.addEventListener('mouseup', stopDragNote);
    });

    function moveNote(e) {
        const canvas = document.getElementById('notes-canvas');
        let newX = posX + (e.clientX - mouseX);
        let newY = posY + (e.clientY - mouseY);

        newX = Math.max(0, Math.min(newX, canvas.offsetWidth - noteEl.offsetWidth));
        newY = Math.max(0, Math.min(newY, canvas.offsetHeight - noteEl.offsetHeight));

        noteEl.style.left = newX + 'px';
        noteEl.style.top = newY + 'px';
    }

    function stopDragNote() {
        document.removeEventListener('mousemove', moveNote);
        document.removeEventListener('mouseup', stopDragNote);

        if (draggedNote) {
            noteEl.classList.remove('dragging');
            saveNotePosition(noteId);
            draggedNote = null;
        }
    }
}

function cycleStatus(statusEl, noteId) {
    const statuses = ['Pendiente', 'En curso', 'Hecho'];
    const current = statusEl.textContent;
    const index = statuses.indexOf(current);
    const next = statuses[(index + 1) % statuses.length];
    statusEl.textContent = next;
    saveNotePosition(noteId);
}

async function saveNotePosition(noteId) {
    const noteEl = document.querySelector(`[data-id="${noteId}"]`);
    if (!noteEl) return;

    const title = noteEl.querySelector('.note-title').textContent;
    const text = noteEl.querySelector('.note-text').textContent;
    const status = noteEl.querySelector('.note-status').textContent;
    const position_x = parseInt(noteEl.style.left);
    const position_y = parseInt(noteEl.style.top);

    try {
        const response = await fetch(`${API_BASE}/notes/${noteId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ title, text, status, position_x, position_y })
        });

        if (!response.ok) throw new Error('Error al guardar');

    } catch (error) {
        console.error('Error:', error);
        alert('Error al guardar los cambios');
        loadNotes();
    }
}

function editNote(noteId) {
    currentNoteId = noteId;
    const noteEl = document.querySelector(`[data-id="${noteId}"]`);

    if (noteEl) {
        document.getElementById('note-title').value = noteEl.querySelector('.note-title').textContent;
        document.getElementById('note-text').value = noteEl.querySelector('.note-text').textContent;
        document.getElementById('note-status').value = noteEl.querySelector('.note-status').textContent;

        document.getElementById('modal-title').textContent = 'Editar Nota';
        openNoteModal();
    }
}

async function handleSaveNote(e) {
    e.preventDefault();

    const title = document.getElementById('note-title').value;
    const text = document.getElementById('note-text').value;
    const status = document.getElementById('note-status').value;

    if (!title.trim()) {
        alert('El título es requerido');
        return;
    }

    try {
        if (currentNoteId) {
            const response = await fetch(`${API_BASE}/notes/${currentNoteId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({ title, text, status })
            });

            if (!response.ok) throw new Error('Error al actualizar');
        } else {
            const response = await fetch(`${API_BASE}/notes`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({
                    title, text, status,
                    position_x: Math.random() * 400,
                    position_y: Math.random() * 300
                })
            });

            if (!response.ok) throw new Error('Error al crear');
        }

        closeNoteModal();
        loadNotes();
        loadMetrics();

    } catch (error) {
        console.error('Error:', error);
        alert('Error al guardar la nota');
    }
}

async function deleteNote(noteId) {
    if (!confirm('¿Está seguro que desea eliminar esta nota?')) return;

    try {
        const response = await fetch(`${API_BASE}/notes/${noteId}`, {
            method: 'DELETE',
            credentials: 'include'
        });

        if (!response.ok) throw new Error('Error al eliminar');

        loadNotes();
        loadMetrics();
    } catch (error) {
        console.error('Error:', error);
        alert('Error al eliminar la nota');
    }
}

function openNoteModal() {
    if (!currentNoteId) {
        document.getElementById('note-form').reset();
        document.getElementById('modal-title').textContent = 'Nueva Nota';
    }
    document.getElementById('note-modal').classList.add('active');
}

function closeNoteModal() {
    document.getElementById('note-modal').classList.remove('active');
    currentNoteId = null;
}

// ============= DASHBOARD =============

async function loadMetrics() {
    try {
        const response = await fetch(`${API_BASE}/dashboard/metrics`, {
            credentials: 'include'
        });

        if (!response.ok) throw new Error('Error al cargar métricas');

        const data = await response.json();

        document.getElementById('total-notes').textContent = data.total;
        document.getElementById('pending-notes').textContent = data.distribution['Pendiente'] || 0;
        document.getElementById('progress-notes').textContent = data.distribution['En curso'] || 0;
        document.getElementById('done-notes').textContent = data.distribution['Hecho'] || 0;

    } catch (error) {
        console.error('Error:', error);
    }
}

// ============= USUARIOS =============

async function loadUsers() {
    try {
        const response = await fetch(`${API_BASE}/users`, {
            credentials: 'include'
        });

        if (!response.ok) throw new Error('Error al cargar usuarios');

        const users = await response.json();
        renderUsers(users);
    } catch (error) {
        console.error('Error:', error);
    }
}

function renderUsers(users) {
    const usersList = document.getElementById('users-list');
    if (!usersList) return;

    usersList.innerHTML = '';

    users.forEach(user => {
        const userCard = document.createElement('div');
        userCard.className = 'user-card';
        userCard.innerHTML = `
            <div class="user-info">
                <div class="user-name">${escapeHtml(user.name)}</div>
                <div class="user-email">${escapeHtml(user.email)}</div>
                <div class="user-details">
                    <span class="user-role">${user.role}</span>
                    <span class="user-detail ${!user.is_active ? 'inactive' : ''}">
                        ${user.is_active ? 'Activo' : 'Inactivo'}
                    </span>
                </div>
            </div>
            <div class="user-actions">
                <button class="btn btn-secondary" onclick="editUser(${user.id})">Editar</button>
            </div>
        `;
        usersList.appendChild(userCard);
    });
}

function editUser(userId) {
    currentUserId = userId;

    fetch(`${API_BASE}/users`, { credentials: 'include' })
    .then(r => r.json())
    .then(users => {
        const user = users.find(u => u.id === userId);
        if (!user) return;

        document.getElementById('user-name').value = user.name;
        document.getElementById('user-email').value = user.email;
        document.getElementById('user-role').value = user.role;
        document.getElementById('user-status').value = user.is_active ? 'true' : 'false';

        document.getElementById('password-group').style.display = 'none';
        document.getElementById('status-group').style.display = 'block';
        document.getElementById('user-modal-title').textContent = 'Editar Usuario';

        openUserModal();
    });
}

async function handleSaveUser(e) {
    e.preventDefault();

    const name = document.getElementById('user-name').value;
    const email = document.getElementById('user-email').value;
    const role = document.getElementById('user-role').value;

    if (!name.trim() || !email.trim()) {
        alert('Nombre y email son requeridos');
        return;
    }

    try {
        if (currentUserId) {
            const is_active = document.getElementById('user-status').value === 'true';

            const response = await fetch(`${API_BASE}/users/${currentUserId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({ name, role, is_active })
            });

            if (!response.ok) {
                const data = await response.json();
                throw new Error(data.error || 'Error al actualizar');
            }
        } else {
            const password = document.getElementById('user-password').value;
            if (!password) {
                alert('La contraseña es requerida');
                return;
            }

            const response = await fetch(`${API_BASE}/users`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({ name, email, password, role })
            });

            if (!response.ok) {
                const data = await response.json();
                throw new Error(data.error || 'Error al crear');
            }
        }

        closeUserModal();
        loadUsers();

    } catch (error) {
        console.error('Error:', error);
        alert(error.message || 'Error al guardar el usuario');
    }
}

function openUserModal() {
    if (!currentUserId) {
        document.getElementById('user-form').reset();
        document.getElementById('password-group').style.display = 'block';
        document.getElementById('status-group').style.display = 'none';
        document.getElementById('user-modal-title').textContent = 'Nuevo Usuario';
    }
    document.getElementById('user-modal').classList.add('active');
}

function closeUserModal() {
    document.getElementById('user-modal').classList.remove('active');
    currentUserId = null;
}

// ============= UTILIDADES =============

function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;', '<': '&lt;', '>': '&gt;',
        '"': '&quot;', "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}
