const path = require("path")
const express = require('express')

const app = express()
const port = 8888

// 首页
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname + '/index.html'));
})

app.listen(port, () => console.log(`Example app listening on port ${port}!`))