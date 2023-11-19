# Docker.StaticNode
A tiny Docker image for running a script using Node.js.

## Usage
Add necessary files to `/app` folder with the entry point being named `index.js`.

Example:
```javascript
const http = require('http');

const server = http.createServer((request, response) => {
    response.writeHead(200);
    response.end('Hello, World!');
});
server.listen(8080, '0.0.0.0');
```
```
docker run -d -p 8080:8080 -v ./index.js:/app/index.js:ro ghcr.io/teddybeermaniac/docker.staticnode:latest
```
```
$ curl http://localhost:8080
Hello, World!
```
