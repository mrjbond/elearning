const express = require("express");
const { readFile } = require("fs");
const { createHash } = require("crypto");

const app = express();
const port = 3000;

const fileName = "random_bytes";

app.get("/bytes", ({ query }, response) => {
  const { rounds = "10" } = query;
  const roundsArray = [...Array(parseInt(rounds)).keys()];

  // Should really be done via `fs.createReadStream`.
  readFile(fileName, (err, data) => {
    if (err) {
      response.status(500).send("500 Internal Server Error");
    }

    const initialHash = createHash("sha256").update(data).digest();

    const finalHash = roundsArray.reduce((acc, _current) => {
      return createHash("sha256").update(acc).digest();
    }, initialHash);

    response.status(200).send(Buffer.from(finalHash).toString("base64"));
  });
});

app.get("*", (_request, response) => {
  response.status(500).send("500 Internal Server Error");
});

app.listen(port, () => {
  console.log(`Node server running on port ${port}.`);
});
