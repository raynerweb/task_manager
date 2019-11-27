
// Framework Rest
const express = require('express');
const app = express();

const bodyParser = require('body-parser');
const uuid = require('uuid');

// Json Web Token
const jwt = require('jsonwebtoken');

//SECRET
const SEGREDO = 'SECRET';


// Habilita JSON no response
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Adiciona Interceptor nas requisicoes
app.use(cobrarTokenJWT)


let tasks = [];

function cobrarTokenJWT(req, resp, next) {
    if (req.url == '/login') {
        next();
        return;
    }
    var token = req.headers['x-access-token'];
    try {
        var decodificado = jwt.verify(token, SEGREDO);
        console.log(`${JSON.stringify(decodificado)}`);
        next();
    } catch (e) {
        resp.status(500).send({ message: 'token invalido' })
    }
}

app.post('/login', (req, resp) => {
    var body = req.body;
    if (body.username == 'usuario' && body.password == 'teste123') {
        var token = jwt.sign({ username: 'usuario', role: 'admin' }, SEGREDO, {
            expiresIn: '1h'
        });
        resp.send({ auth: true, token });
    } else {
        resp.status(401).send({ auth: false, message: 'usuario invalido' });
    }
})


// endpoints
app.get('/tasks', (request, response) => {
    response.send(tasks);
});

app.get('/tasks/:id', (request, response) => {
    const task = tasks.find(t => t.id == request.params.id);
    if (task) {
        response.status(200).send(task);
    } else {
        response.status(404).send();
    }
});

app.post('/tasks', (request, response) => {
    const body = request.body;
    
    if (isValid(body)) {
        console.log('valid');
        const task = {
            id: uuid(),
            title: body.title,
            description: body.description,
            isDone: body.isDone,
            isPriority: body.isPriority
        };
        tasks.push(task);
        response.status(201);
        response.send(task);
    } else {
        response.status(400).send({ message: 'Body inválido' });
    }
});

app.put('/tasks/:id', (request, response) => {
    const { body } = request;

    if (!isValid(body)) {
        response.status(400).send({ message: 'Body inválido' });
        return;
    }

    const task = tasks.find(t => t.id == request.params.id);
    if (task) {
        task.title = body.title;
        task.description = body.description;
        task.isDone = body.isDone;
        task.isPriority = body.isPriority;
        response.send(task);
    } else {
        response.status(404);
        response.send();
    }
});

app.delete('/tasks/:id', (request, response) => {
    var task = tasks.find(t => t.id == request.params.id);
    if (task) {
        tasks = tasks.filter(t => t.id != request.params.id);
        response.status(200).send();
    } else {
        response.status(404).send();
    }
});

function isValid(body) {
    let attributes = ['title', 'description', 'isDone', 'isPriority']
    let valid = true;
    if (body) {
        for (let i = 0; i < attributes.length; i++) {
            valid = valid && body.hasOwnProperty(attributes[i])
        }
    }
    // console.log(`isValid: ${valid}`);
    return valid;
}


// Inicia Servidor na porta 3000
app.listen(3000);