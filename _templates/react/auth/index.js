module.exports = {
  prompt: ({ prompter, args }) =>
    prompter
      .prompt({
        type: 'input',
        name: 'hasSrc',
        message: "Do you want to use /src folder? (y/N)"
      })
      .then(({ hasSrc }) => {
        if(hasSrc.toUpperCase() == 'Y') return Promise.resolve({path: null})
        return prompter.prompt({
          type: 'input',
          name: 'path',
          message: `Please enter your target path`
        })

      }
      )
}