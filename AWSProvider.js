const AWS = require('aws-sdk');
AWS.config.update({
	region: 'sa-east-1',
	accessKeyId: 'accessKeyId',
	secretAccessKey: 'secretAccessKey',
	endpoint: 'http://127.0.0.1:8000'
});
module.exports = AWS;
