const { createReadStream } = require("fs")

const wordMap = {}

const stream = createReadStream("the_bible")

stream.on("data", chunk => {
  let str = chunk.toString('utf8')
  str = str.replace(/\r\n/g, " ")

  const words = str.split(" ")

  words.forEach(rawWord => {
    let word = rawWord.toLowerCase()
    word = word.trim()

    const lastChar = word[word.length - 1]

    if ([".", ",", ":", ";"].includes(lastChar)) {
      word = word.slice(0, -1); 
    }
 
    const count = wordMap[word]

    if (count) {
      wordMap[word] = count + 1
    } else {
      wordMap[word] = 1
    }
  })
})

stream.on("end", () => {
  console.log(wordMap)
})
