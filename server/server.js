const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const multer = require('multer');
const path = require('path');
const cors = require('cors');
const fs = require('fs');
const fsPromises = require('fs').promises;
require('dotenv').config({ path: '../cartelera_digital/.env' });

const app = express();
const server = http.createServer(app);

// Configuración de variables de entorno y constantes
const SERVER_IP = process.env.SERVER_IP || 'localhost';
const SERVER_PORT = process.env.SERVER_PORT || 3000;
const SERVER_URL = `http://${SERVER_IP}:${SERVER_PORT}`;

console.log('Servidor configurado con:', {
  SERVER_IP,
  SERVER_PORT,
  SERVER_URL
});

// Asegurarse de que los directorios existan
const uploadsDir = path.join(__dirname, 'uploads');
const monitoringDir = path.join(__dirname, 'monitoring');
const mobileDir = path.join(__dirname, 'mobile', 'images');  // Cambiado para incluir /images
const dataDir = path.join(__dirname, 'data');

[uploadsDir, monitoringDir, mobileDir, dataDir].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`Directorio creado: ${dir}`);
  }
});

// Configuración básica de CORS
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  
  // Handle preflight
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Configurar socket.io con CORS
const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    credentials: true
  }
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Middleware para logging
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Middleware para manejar nombres de archivo con espacios
app.use((req, res, next) => {
  req.url = decodeURIComponent(req.url);
  next();
});

// Servir archivos estáticos
app.use('/uploads', express.static(uploadsDir));
app.use('/monitoring', express.static(monitoringDir));
app.use('/mobile/images', express.static(mobileDir));  // Cambiado para coincidir con la ruta de la API

