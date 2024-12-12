const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    credentials: true
  }
});

app.use(cors());
app.use(express.json());

// Configurar multer para el almacenamiento de imágenes
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/') // Las imágenes se guardarán en la carpeta 'uploads'
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname)) // Nombre único para cada archivo
  }
});

const upload = multer({ storage: storage });

// Servir archivos estáticos
app.use('/uploads', express.static('uploads'));

// Ruta para verificar el estado de la API
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'API funcionando correctamente' });
});

// Ruta para subir imágenes
app.post('/api/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'No se subió ningún archivo' });
  }
  
  const imageUrl = `http://192.168.0.5:3000/uploads/${req.file.filename}`;
  res.json({ imageUrl });
});

// Clave secreta para JWT
const JWT_SECRET = 'tu_clave_secreta';

// Usuarios de prueba
const users = [
  { id: 1, username: 'admin', password: 'admin123' }
];

// Ruta de autenticación
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  const user = users.find(u => u.username === username && u.password === password);
  
  if (user) {
    const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ token });
  } else {
    res.status(401).json({ message: 'Credenciales inválidas' });
  }
});

// Middleware de autenticación
const authenticateToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ message: 'Token no proporcionado' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Token inválido' });
    }
    req.user = user;
    next();
  });
};

// Ruta protegida
app.get('/api/carteleras', authenticateToken, (req, res) => {
  res.json(cartelerasEjemplo);
});

// Datos de ejemplo
const cartelerasEjemplo = [
  {
    id: '1',
    title: 'Evento 1',
    description: 'Descripción del evento 1',
    imageUrl: 'https://ejemplo.com/imagen1.jpg',
    startDate: new Date().toISOString(),
    endDate: new Date(Date.now() + 86400000).toISOString(),
  },
  {
    id: '2',
    title: 'Evento 2',
    description: 'Descripción del evento 2',
    imageUrl: 'https://ejemplo.com/imagen2.jpg',
    startDate: new Date().toISOString(),
    endDate: new Date(Date.now() + 86400000).toISOString(),
  }
];

io.on('connection', (socket) => {
  console.log('👤 Cliente conectado');
  
  // Enviar datos inmediatamente después de la conexión
  socket.emit('carteleras', cartelerasEjemplo);

  // Escuchar para agregar nuevas carteleras
  socket.on('nueva_cartelera', (nuevaCartelera) => {
    cartelerasEjemplo.push(nuevaCartelera);
    io.emit('carteleras', cartelerasEjemplo); // Emitir a todos los clientes
  });

  // Escuchar para eliminar carteleras
  socket.on('eliminar_cartelera', (id) => {
    console.log('Recibida solicitud de eliminación para ID:', id);
    const index = cartelerasEjemplo.findIndex(cartelera => cartelera.id === id);
    console.log('Índice encontrado:', index);
    if (index !== -1) {
      cartelerasEjemplo.splice(index, 1);
      console.log('Cartelera eliminada. Enviando actualización...');
      io.emit('carteleras', cartelerasEjemplo);
    } else {
      console.log('No se encontró la cartelera con ID:', id);
    }
  });

  socket.on('disconnect', () => {
    console.log('👤 Cliente desconectado');
  });
});

const PORT = 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor corriendo en http://0.0.0.0:${PORT}`);
}); 