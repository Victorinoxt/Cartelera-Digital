const fs = require('fs');
const path = require('path');

// Crear la carpeta uploads si no existe
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir);
    console.log('Carpeta uploads creada en:', uploadsDir);
} else {
    console.log('La carpeta uploads ya existe en:', uploadsDir);
}

// Verificar permisos
try {
    const testFile = path.join(uploadsDir, 'test.txt');
    fs.writeFileSync(testFile, 'test');
    fs.unlinkSync(testFile);
    console.log('Permisos de escritura verificados correctamente');
} catch (error) {
    console.error('Error al verificar permisos:', error);
}
