module.exports = (grunt) ->
  ssh_opts = grunt.file.readJSON "ssh.json"

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    coffeelint:
      app: ["*.coffee", "assets/js/*.coffee"]
      options: grunt.file.readJSON(".coffeelintrc")

    sftp:
      options:
        banner: "Uploading <%= files %> to <%= host %>"
        host: ssh_opts.host
        username: ssh_opts.user
        privateKey: ssh_opts.key
        mkdirs: true

      keys:
        files:
          "./": "keys.js"
        options:
          path: "app-root/data/"

      data:
        files:
          "./import": "csv-only.tar.gz"
        options:
          path: "app-root/data/import/"

    sshexec:
      options:
        banner: "Executing: <%= command %>"
        host: ssh_opts.host
        username: ssh_opts.user
        privateKey: ssh_opts.key

      keys:
        command: "cd appt-root/runtime/repo;ln -s ../../data/keys.js ."

      data:
        command: "cd app-root/data/import; tar -xzf csv-only.tar.gz ."


  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-ssh"

  grunt.registerTask "default", ["coffeelint"]
  grunt.registerTask "keys", ["sftp:keys","sshexec:keys"]
  grunt.registerTask "data", ["sftp:data","sshexec:data"]
  
