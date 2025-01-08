const express = require('express');
const app = express();
const port = 80;

app.use(express.json());

// Ruta de salud
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok', message: 'API is running' });
});

// Ejemplo de una API REST básica
app.get('/api/info', (req, res) => {
    res.json({
        service: 'Demo API',
        version: '1.0.0',
        timestamp: new Date()
    });
});

app.get('/api/hello', (req, res) => {
    res.json({
        message: 'Hello, DevOps!'
    });
});

app.listen(port, () => {
    console.log(`API running on port ${port}`);
});