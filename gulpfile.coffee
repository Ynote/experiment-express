gulp    = require 'gulp'
plumber = require('gulp-plumber')
coffee  = require 'gulp-coffee'

coffeePath = 'coffee/**/*.coffee'

gulp.task 'coffee', ->
    gulp.src coffeePath
        .pipe(plumber())
        .pipe(coffee(
            bare: true
        ))
        .pipe(gulp.dest 'public/js')

gulp.task 'default', ->
    gulp.watch coffeePath, ['coffee']
