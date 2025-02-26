const express = require('express');
const router = express.Router();
const fs = require('fs').promises;
const path = require('path');

// Ruta al archivo contents.json relativa al directorio del servidor
const CONTENTS_FILE = path.join(__dirname, '..', 'data', 'contents.json');

// Middleware para asegurar que el directorio data existe
router.use(async (req, res, next) => {
    try {
        const dataDir = path.dirname(CONTENTS_FILE);
        await fs.mkdir(dataDir, { recursive: true });
        next();
    } catch (err) {
        next(err);
    }
});

// GET /contents
router.get('/', async (req, res) => {
    console.log('GET /contents - Accedido');
    try {
        const data = await fs.readFile(CONTENTS_FILE, 'utf8');
        const contents = JSON.parse(data);
        res.json(contents);
    } catch (error) {
        if (error.code === 'ENOENT') {
            return res.json([]);
        }
        console.error('Error al obtener contenidos:', error);
        res.status(500).json({ error: error.message });
    }
});

// POST /contents
router.post('/', async (req, res) => {
    console.log('POST /contents - Inicio de la función');
    try {
        console.log('=== POST /contents ===');
        console.log('Headers:', req.headers);
        console.log('Body:', req.body);
        console.log('URL:', req.originalUrl);
        console.log('Path:', req.path);
        
        if (!req.body || !req.body.imageUrl) {
            console.error('Error: No se recibió imageUrl en el body');
            return res.status(400).json({ error: 'Se requiere imageUrl en el body' });
        }
        
        let contents = [];
        try {
            const data = await fs.readFile(CONTENTS_FILE, 'utf8');
            contents = JSON.parse(data);
        } catch (err) {
            if (err.code !== 'ENOENT') {
                throw err;
            }
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
        
        console.log('Guardando nuevo contenido:', newContent);
        contents.push(newContent);
        
        await fs.writeFile(CONTENTS_FILE, JSON.stringify(contents, null, 2));
        console.log('Contenido guardado exitosamente');
        
        res.status(201).json(newContent);
    } catch (error) {
        console.error('Error detallado al guardar contenido:', error);
        res.status(500).json({ error: error.message });
    }
});

// PATCH /contents/:id/status
router.patch('/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        if (!status) {
            return res.status(400).json({ error: 'Se requiere status en el body' });
        }

        const data = await fs.readFile(CONTENTS_FILE, 'utf8');
        const contents = JSON.parse(data);
        
        const contentIndex = contents.findIndex(c => c.id === id);
        if (contentIndex === -1) {
            return res.status(404).json({ error: 'Contenido no encontrado' });
        }

        contents[contentIndex].status = status;
        await fs.writeFile(CONTENTS_FILE, JSON.stringify(contents, null, 2));
        
        res.json(contents[contentIndex]);
    } catch (error) {
        console.error('Error al actualizar estado:', error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router; 