const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    allowedHeaders: ["*"],
    credentials: false
  }
});

// Ruta de prueba
app.get('/api/carteleras', (req, res) => {
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

  socket.on('disconnect', () => {
    console.log('👤 Cliente desconectado');
  });
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
}); 