module.exports = (grunt) ->
  ssh_opts = grunt.file.readJSON "ssh.json"

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    coffeelint:
      app: ["*.coffee", "assets/js/*.coffee"]
      options: grunt.file.readJSON(".coffeelintrc")

    sftp:
      keys:
        files:
          "./": "keys,js"

        options:
          path: "app-root/data/"
          host: ssh_opts.host
          username: ssh_opts.user
          privateKey: ssh_opts.key

    sshexec:
      keys:
        command: "cd appt-root/runtime/repo;ln -s ../../data/keys.js ."
        options:
          host: ssh_opts.host
          username: ssh_opts.user
          privateKey: ssh_opts.key

  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-ssh"

  grunt.registerTask "default", ["coffeelint"]
