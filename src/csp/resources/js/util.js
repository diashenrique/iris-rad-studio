var urlOrigin = window.location.origin;
var restapp = "/irisrad"

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
            } catch(e) {
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
function notify(msg, type, duration) {
    DevExpress.ui.notify(msg, type, duration||1500);
}

// Utility method for login logic
function doLogin(user, password) {
    var d = $.Deferred();
    $.ajax(`${urlOrigin}${restapp}/login`, {
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
    return JSON.parse(localStorage.getItem("userInfo"));
}