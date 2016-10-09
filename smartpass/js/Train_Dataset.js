function trainDataset(personGroupId) {
    var params = {
        // Request parameters
    };

    $.ajax({
        url: "https://api.projectoxford.ai/face/v1.0/persongroups/" + personGroupId + "/train?" + $.param(params),
        beforeSend: function(xhrObj){
            // Request headers
            xhrObj.setRequestHeader("Ocp-Apim-Subscription-Key","41b49cbdfd7548179bc07be1a26d5699");
        },
        type: "POST",
        // Request body
    })
    .done(function(data) {
        alert("success");
    })
    .fail(function() {
        alert("error");
    });
}
