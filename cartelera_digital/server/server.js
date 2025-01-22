const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const multer = require('multer');
const path = require('path');
const cors = require('cors');
const fs = require('fs');
require('dotenv').config({ path: '../cartelera_digital/.env' });

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: ["http://localhost:3000", "http://localhost", "http://127.0.0.1:3000"],
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true
  }
});

// Configuración de variables de entorno y constantes
const SERVER_IP = process.env.SERVER_IP || 'localhost';
const SERVER_PORT = process.env.SERVER_PORT || 3000;
const SERVER_URL = `http://${SERVER_IP}:${SERVER_PORT}`;

console.log('Servidor configurado con:', {
  SERVER_IP,
  SERVER_PORT,
  SERVER_URL
});

// Configuración de seguridad
const ALLOWED_ORIGINS = [
  'http://localhost:3000',
  'http://127.0.0.1:3000',
  'http://localhost',
  'http://127.0.0.1'
];

// Asegurarse de que los directorios existan
const uploadsDir = path.join(__dirname, 'uploads');
const monitoringDir = path.join(__dirname, 'monitoring');

[uploadsDir, monitoringDir].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Configurar CORS y middleware
app.use(cors({
  origin: function(origin, callback) {
    // Permitir solicitudes sin origen (ej: desde Postman o curl)
    if (!origin) return callback(null, true);
    
    // Verificar si el origen está permitido
    if (ALLOWED_ORIGINS.indexOf(origin) === -1) {
      return callback(new Error('No permitido por CORS'), false);
    }
    return callback(null, true);
  },
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  credentials: true
}));

app.use(express.json());

// Middleware para logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Middleware para manejar nombres de archivo con espacios
app.use((req, res, next) => {
  req.url = decodeURIComponent(req.url);
  next();
});

// Servir archivos estáticos con headers CORS
app.use('/uploads', (req, res, next) => {
  console.log(`Serving static file from uploads: ${req.url}`);
  res.header('Access-Control-Allow-Origin', '*');
  next();
}, express.static(uploadsDir));

app.use('/monitoring', express.static(monitoringDir, {
  setHeaders: (res, filePath) => {
    res.setHeader('Content-Type', 'image/jpeg');
    res.setHeader('Cache-Control', 'no-cache');
  }
}));

// Configurar multer para el manejo de archivos
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadsDir),
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    const sanitizedName = file.originalname.replace(/\s+/g, '_');
    const originalName = encodeURIComponent(sanitizedName);
    cb(null, `${timestamp}-${originalName}`);
  }
});

const upload = multer({ storage: storage });

// Arrays para almacenar datos
let images = [];
let monitoringImages = [];
let uploadStatus = [];

// Cargar imágenes existentes
function loadExistingImages() {
  try {
    const files = fs.readdirSync(uploadsDir);
    images = files.map(fileName => {
      const id = fileName.split('-')[0];
      const url = `http://${SERVER_IP}:${SERVER_PORT}/uploads/${encodeURIComponent(fileName)}`;
      console.log('URL de imagen procesada:', url);
      return {
        id: id,
        title: decodeURIComponent(fileName.substring(fileName.indexOf('-') + 1)),
        imageUrl: url,
        type: 'image'
      };
    });
    console.log('Imágenes cargadas:', images.length);
  } catch (error) {
    console.error('Error cargando imágenes:', error);
  }
}

// Cargar imágenes de monitoreo
function loadMonitoringImages() {
  try {
    const files = fs.readdirSync(monitoringDir);
    monitoringImages = files.map(fileName => {
      const id = fileName.split('_')[0];
      const url = `http://${SERVER_IP}:${SERVER_PORT}/monitoring/${encodeURIComponent(fileName)}`;
      console.log('URL de imagen de monitoreo procesada:', url);
      return {
        id: id,
        title: decodeURIComponent(fileName.substring(fileName.indexOf('_') + 1)),
        imageUrl: url,
        type: 'image'
      };
    });
    console.log('Imágenes de monitoreo cargadas:', monitoringImages.length);
  } catch (error) {
    console.error('Error cargando imágenes de monitoreo:', error);
  }
}

loadExistingImages();
loadMonitoringImages();

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Endpoint para obtener imágenes
app.get('/api/images', (req, res) => {
  res.json(images);
});

// Endpoint para obtener imágenes de monitoreo
app.get('/api/monitoring/images', (req, res) => {
  try {
    const files = fs.readdirSync(monitoringDir);
    const images = files
      .filter(file => /\.(jpg|jpeg|png|gif)$/i.test(file))
      .map(file => {
        const encodedFileName = encodeURIComponent(file);
        return {
          id: path.parse(file).name,
          title: path.parse(file).name,
          path: `/monitoring/${encodedFileName}`,
          type: 'image',
          metadata: {}
        };
      });
    
    console.log('Sending images:', images);
    res.json(images);
  } catch (error) {
    console.error('Error getting monitoring images:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para obtener el estado de monitoreo
app.get('/api/monitoring/status', (req, res) => {
  res.json(uploadStatus);
});

// Endpoint para subir imágenes
app.post('/api/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No se proporcionó ningún archivo' });
  }

  const newImage = {
    id: req.file.filename.split('-')[0],
    title: decodeURIComponent(req.file.originalname),
    imageUrl: `http://${SERVER_IP}:${SERVER_PORT}/uploads/${encodeURIComponent(req.file.filename)}`,
    type: 'image'
  };

  images.push(newImage);
  io.emit('images_updated', images);
  res.json(newImage);
});

