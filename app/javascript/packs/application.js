// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import '../css/main.scss'
require.context('../img', true)

$(document).on('turbolinks:load', function () {
    $('.alert.alert-dismissible').click(function () {
        this.remove()
    })

    $('[data-toggle="tooltip"]').tooltip()

    $('.markdown-content table:not(.style-as-is)').addClass('table table-striped table-hover')
    $('.markdown-content table thead:not(.style-as-is)').addClass('thead-dark')
    $('.markdown-content table thead tr th:not(.style-as-is)').attr('scope', 'col')
})
