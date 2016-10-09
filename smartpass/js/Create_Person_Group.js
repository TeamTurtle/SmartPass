function createPersonGroup(id, name, description) {
    var params = {
        // Request parameters
        "personGroupId" : id,
    };

    $.ajax({
        url: "https://api.projectoxford.ai/face/v1.0/persongroups/test_group4?" + $.param(params),
        beforeSend: function(xhrObj){
            // Request headers
            xhrObj.setRequestHeader("Content-Type","application/json");
            xhrObj.setRequestHeader("Ocp-Apim-Subscription-Key","41b49cbdfd7548179bc07be1a26d5699");
        },
        type: "PUT",
        // Request body
        data: "{'name':'" + name + "', 'userData':'" + description + "'}"
    })
    .done(function(data) {
        alert("success");
    })
    .fail(function() {
        alert("error");
    });
}
