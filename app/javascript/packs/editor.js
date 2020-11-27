function resizeTextarea(area) {
    area.style.height = 0
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

$(document).on('turbolinks:load', () => {
    $('.auto-resize').each(function () {
        resizeTextarea(this)
    }).on('input', function () {
        resizeTextarea(this)
    })

    $('.paste-file-upload').on('paste', function (event) {
        var clipboard = (event.clipboardData || event.originalEvent.clipboardData).items;
        for (let item of clipboard) {
            if (item.kind === 'file') {
                uploadFile(item.getAsFile(), this)
            }
        }
    }).on('keyup', function (event) {
        if (event.ctrlKey && event.altKey && event.key === "u") {
            event.preventDefault()
            var that = this
            $("#file_upload_tag")[0].onchange = function () {
                if (this.files[0]) {
                    uploadFile(this.files[0], that)
                }
            }
            $("#file_upload_tag").trigger('click')
        }
    })
})
