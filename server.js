
// Framework Rest
const express = require('express');
const app = express();

const bodyParser = require('body-parser');
const uuid = require('uuid');

// Json Web Token
const jwt = require('jsonwebtoken');

//SECRET
const SEGREDO = 'SECRET';

// DAO das Tasks
const taskDAO = require('./taskDAO');


// Habilita JSON no response
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Adiciona Interceptor nas requisicoes
app.use(cobrarTokenJWT)


let tasks = [];

function cobrarTokenJWT(req, resp, next) {
    if (req.url == '/login' || req.url == "/") {
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

// endpoints
app.get("/", (request, response) => {
    response.send({ 'message': 'ok' });
});

app.post('/login', (req, resp) => {
    var body = req.body;
    if (body.username == 'usuario' && body.password == '123456') {
        var token = jwt.sign({ username: 'usuario', role: 'admin' }, SEGREDO, {
            expiresIn: '1d'
        });
        resp.send({ token });
    } else {
        resp.status(401).send({ message: 'Error in username or password' });
    }
})

app.get('/tasks', (request, response) => {

    taskDAO.findAll((error, tasks) => {
        if (error) {
            console.log(error);
            response.status(500).send();
        } else {
            response.send(tasks);
        }
    });

});

app.post('/tasks', (request, response) => {
    const body = request.body;

    if (isValid(body)) {
        const task = {
            title: body.title,
            description: body.description,
            isDone: body.isDone,
            isPriority: body.isPriority
        };

        taskDAO.save(task, (error, saved) => {
            if (error) {
                console.log(error);
            } else {
                response.status(201).send(saved);
            }
        });

    } else {
        response.status(400).send({ message: 'Body inválido' });
    }
});

app.get('/tasks/:id', (request, response) => {
    taskDAO.save(function (error, saved) {
        if (error) {
            response.status(500).send();
        } else {
            response.status(201).send(saved);
        }
    });
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

taskDAO.init(function (error, data) {
    let porta = 3000;
    if (error) {
        console.log("Erro ao criar banco de dados");
        console.log(error);
    } else {
        app.listen(porta, () => {
            console.log(`Servidor rodando na porta ${porta}`)
        });
    }
});