// Configuración de multer para manejo de archivos
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1E9)}`;
    cb(null, `${uniqueSuffix}-${file.originalname}`);
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB límite
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Tipo de archivo no soportado'));
    }
  }
});

// Arrays para almacenar datos
let images = [];
let monitoringImages = [];  // Imágenes para la aplicación de monitoreo
let mobileImages = [];      // Imágenes para la aplicación móvil
let uploadStatus = [];

// Cargar imágenes existentes
function loadExistingImages() {
  try {
    const files = fs.readdirSync(uploadsDir);
    images = files.map(fileName => {
      const id = fileName.split('-')[0];
      const url = `${SERVER_URL}/uploads/${encodeURIComponent(fileName)}`;
      return {
        id: id,
        title: fileName.substring(fileName.indexOf('-') + 1),
        imageUrl: url,
        type: 'image',
        isActive: true
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
      const url = `${SERVER_URL}/monitoring/${encodeURIComponent(fileName)}`;
      console.log('URL de imagen de monitoreo procesada:', url);
      console.log('ID de imagen:', id);
      return {
        id: id,
        title: decodeURIComponent(fileName.substring(fileName.indexOf('_') + 1)),
        path: `monitoring/${fileName}`,
        imageUrl: url,
        type: 'image',
        status: 'active',
        metadata: {
          uploadedAt: new Date().toISOString(),
          status: 'active'
        }
      };
    });
    console.log('Imágenes de monitoreo cargadas:', monitoringImages.length);
    console.log('IDs disponibles:', monitoringImages.map(img => img.id));
  } catch (error) {
    console.error('Error cargando imágenes de monitoreo:', error);
  }
}

// Cargar imágenes móviles
function loadMobileImages() {
  try {
    const files = fs.readdirSync(mobileDir);
    mobileImages = files.map(fileName => {
      const id = fileName.split('_')[0];
      const url = `${SERVER_URL}/mobile/${encodeURIComponent(fileName)}`;
      console.log('URL de imagen móvil procesada:', url);
      return {
        id: id,
        title: decodeURIComponent(fileName.substring(fileName.indexOf('_') + 1)),
        imageUrl: url,
        type: 'image',
        isActive: true
      };
    });
    console.log('Imágenes móviles cargadas:', mobileImages.length);
  } catch (error) {
    console.error('Error cargando imágenes móviles:', error);
  }
}

loadExistingImages();
loadMonitoringImages();
loadMobileImages();

// Health check endpoint
app.get('/api/health', (req, res) => {
  console.log('Health check request received');
  res.json({
    status: 'ok',
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

// Endpoint para obtener imágenes
app.get('/api/images', (req, res) => {
  console.log('Request received for images');
  try {
    const formattedImages = images.map(img => ({
      id: img.id,
      title: img.title,
      imageUrl: img.imageUrl,
      type: img.type || 'image',
      isActive: img.isActive || true
    }));
    
    console.log(`Sending ${formattedImages.length} images`);
    res.json(formattedImages);
  } catch (error) {
    console.error('Error getting images:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Endpoint para obtener imágenes de monitoreo
app.get('/api/monitoring/images', (req, res) => {
  try {
    console.log('GET /api/monitoring/images');
    console.log('Imágenes de monitoreo disponibles:', monitoringImages.length);
    res.json(monitoringImages);
  } catch (error) {
    console.error('Error al obtener imágenes de monitoreo:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para obtener imágenes móviles
app.get('/api/mobile/images', (req, res) => {
  try {
    res.json(mobileImages);
  } catch (error) {
    console.error('Error getting mobile images:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para obtener estado de subidas
app.get('/api/monitoring/status', (req, res) => {
  try {
    console.log('GET /api/monitoring/status');
    console.log('Estados de subida disponibles:', uploadStatus.length);
    res.json(uploadStatus);
  } catch (error) {
    console.error('Error al obtener estados de subida:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para obtener todos los contenidos
app.get('/api', (req, res) => {
  console.log('Request received for all contents');
  try {
    res.json(images);
  } catch (error) {
    console.error('Error getting contents:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Endpoint para subir contenido
app.post('/api/contents', async (req, res) => {
  try {
    console.log('POST /api/contents - Body:', req.body);
    
    if (!req.body || !req.body.imageUrl) {
      return res.status(400).json({ error: 'Se requiere imageUrl en el body' });
    }

    // Obtener el nombre del archivo de la URL
    const sourceFileName = decodeURIComponent(req.body.imageUrl.split('/').pop());
    console.log('Nombre del archivo fuente:', sourceFileName);

    // Construir la ruta del archivo fuente en la carpeta de monitoreo
    const sourceFilePath = path.join(monitoringDir, sourceFileName);
    console.log('Ruta del archivo fuente:', sourceFilePath);

    // Verificar si el archivo existe
    try {
      await fsPromises.access(sourceFilePath);
    } catch (error) {
      console.error('Archivo no encontrado:', sourceFilePath);
      return res.status(404).json({ error: 'Archivo no encontrado en monitoreo' });
    }

    // Crear un nuevo nombre para el archivo en la carpeta móvil
    const newFileName = `mobile_${Date.now()}_${path.basename(sourceFileName)}`;
    const targetFilePath = path.join(mobileDir, newFileName);
    console.log('Ruta del archivo destino:', targetFilePath);

    // Asegurarse de que el directorio móvil existe
    await fsPromises.mkdir(mobileDir, { recursive: true });

    // Copiar el archivo
    await fsPromises.copyFile(sourceFilePath, targetFilePath);

    // Crear el nuevo contenido
    const newContent = {
      id: req.body.id || `mobile_${Date.now()}`,
      title: req.body.title || path.basename(sourceFileName),
      imageUrl: `${SERVER_URL}/mobile/${encodeURIComponent(newFileName)}`,
      type: req.body.type || 'image',
      metadata: req.body.metadata || {},
      uploadedAt: new Date().toISOString(),
      status: 'active'
    };

    // Agregar a la lista de imágenes móviles
    mobileImages.push(newContent);

    // Notificar a los clientes conectados
    io.emit('mobile_images_updated', mobileImages);

    console.log('Contenido creado exitosamente:', newContent);
    res.status(201).json(newContent);
  } catch (error) {
    console.error('Error al guardar contenido:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para actualizar estado de imagen
app.patch('/api/monitoring/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    // Encontrar la imagen
    const imageIndex = monitoringImages.findIndex(img => img.id === id);
    if (imageIndex === -1) {
      return res.status(404).json({ error: 'Imagen no encontrada' });
    }

    // Actualizar estado
    monitoringImages[imageIndex] = {
      ...monitoringImages[imageIndex],
      status: status,
      updatedAt: new Date().toISOString()
    };

    // Notificar a los clientes conectados
    io.emit('monitoring_updated', { monitoringImages, uploadStatus });

    res.status(200).json(monitoringImages[imageIndex]);
  } catch (error) {
    console.error('Error al actualizar estado:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para subir imágenes
app.post('/api/upload', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No se proporcionó ningún archivo' });
    }

    const newImage = {
      id: `${Date.now()}`,
      title: req.body.title || decodeURIComponent(req.file.originalname),
      imageUrl: `${SERVER_URL}/uploads/${encodeURIComponent(req.file.filename)}`,
      description: req.body.description || '',
      path: `/uploads/${req.file.filename}`,
      type: 'image',
      metadata: {
        size: req.file.size,
        mimetype: req.file.mimetype,
        uploadedAt: new Date().toISOString()
      },
      uploadedAt: new Date().toISOString(),
      startDate: new Date().toISOString(),
      endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
      isActive: true
    };

    images.push(newImage);
    io.emit('images_updated', images);
    res.status(201).json(newImage);
  } catch (error) {
    console.error('Error en upload:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para agregar imágenes a monitoreo
app.post('/api/monitoring/images', async (req, res) => {
  try {
    console.log('POST /api/monitoring/images - Body:', req.body);
    console.log('Headers:', req.headers);
    
    if (!req.body || !req.body.imageUrl) {
      console.error('Error: imageUrl no proporcionada');
      return res.status(400).json({ error: 'Se requiere imageUrl en el body' });
    }

    // Extraer el ID y la URL de la imagen original
    const imageId = req.body.id;
    const originalUrl = req.body.imageUrl;
    console.log('ID de imagen:', imageId);
    console.log('URL original:', originalUrl);

    // Verificar que la URL sea válida
    if (!originalUrl.startsWith('http') && !originalUrl.startsWith('/uploads/')) {
      console.error('URL inválida:', originalUrl);
      return res.status(400).json({ error: 'URL de imagen inválida' });
    }

    // Obtener el nombre del archivo original
    const fileName = decodeURIComponent(originalUrl.split('/').pop());
    console.log('Nombre del archivo:', fileName);

    // Construir las rutas
    const sourceFilePath = path.join(uploadsDir, fileName);
    const targetFileName = `${imageId}_${fileName}`;
    const targetFilePath = path.join(monitoringDir, targetFileName);

    console.log('Ruta origen:', sourceFilePath);
    console.log('Ruta destino:', targetFilePath);

    // Verificar si el archivo existe
    try {
      await fsPromises.access(sourceFilePath);
      console.log('Archivo encontrado en:', sourceFilePath);
    } catch (error) {
      console.error('Archivo no encontrado:', sourceFilePath);
      console.error('Error completo:', error);
      return res.status(404).json({ 
        error: 'Archivo no encontrado en uploads',
        details: {
          sourceFilePath,
          originalUrl,
          fileName
        }
      });
    }

    // Asegurarse de que el directorio de monitoreo existe
    await fsPromises.mkdir(monitoringDir, { recursive: true });
    console.log('Directorio de monitoreo verificado');

    // Copiar el archivo
    try {
      await fsPromises.copyFile(sourceFilePath, targetFilePath);
      console.log('Archivo copiado exitosamente');
    } catch (error) {
      console.error('Error al copiar archivo:', error);
      return res.status(500).json({ 
        error: 'Error al copiar archivo',
        details: error.message
      });
    }

    // Crear el nuevo contenido
    const newContent = {
      id: imageId,
      title: req.body.title || fileName,
      path: `monitoring/${targetFileName}`,
      imageUrl: `${SERVER_URL}/monitoring/${encodeURIComponent(targetFileName)}`,
      type: req.body.type || 'image',
      status: 'active',
      metadata: {
        ...req.body.metadata,
        originalPath: originalUrl,
        uploadedAt: new Date().toISOString(),
      },
    };

    // Agregar a la lista de imágenes de monitoreo
    monitoringImages.push(newContent);

    // Agregar al estado de subida
    const uploadStatusItem = {
      id: imageId,
      fileName: fileName,
      status: 'active',
      timestamp: new Date(),
      type: 'image',
      progress: 100,
    };
    uploadStatus.push(uploadStatusItem);

    // Notificar a los clientes conectados
    io.emit('monitoring_updated', { 
      monitoringImages, 
      uploadStatus,
      newImage: newContent 
    });

    console.log('Contenido creado exitosamente:', newContent);
    res.status(201).json(newContent);
  } catch (error) {
    console.error('Error al guardar contenido:', error);
    res.status(500).json({ 
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
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
    
    console.log('PATCH /api/monitoring/images/:id', {
      id,
      status,
      availableImages: monitoringImages.map(img => img.id),
      requestBody: req.body
    });

    // Buscar la imagen en el array de monitoreo
    const imageIndex = monitoringImages.findIndex(img => img.id === id);
    console.log('Índice de imagen encontrado:', imageIndex);

    if (imageIndex === -1) {
      console.error('Imagen no encontrada:', id);
      console.log('Imágenes disponibles:', monitoringImages.map(img => ({id: img.id, title: img.title})));
      return res.status(404).json({ 
        error: 'Imagen no encontrada',
        details: {
          requestedId: id,
          availableIds: monitoringImages.map(img => img.id)
        }
      });
    }

    // Actualizar estado de la imagen
    monitoringImages[imageIndex] = {
      ...monitoringImages[imageIndex],
      status: status,
      metadata: {
        ...monitoringImages[imageIndex].metadata,
        lastUpdated: new Date().toISOString(),
        previousStatus: monitoringImages[imageIndex].status
      }
    };

    // Actualizar estado en uploadStatus si existe
    const statusIndex = uploadStatus.findIndex(st => st.id === id);
    if (statusIndex !== -1) {
      uploadStatus[statusIndex] = {
        ...uploadStatus[statusIndex],
        status: status,
        timestamp: new Date()
      };
    } else {
      // Si no existe, crear nuevo estado
      uploadStatus.push({
        id: id,
        fileName: monitoringImages[imageIndex].title,
        status: status,
        timestamp: new Date(),
        type: 'image',
        progress: 100
      });
    }

    // Notificar a todos los clientes
    io.emit('monitoring_updated', { 
      monitoringImages, 
      uploadStatus,
      updatedImage: monitoringImages[imageIndex]
    });

    console.log('Estado actualizado exitosamente:', {
      id,
      newStatus: status,
      image: monitoringImages[imageIndex]
    });

    res.json({ 
      success: true,
      image: monitoringImages[imageIndex],
      status: status
    });
  } catch (error) {
    console.error('Error al actualizar estado:', error);
    res.status(500).json({ 
      error: 'Error al actualizar estado',
      details: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
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

// Endpoint para eliminar una imagen de monitoreo
app.delete('/api/monitoring/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log('Eliminando imagen de monitoreo:', id);

    // Encontrar la imagen en el array
    const imageIndex = monitoringImages.findIndex(img => img.id === id);
    if (imageIndex === -1) {
      console.log('Imagen no encontrada en el array:', id);
      return res.status(404).json({ error: 'Imagen no encontrada' });
    }

    // Obtener la información de la imagen
    const image = monitoringImages[imageIndex];
    const fileName = image.path.split('/').pop();
    const filePath = path.join(monitoringDir, fileName);

    console.log('Ruta del archivo a eliminar:', filePath);

    // Verificar si el archivo existe
    try {
      await fsPromises.access(filePath);
    } catch (error) {
      console.error('Archivo no encontrado en el sistema:', filePath);
      // Aún si el archivo no existe, eliminamos la referencia del array
      monitoringImages.splice(imageIndex, 1);
      io.emit('monitoring_updated', { monitoringImages, uploadStatus });
      return res.status(200).json({ success: true, message: 'Referencia eliminada' });
    }

    // Eliminar el archivo
    try {
      await fsPromises.unlink(filePath);
      console.log('Archivo eliminado exitosamente:', filePath);
    } catch (error) {
      console.error('Error al eliminar archivo:', error);
      return res.status(500).json({ error: 'Error al eliminar archivo' });
    }

    // Eliminar la imagen del array
    monitoringImages.splice(imageIndex, 1);

    // Eliminar el estado de subida relacionado
    const statusIndex = uploadStatus.findIndex(status => status.id === id);
    if (statusIndex !== -1) {
      uploadStatus.splice(statusIndex, 1);
    }

    // Notificar a los clientes
    io.emit('monitoring_updated', { monitoringImages, uploadStatus });

    console.log('Imagen eliminada exitosamente');
    res.json({ success: true });
  } catch (error) {
    console.error('Error al eliminar imagen:', error);
    res.status(500).json({ error: error.message });
  }
});

// Eliminar múltiples imágenes
app.post('/api/monitoring/delete-multiple', async (req, res) => {
  try {
    const { ids } = req.body;
    console.log('Intentando eliminar múltiples imágenes:', ids);
    
    if (!Array.isArray(ids)) {
      return res.status(400).json({ error: 'Se requiere un array de IDs' });
    }
    
    const files = await fsPromises.readdir(monitoringDir);
    console.log('Archivos disponibles:', files);
    
    const results = await Promise.all(
      ids.map(async (id) => {
        try {
          const imageFile = files.find(file => file.startsWith(id));
          if (!imageFile) {
            return { id, success: false, error: 'Imagen no encontrada' };
          }
          
          const imagePath = path.join(monitoringDir, imageFile);
          if (!fs.existsSync(imagePath)) {
            return { id, success: false, error: 'Archivo no existe' };
          }
          
          await fsPromises.unlink(imagePath);
          return { id, success: true };
        } catch (err) {
          return { id, success: false, error: err.message };
        }
      })
    );
    
    const successCount = results.filter(r => r.success).length;
    
    res.json({
      success: true,
      message: `${successCount} de ${ids.length} imágenes eliminadas`,
      results
    });
  } catch (error) {
    console.error('Error al eliminar imágenes:', error);
    res.status(500).json({ 
      error: error.message,
      stack: error.stack
    });
  }
});

// Endpoint para publicar imagen en la app móvil
app.post('/api/mobile/publish', async (req, res) => {
  try {
    const { imageId } = req.body;
    
    // Buscar la imagen en las imágenes de monitoreo
    const sourceImage = monitoringImages.find(img => img.id === imageId);
    if (!sourceImage) {
      return res.status(404).json({ error: 'Imagen no encontrada' });
    }

    // Obtener el nombre del archivo original
    const sourceFileName = path.basename(sourceImage.imageUrl);
    const sourceFilePath = path.join(monitoringDir, sourceFileName);

    // Crear nuevo nombre para la versión móvil
    const newFileName = `mobile_${Date.now()}_${sourceFileName}`;
    const targetFilePath = path.join(mobileDir, newFileName);

    // Copiar el archivo
    await fsPromises.copyFile(sourceFilePath, targetFilePath);

    // Crear nuevo registro para la imagen móvil
    const newMobileImage = {
      id: `mobile_${Date.now()}`,
      title: sourceImage.title,
      imageUrl: `${SERVER_URL}/mobile/${encodeURIComponent(newFileName)}`,
      type: 'image',
      isActive: true,
      publishedAt: new Date().toISOString()
    };

    // Agregar a la lista de imágenes móviles
    mobileImages.push(newMobileImage);

    // Notificar a los clientes conectados
    io.emit('mobile_images_updated', mobileImages);

    res.status(200).json(newMobileImage);
  } catch (error) {
    console.error('Error publishing to mobile:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para despublicar imagen de la app móvil
app.delete('/api/mobile/unpublish/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Encontrar la imagen
    const imageIndex = mobileImages.findIndex(img => img.id === id);
    if (imageIndex === -1) {
      return res.status(404).json({ error: 'Imagen no encontrada' });
    }

    const image = mobileImages[imageIndex];
    const fileName = path.basename(image.imageUrl);
    const filePath = path.join(mobileDir, fileName);

    // Eliminar el archivo
    if (fs.existsSync(filePath)) {
      await fsPromises.unlink(filePath);
    }

    // Eliminar de la lista
    mobileImages.splice(imageIndex, 1);

    // Notificar a los clientes conectados
    io.emit('mobile_images_updated', mobileImages);

    res.status(200).json({ message: 'Imagen despublicada correctamente' });
  } catch (error) {
    console.error('Error unpublishing from mobile:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para agregar imágenes a móvil
app.post('/api/mobile/images', async (req, res) => {
  try {
    console.log('POST /api/mobile/images - Body:', req.body);
    console.log('Headers:', req.headers);
    
    if (!req.body || !req.body.imageUrl) {
      console.error('Error: imageUrl no proporcionada');
      return res.status(400).json({ error: 'Se requiere imageUrl en el body' });
    }

    // Extraer datos necesarios
    const imageId = req.body.id;
    const originalUrl = req.body.imageUrl;
    console.log('ID de imagen:', imageId);
    console.log('URL original:', originalUrl);

    // Obtener el nombre del archivo original
    const fileName = decodeURIComponent(originalUrl.split('/').pop());
    console.log('Nombre del archivo:', fileName);

    // Construir las rutas
    const sourceFilePath = path.join(monitoringDir, fileName);
    const targetFileName = `${imageId}_${fileName}`;
    const targetFilePath = path.join(mobileDir, targetFileName);

    console.log('Ruta origen:', sourceFilePath);
    console.log('Ruta destino:', targetFilePath);

    // Verificar si el archivo existe en monitoreo
    try {
      await fsPromises.access(sourceFilePath);
      console.log('Archivo encontrado en monitoreo:', sourceFilePath);
    } catch (error) {
      console.error('Archivo no encontrado en monitoreo:', sourceFilePath);
      return res.status(404).json({ 
        error: 'Archivo no encontrado en monitoreo',
        details: {
          sourceFilePath,
          originalUrl,
          fileName
        }
      });
    }

    // Asegurarse de que el directorio móvil existe
    await fsPromises.mkdir(mobileDir, { recursive: true });
    console.log('Directorio móvil verificado');

    // Copiar el archivo
    try {
      await fsPromises.copyFile(sourceFilePath, targetFilePath);
      console.log('Archivo copiado exitosamente a móvil');
    } catch (error) {
      console.error('Error al copiar archivo:', error);
      return res.status(500).json({ 
        error: 'Error al copiar archivo',
        details: error.message
      });
    }

    // Crear el nuevo contenido
    const newContent = {
      id: imageId,
      title: req.body.title || fileName,
      path: `mobile/${targetFileName}`,
      imageUrl: `${SERVER_URL}/mobile/${encodeURIComponent(targetFileName)}`,
      type: req.body.type || 'image',
      status: 'active',
      metadata: {
        ...req.body.metadata,
        originalPath: originalUrl,
        uploadedAt: new Date().toISOString(),
      },
    };

    // Agregar a la lista de imágenes móviles
    mobileImages.push(newContent);

    // Notificar a los clientes conectados
    io.emit('mobile_updated', { 
      mobileImages,
      newImage: newContent 
    });

    console.log('Contenido móvil creado exitosamente:', newContent);
    res.status(201).json(newContent);
  } catch (error) {
    console.error('Error al guardar contenido móvil:', error);
    res.status(500).json({ 
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
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

// Iniciar servidor
server.listen(SERVER_PORT, '0.0.0.0', () => {
  console.log(`Servidor escuchando en ${SERVER_URL}`);
  console.log('También disponible en:');
  console.log(`- http://localhost:${SERVER_PORT}`);
  console.log(`- http://127.0.0.1:${SERVER_PORT}`);
  console.log(`- http://${SERVER_IP}:${SERVER_PORT}`);
});
