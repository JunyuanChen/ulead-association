// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import 'bootstrap'
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import '../css/main.scss'

require.context('../img', true)


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

$(document).on('turbolinks:load', function () {
    $('.alert.alert-dismissible').click(function () {
        this.remove();
    })

    // Style markdown content with reasonable defaults
    $('.markdown-content table:not(.style-as-is)').addClass('table table-striped table-hover')
    $('.markdown-content table:not(.style-as-is) thead:not(.style-as-is)').addClass('thead-dark')
    $('.markdown-content table:not(.style-as-is) thead:not(.style-as-is) tr:not(.style-as-is) th:not(.style-as-is)').attr('scope', 'col')
})