// Endpoint para enviar imagen a monitoreo
app.post('/api/monitoring/images', async (req, res) => {
  try {
    console.log('Recibiendo solicitud de monitoreo:', req.body);
    
    const { id, title, imageUrl } = req.body;
    
    // Validar datos requeridos
    if (!id || !title || !imageUrl) {
      console.error('Datos faltantes:', { id, title, imageUrl });
      return res.status(400).json({ error: 'Faltan datos requeridos (id, title, imageUrl)' });
    }

    // Obtener el nombre del archivo original
    const originalFileName = decodeURIComponent(imageUrl.split('/').pop());
    const originalPath = path.join(uploadsDir, originalFileName);
    
    console.log('Buscando archivo original:', {
      originalFileName,
      originalPath,
      exists: fs.existsSync(originalPath)
    });
    
    if (!fs.existsSync(originalPath)) {
      console.error('Archivo no encontrado:', originalPath);
      return res.status(404).json({ error: 'Archivo original no encontrado' });
    }

    // Crear un nombre de archivo seguro para monitoreo
    const fileExtension = path.extname(originalFileName).toLowerCase();
    const timestamp = Date.now();
    const safeFileName = `${timestamp}_${id}${fileExtension}`;
    const monitoringPath = path.join(monitoringDir, safeFileName);
    
    console.log('Copiando archivo:', {
      from: originalPath,
      to: monitoringPath
    });

    // Asegurarse de que el directorio de monitoreo existe
    if (!fs.existsSync(monitoringDir)) {
      console.log('Creando directorio de monitoreo');
      fs.mkdirSync(monitoringDir, { recursive: true });
    }
    
    // Copiar archivo a la carpeta de monitoreo
    fs.copyFileSync(originalPath, monitoringPath);
    console.log('Archivo copiado exitosamente');

    // Crear objeto de estado
    const status = {
      id,
      title,
      path: `/monitoring/${safeFileName}`,
      type: 'image',
      metadata: {
        status: 'active',
        createdAt: new Date().toISOString(),
        originalName: originalFileName
      }
    };

    console.log('Creando registro de estado:', status);

    // Agregar a las listas
    monitoringImages.push(status);
    uploadStatus.push(status);

    // Notificar a todos los clientes
    io.emit('monitoring_updated', { monitoringImages, uploadStatus });
    console.log('Clientes notificados de la actualización');

    res.json(status);
  } catch (error) {
    console.error('Error detallado al procesar imagen para monitoreo:', {
      error: error.message,
      stack: error.stack
    });
    res.status(500).json({ 
      error: 'Error al procesar imagen para monitoreo',
      details: error.message
    });
  }
});

// Endpoint para subir imágenes de monitoreo
app.post('/api/monitoring/upload', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      throw new Error('No file uploaded');
    }

    const imageUrl = `http://${SERVER_IP}:${SERVER_PORT}/monitoring/${req.file.filename}`;
    console.log('File uploaded successfully:', imageUrl);
    
    res.json({
      success: true,
      path: imageUrl
    });
  } catch (error) {
    console.error('Error uploading file:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para actualizar estado de monitoreo
app.patch('/api/monitoring/images/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const imageIndex = monitoringImages.findIndex(img => img.id === id);
    const statusIndex = uploadStatus.findIndex(st => st.id === id);

    if (imageIndex === -1 || statusIndex === -1) {
      return res.status(404).json({ error: 'Imagen no encontrada' });
    }

    // Actualizar estado
    monitoringImages[imageIndex].status = status;
    uploadStatus[statusIndex].status = status;

    // Notificar a todos los clientes
    io.emit('monitoring_updated', { monitoringImages, uploadStatus });

    res.json({ success: true });
  } catch (error) {
    console.error('Error al actualizar estado:', error);
    res.status(500).json({ error: 'Error al actualizar estado' });
  }
});

// Endpoint para eliminar una imagen
app.delete('/api/images/:id', (req, res) => {
  const imageId = req.params.id;
  const imageIndex = images.findIndex(img => img.id === imageId);

  if (imageIndex === -1) {
    return res.status(404).json({ error: 'Imagen no encontrada' });
  }

  const image = images[imageIndex];
  const fileName = decodeURIComponent(image.imageUrl.split('/').pop());
  const filePath = path.join(uploadsDir, fileName);
  
  try {
    fs.unlinkSync(filePath);
    images.splice(imageIndex, 1);
    io.emit('images_updated', images);
    res.json({ success: true });
  } catch (error) {
    console.error('Error al eliminar archivo:', error);
    res.status(500).json({ error: 'Error al eliminar archivo' });
  }
});

// Configurar socket.io para actualizaciones en tiempo real
io.on('connection', (socket) => {
  console.log('Cliente conectado');

  // Enviar datos iniciales
  socket.emit('monitoring_updated', { monitoringImages, uploadStatus });

  socket.on('disconnect', () => {
    console.log('Cliente desconectado');
  });
});

server.listen(SERVER_PORT, SERVER_IP, () => {
  console.log(`Servidor escuchando en ${SERVER_URL}`);
});
