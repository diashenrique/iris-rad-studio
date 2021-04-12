var urlOrigin = window.location.origin;
var restapp = "/irisrad"

var ajaxGlobalLastError;
$(document).ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
    console.log(jqXHR.status, event, ajaxSettings, thrownError)
    if (parseInt(jqXHR.status) >= 500) {
        const errorMsg = jqXHR.responseJSON.errors.map(errObj => errObj.error).join();
        ajaxGlobalLastError = errorMsg;
        return jqXHR;
    }
});

function addDefuaultGridErroHandler(dataGridConfig) {
    return Object.assign(dataGridConfig, {
        onDataErrorOccurred: (e) => {
            setTimeout(() => {
                notify(ajaxGlobalLastError || e.message, NotificationEnum.ERROR, {
                    closeOnClick: true,
                    closeOnOutsideClick: true,
                    displayTime: 60000
                });
            }, 100);
        },
        errorRowEnabled: false
    });
}

function sendRequest(url, method, data) {
    var d = $.Deferred();

    method = method || "GET";

    $.ajax(url, {
        method: method || "GET",
        data: data,
        cache: false,
        xhrFields: {
            withCredentials: true
        }
    }).done(function (result) {
        var jsonResult = {}
        jsonResult.data = result.children;
        d.resolve(method === "GET" ? result.children : result);
    }).fail(function (xhr) {
        if (xhr.statusText !== 'OK') {
            d.reject(xhr.responseJSON ? xhr.responseJSON.Message : xhr.statusText);
        } else {
            try {
                var result = eval(`(${xhr.responseText})`);
                var jsonResult = {}
                jsonResult.data = result.children;
                d.resolve(method === "GET" ? result.children : result);
            } catch (e) {
                d.reject(e);
            }
        }
    });

    return d.promise();
}

// Utility method to get URL query string
function getQueryString() {
    return window.location.search
        .substr(1)
        .split('&')
        .map(item => item.split('='))
        .reduce((acc, curr) => {
            acc[curr[0]] = curr[1];
            return acc;
        }, {});
}

var NotificationEnum = {
    ERROR: 'error',
    SUCCESS: 'success',
    WARNING: 'warning',
    INFO: 'info'
}

function notify(msg, type, config) {
    config = config || {};
    config.message = msg;
    config.displayTime = config.displayTime || 4000
    DevExpress.ui.notify(config, type);
}

function getAppName() {
    return /\/csp\/([^\/]+)\//.exec(location.pathname)[1]
}

// Utility method for login logic
function doLogin(user, password) {
    var d = $.Deferred();
    $.ajax(`${urlOrigin}${restapp}/login/${getAppName()}`, {
        headers: {
            "Authorization": `Basic ${btoa(`${user}:${password}`)}`
        },
        success: (data, textStatus, jqXHR) => {
            // todo: enhance this handling
            window.location.href = 'rad.html'
            setUserInfo(data);
            d.resolve();
        },
        error: (jqXHR, textStatus, errorThrown) => {
            // todo: handle exception properly...
            console.log(jqXHR, textStatus, errorThrown);
            console.log(jqXHR.status)
            if (jqXHR.status === 401) {
                notify('Incorrect user or password. Please, try again.', NotificationEnum.ERROR)
            } else {
                notify('Sorry, can\'t login. See log for more detail.', NotificationEnum.ERROR);
            }
            setUserInfo();
            d.reject();
        }
    });
    return d.promise();
}

// Utility method for logout logic
function doLogout() {
    $.ajax(`${urlOrigin}${restapp}/logout`, {
        success: (data, textStatus, jqXHR) => {
            // todo: enhance this handling
            window.location.href = 'login.html';
            setUserInfo();
        },
        error: (jqXHR, textStatus, errorThrown) => {
            console.log(jqXHR, textStatus, errorThrown);
            notify('Error on logout. See log for more detail.', NotificationEnum.ERROR);
            window.location.href = 'login.html';
            setUserInfo();
        }
    });
}

function setUserInfo(userInfo) {
    if (userInfo) {
        localStorage.setItem("userInfo", JSON.stringify(userInfo));
    } else {
        localStorage.removeItem("userInfo");
    }
}

function getUserInfo() {
    var userInfo = localStorage.getItem("userInfo");
    if (userInfo) {
        return JSON.parse(userInfo);
    }
}