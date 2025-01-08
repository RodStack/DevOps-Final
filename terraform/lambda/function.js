exports.handler = async (event, context) => {
    try {
        // Procesar el mensaje de SQS
        const records = event.Records || [];
        
        for (const record of records) {
            const message = JSON.parse(record.body);
            console.log('Procesando mensaje:', message);
            
            // Crear el mensaje para SNS
            const snsMessage = {
                default: `Alerta procesada: ${JSON.stringify(message)}`,
                email: `Nueva alerta recibida:\nTipo: ${message.type}\nMensaje: ${message.message}\nTimestamp: ${message.timestamp}`
            };
            
            // Publicar en SNS
            const AWS = require('aws-sdk');
            const sns = new AWS.SNS();
            
            await sns.publish({
                TopicArn: process.env.SNS_TOPIC_ARN,
                Message: JSON.stringify(snsMessage),
                MessageStructure: 'json'
            }).promise();
        }
        
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Mensajes procesados exitosamente' })
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Error al procesar mensajes' })
        };
    }
};
