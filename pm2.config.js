module.exports = {
    apps: [
        {
            name:           "Apsalus-App",
            cwd:            "/home/node/app/apsalus-app-next",
            script:         "app.js",
            instances:      "2",
            exec_mode:      "cluster",
            watch:          false,
            env: {
                PORT:       1337,
                NODE_ENV:   "production"
            },
        },
    ]
}
