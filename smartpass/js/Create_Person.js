function createPerson(personGroupId, name, imageURL) {
    var params = {
        // Request parameters
        "personGroupId" : personGroupId,
    };

    $.ajax({
        url: "https://api.projectoxford.ai/face/v1.0/persongroups/" + personGroupId + "/persons?" + $.param(params),
        beforeSend: function(xhrObj){
            // Request headers
            xhrObj.setRequestHeader("Content-Type","application/json");
            xhrObj.setRequestHeader("Ocp-Apim-Subscription-Key","41b49cbdfd7548179bc07be1a26d5699");
        },
        type: "POST",
        // Request body
        data: "{'name':'" + name + "', 'userData':'hi'}",
    })
    .done(function(data) {
        var returnOut = data.personId;

        var params = {
            // Request parameters
        };

        var urll = "https://api.projectoxford.ai/face/v1.0/persongroups/" + personGroupId + "/persons/" + data.personId + "/persistedFaces?" + $.param(params);

        $.ajax({
            url: urll,
            beforeSend: function(xhrObj){
                // Request headers
                xhrObj.setRequestHeader("Content-Type","application/json");
                xhrObj.setRequestHeader("Ocp-Apim-Subscription-Key","41b49cbdfd7548179bc07be1a26d5699");
            },
            type: "POST",
            // Request body
            data: "{'url': '" + imageURL + "'}",
        })
        .done(function(data) {
            trainDataset(personGroupId);
            var myform = $('#form');
            $.ajax({
                type: myform.attr('method'),
                url: "/bookevent",
                data: myform.serialize() + "&faceId=" + returnOut,
                success: function (data) {
                    //if successful at posting the form via ajax.
                    window.lock = "";
                }
            });
        })
        .fail(function() {
            alert("add face error");
        });
    })
    .fail(function() {
        alert("add person error");
    });
}
