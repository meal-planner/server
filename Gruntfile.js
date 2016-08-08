'use strict';

module.exports = function (grunt) {
    // Time how long tasks take. Can help when optimizing build times
    require('time-grunt')(grunt);

    grunt.initConfig({
        apidoc: {
            myapp: {
                src: "app/",
                dest: "_doc/"
            }
        },
        buildcontrol: {
            options: {
                dir: '_doc',
                commit: true,
                push: true,
                message: 'Built Meal Planner API docs from commit %sourceCommit% on branch %sourceBranch%'
            },
            github: {
                options: {
                    remote: 'git@github.com:meal-planner/server.git',
                    branch: 'gh-pages'
                }
            }
        },
    });

    grunt.registerTask('deploy-doc', [
        'apidoc',
        'buildcontrol:github'
    ]);

    grunt.loadNpmTasks('grunt-apidoc');
    grunt.loadNpmTasks('grunt-build-control');
};
