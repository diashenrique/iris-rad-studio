var urlOrigin = window.location.origin;

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
        d.reject(xhr.responseJSON ? xhr.responseJSON.Message : xhr.statusText);
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
    $.ajax(`${urlOrigin}/forms/login`, {
        headers: {
            "Authorization": `Basic ${btoa(`${user}:${password}`)}`
        },
        success: (data, textStatus, jqXHR) => {
            // todo: enhance this handling
            window.location.href = 'rad.html'
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
            d.reject();
        }
    });
    return d.promise();
}

// Utility method for logout logic
function doLogout() {
    $.ajax(`${urlOrigin}/forms/logout`, {
        success: (data, textStatus, jqXHR) => {
            // todo: enhance this handling
            window.location.href = 'login.html'
        },
        error: (jqXHR, textStatus, errorThrown) => {
            console.log(jqXHR, textStatus, errorThrown);
            notify('Error on logout. See log for more detail.', NotificationEnum.ERROR);
            window.location.href = 'login.html'
        }
    });
}