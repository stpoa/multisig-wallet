module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  },
  test_file_extension_regexp: /.*\.(js|ts|es|es6|jsx|sol)$/,
};
