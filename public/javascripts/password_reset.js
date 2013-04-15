/*
*This page contains all relevant JS for the password reset pages
*/


// Helper function to validate reset form
function validateResetForm(){
    if ($("#email").val()==""){
        return false
    } else{
        return true
    }
}

// Helper function to validate edit form
function validateEditForm(){
    var newPass = $("#newPassword").val()
    var oldPass = $("#confirmPassword").val()
    if ((newPass==oldPass) && newPass!="") {
        return true
    }else{
        email_mismatching()
        return false
    }
}

function email_mismatching(){
    $("#password_mismatch_warning").append($('<div/>').css('color', 'red').text('Password mismatch'));
}