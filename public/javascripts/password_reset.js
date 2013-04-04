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
    return (newPass==oldPass) && newPass!=""

}