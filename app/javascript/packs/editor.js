import Compressor from 'compressorjs'
import tabOverride from 'taboverride'

function resizeTextarea(area) {
    area.style.height = area.scrollHeight + 'px'
}

function uploadFile(file, textarea) {
    var data = new FormData()
    data.append($('meta[name="csrf-param"]')[0].content,
                $('meta[name="csrf-token"]')[0].content)
    data.append('file', file)

    $.ajax({
        type: 'POST',
        enctype: 'multipart/form-data',
        url: '/resources/upload',
        data: data,
        processData: false,
        contentType: false,
        success: (data) => {
            var caret = textarea.selectionStart
            var before = textarea.value.slice(0, caret)
            var after = textarea.value.slice(textarea.selectionEnd)
            textarea.value = `${before}![](${data})${after}`
            textarea.selectionStart = textarea.selectionEnd = caret + 2
            $(textarea).trigger('input')
        }
    })
}

function downSizeFile(file, callback) {
    if (file.type.startsWith('image/')) {
        new Compressor(file, {
            quality: 0.6,
            maxWidth: 2048,
            success: callback,
            error: () => {
                callback(file)
            }
        })
    } else {
        callback(file)
    }
}

$(document).on('turbolinks:load', () => {
    tabOverride.tabSize(2);

    $('.editor-textarea').each(function () {
        resizeTextarea(this)
        tabOverride.set(this)
    }).on('input', function () {
        resizeTextarea(this)
    })

    $('.paste-file-upload').on('paste', function (event) {
        var clipboard = (event.clipboardData || event.originalEvent.clipboardData).items;
        for (let item of clipboard) {
            if (item.kind === 'file') {
                downSizeFile(item.getAsFile(), (file) => {
                    uploadFile(file, this)
                })
            }
        }
    }).on('keyup', function (event) {
        if (event.ctrlKey && event.altKey && event.key === 'u') {
            event.preventDefault()
            var that = this
            $('#file_upload_tag')[0].onchange = function () {
                if (this.files[0]) {
                    downSizeFile(this.files[0], (file) => {
                        uploadFile(file, that)
                    })
                }
            }
            $('#file_upload_tag').trigger('click')
        }
    })
})
