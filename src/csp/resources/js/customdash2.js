var urlOrigin = window.location.origin;
var urlREST = `${urlOrigin}/forms/form`;

$(document).ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
  console.log(jqXHR.status, event, ajaxSettings, thrownError)
  if (jqXHR.status === 401) {
    window.location.href = 'login.html';
  }
});

var qs = getQueryString();
var formName = qs.formName || 'Form.Test.Person';
var queryName = qs.queryName

$(document).ready(function () {
  $("#divFormName").text(` ${formName}`);
  createDefaultCRUDForm();
});

var dataUrl;
var metadataUrl;
if (formName) {
  dataUrl = `${urlREST}/objects/${formName}/allobj?size=1000000`;
  metadataUrl = `${urlREST}/info/${formName}`;
  if (queryName) {
    dataUrl = `${urlREST}/objects/${formName}/custom/${queryName}?size=1000000`;
    metadataUrl = `${urlREST}/info/${formName}/${queryName}`;
  }
}

var createQueryCustomStore = function () {
  return new DevExpress.data.CustomStore({
    load: function () {
      return sendRequest(dataUrl);
    }
  });
}

var createCRUDCustomStore = function () {
  return new DevExpress.data.CustomStore({
    key: "ID",
    load: function () {
      return sendRequest(dataUrl);
    },
    insert: function (values) {
      return $.ajax({
        url: `${urlREST}/object/${formName}`,
        method: "POST",
        processData: false,
        contentType: "application/json",
        data: JSON.stringify(values)
      });
    },
    update: function (key, values) {
      return $.ajax({
        url: `${urlREST}/object/${formName}/${encodeURIComponent(key)}`,
        method: "PUT",
        processData: false,
        contentType: "application/json",
        data: JSON.stringify(values)
      });
    },
    remove: function (key) {
      return $.ajax({
        url: `${urlREST}/object/${formName}/${encodeURIComponent(key)}`,
        method: "DELETE",
      });
    },
    onBeforeSend: function (method, ajaxOptions) {
      ajaxOptions.xhrFields = {
        withCredentials: true
      };
    }
  });
}

var createDefaultCRUDForm = function () {
  var customStore;
  if (queryName) {
    customStore = createQueryCustomStore();
  } else {
    customStore = createCRUDCustomStore();
  }

  $.ajax({
    url: metadataUrl,
    method: "GET",
    processData: false,
    contentType: "application/json",
    error: (jqXHR, textStatus, errorThrown) => {
      console.log(jqXHR.status, textStatus, errorThrown)
      if (jqXHR.status === 500) {
        notify(`Form not found: ${formName}`, NotificationEnum.ERROR);
      }
      return true;
    },
    complete: (resp) => {
      var rf2FormInfo = resp.responseJSON;
      var cols = rf2FormInfo.fields.map(rf2Field => {

        var objCol = {
          dataField: rf2Field.name,
          caption: rf2Field.displayName,
          dataType: getDevExtremeFieldType(rf2Field)
        }

        if (getPropType(rf2Field) == FieldType.Form) {
          console.log("Campo relacionado ", objCol);
          var lookupForm = rf2Field.type;
          var fieldValue = rf2Field.name.valueOf();
          objCol.lookup = {
            dataSource: {
              store: new DevExpress.data.CustomStore({
                key: "_id",
                //loadMode: "raw",
                load: function () {
                  console.log(`${urlREST}/objects/${lookupForm}/info`);
                  return sendRequest(`${urlREST}/objects/${lookupForm}/info`);
                },
                byKey: function (key) {
                  console.log(`${urlREST}/objects/${lookupForm}/${key}`);
                  return sendRequest(`${urlREST}/object/${lookupForm}/${key}`);
                }
              })
            },
            valueExpr: "_id",
            displayExpr: "displayName"
          }

        };

        return objCol;
      });

      if (rf2FormInfo.toolbarUIDef) {
        // todo: fix this security threat
        // eval() function was used in order to allow embedded JS code
        $("#toolbar").dxToolbar({
          items: eval(`(${rf2FormInfo.toolbarUIDef})`)
        });
      }

      if (rf2FormInfo.customUIDef) {
        // todo: fix this security threat
        // eval() function was used in order to allow embedded JS code
        $("#divRAD").dxForm(eval(`(${rf2FormInfo.customUIDef})`));
      } else {
        var dataGridConfig = {
          dataSource: customStore,
          showBorders: true,
          columnsAutoWidth: true,
          columnHidingEnabled: true,
          searchPanel: {
            visible: true,
            width: 240,
            placeholder: "Search..."
          },
          columns: cols,
        };

        if (!queryName) {
          dataGridConfig.editing = {
            mode: "form",
            allowAdding: true,
            allowUpdating: true,
            allowDeleting: true
          };
        }

        $("#divRAD").dxDataGrid(dataGridConfig);
      }
    }
  });
}