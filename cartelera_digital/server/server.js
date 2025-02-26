const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const fsPromises = require('fs').promises;

const app = express();

// Configuración del servidor
const SERVER_IP = process.env.SERVER_IP || '192.168.100.13';
const SERVER_PORT = process.env.SERVER_PORT || 3000;
const SERVER_URL = `http://${SERVER_IP}:${SERVER_PORT}`;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Servir archivos estáticos
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/monitoring', express.static(path.join(__dirname, 'monitoring')));

// Asegurar que los directorios existan
const dirs = ['uploads', 'monitoring', 'data'];
dirs.forEach(dir => {
  const dirPath = path.join(__dirname, dir);
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    console.log(`Directorio creado: ${dirPath}`);
  }
});

// Archivo de contenidos
const CONTENTS_FILE = path.join(__dirname, 'data', 'contents.json');
const MONITORING_DIR = path.join(__dirname, 'monitoring');

// Rutas de la API
app.get('/api/contents', async (req, res) => {
  try {
    if (!fsPromises.existsSync(CONTENTS_FILE)) {
      return res.json([]);
    }
    const data = await fsPromises.readFile(CONTENTS_FILE, 'utf8');
    const contents = JSON.parse(data);
    res.json(contents);
  } catch (error) {
    console.error('Error al obtener contenidos:', error);
    res.status(500).json({ error: error.message });
  }
});

// Eliminar una imagen de monitoreo
app.delete('/api/monitoring/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log('Intentando eliminar imagen con ID:', id);
    
    // Leer el directorio de monitoreo
    const monitoringFiles = await fsPromises.readdir(MONITORING_DIR);
    console.log('Archivos en el directorio:', monitoringFiles);
    
    // Buscar el archivo que comience con el ID (sin importar la extensión)
    const imageFile = monitoringFiles.find(file => file.startsWith(id));
    
    if (!imageFile) {
      console.log('Imagen no encontrada. ID:', id);
      return res.status(404).json({ 
        error: 'Imagen no encontrada',
        details: {
          id,
          availableFiles: monitoringFiles
        }
      });
    }
    
    const imagePath = path.join(MONITORING_DIR, imageFile);
    console.log('Eliminando archivo:', imagePath);
    
    // Verificar que el archivo existe antes de intentar eliminarlo
    try {
      await fsPromises.access(imagePath);
    } catch (err) {
      console.log('El archivo no existe:', imagePath);
      return res.status(404).json({ 
        error: 'El archivo no existe',
        details: { path: imagePath }
      });
    }
    
    // Eliminar el archivo
    await fsPromises.unlink(imagePath);
    console.log('Archivo eliminado exitosamente:', imagePath);
    
    res.json({ 
      success: true, 
      message: 'Imagen eliminada correctamente',
      details: {
        id,
        file: imageFile,
        path: imagePath
      }
    });
  } catch (error) {
    console.error('Error al eliminar imagen:', error);
    res.status(500).json({ 
      error: error.message,
      details: error.stack
    });
  }
});

// Eliminar múltiples imágenes de monitoreo
app.post('/api/monitoring/delete-multiple', async (req, res) => {
  try {
    const { ids } = req.body;
    
    if (!Array.isArray(ids)) {
      return res.status(400).json({ error: 'Se requiere un array de IDs' });
    }
    
    const monitoringFiles = await fsPromises.readdir(MONITORING_DIR);
    
    const results = await Promise.allSettled(
      ids.map(async (id) => {
        try {
          // Buscar el archivo que comience con el ID
          const imageFile = monitoringFiles.find(file => file.startsWith(id));
          if (!imageFile) {
            return { id, success: false, error: 'Imagen no encontrada' };
          }
          
          const imagePath = path.join(MONITORING_DIR, imageFile);
          await fsPromises.unlink(imagePath);
          return { id, success: true };
        } catch (err) {
          return { id, success: false, error: err.message };
        }
      })
    );
    
    const successCount = results.filter(r => r.status === 'fulfilled' && r.value.success).length;
    
    res.json({
      success: true,
      message: `${successCount} de ${ids.length} imágenes eliminadas`,
      results: results.map(r => r.status === 'fulfilled' ? r.value : { success: false, error: r.reason })
    });
  } catch (error) {
    console.error('Error al eliminar imágenes:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/contents', async (req, res) => {
  try {
    console.log('POST /api/contents - Body:', req.body);
    
    if (!req.body || !req.body.imageUrl) {
      return res.status(400).json({ error: 'Se requiere imageUrl en el body' });
    }

    let contents = [];
    try {
      if (fsPromises.existsSync(CONTENTS_FILE)) {
        const data = await fsPromises.readFile(CONTENTS_FILE, 'utf8');
        contents = JSON.parse(data);
      }
    } catch (err) {
      console.log('Creando nuevo archivo contents.json');
    }

    const newContent = {
      id: req.body.id || Date.now().toString(),
      title: req.body.title || 'Sin título',
      imageUrl: req.body.imageUrl,
      type: req.body.type || 'image',
      metadata: req.body.metadata || {},
      uploadedAt: new Date().toISOString(),
      status: 'active'
    };

    contents.push(newContent);
    await fsPromises.writeFile(CONTENTS_FILE, JSON.stringify(contents, null, 2));
    res.status(201).json(newContent);
  } catch (error) {
    console.error('Error al guardar contenido:', error);
    res.status(500).json({ error: error.message });
  }
});

app.patch('/api/contents/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ error: 'Se requiere status en el body' });
    }

    if (!fsPromises.existsSync(CONTENTS_FILE)) {
      return res.status(404).json({ error: 'No hay contenidos' });
    }

    const data = await fsPromises.readFile(CONTENTS_FILE, 'utf8');
    const contents = JSON.parse(data);
    
    const contentIndex = contents.findIndex(c => c.id === id);
    if (contentIndex === -1) {
      return res.status(404).json({ error: 'Contenido no encontrado' });
    }

    contents[contentIndex].status = status;
    await fsPromises.writeFile(CONTENTS_FILE, JSON.stringify(contents, null, 2));
    
    res.json(contents[contentIndex]);
  } catch (error) {
    console.error('Error al actualizar estado:', error);
    res.status(500).json({ error: error.message });
  }
});

// Ruta de health check
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Iniciar servidor
app.listen(SERVER_PORT, SERVER_IP, () => {
  console.log('Servidor configurado con:', {
    SERVER_IP,
    SERVER_PORT,
    SERVER_URL
  });
  console.log(`Servidor escuchando en ${SERVER_URL}`);
}); 