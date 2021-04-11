var urlOrigin = window.location.origin;
var restapp = "/irisrad/unauth"
var urlREST = `${urlOrigin}${restapp}/form`;

$(document).ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
  console.log(jqXHR.status, event, ajaxSettings, thrownError)
  if (jqXHR.status === 401) {
    window.location.href = 'login.html';
  }
});

var qs = getQueryString();
var formName = "dc.irisrad.data.RADUser";
var queryName = qs.queryName;

var dataUrl;
var metadataUrl;
var formsUrl = `${urlREST}/info`;
if (formName) {
  dataUrl = `${urlREST}/objects/${formName}/allobj?size=1000000`;
  metadataUrl = `${urlREST}/info/${formName}`;
  if (queryName) {
    dataUrl = `${urlREST}/objects/${formName}/custom/${queryName}?size=1000000`;
    metadataUrl = `${urlREST}/info/${formName}/${queryName}`;
  }
}

$(document).ready(function () {
  createMenu();
  createFormSelector();
  if (formName) {
    $("#divFormName").text(` ${formName}`);
    createDefaultCRUDForm();
  }
});

var createFormSelector = () =>
  $.ajax({
    url: formsUrl,
    method: "GET",
    processData: false,
    contentType: "application/json",
    error: (jqXHR, textStatus, errorThrown) => {
      console.log(jqXHR.status, textStatus, errorThrown);
      return true;
    },
    complete: (resp) => {
      var forms = resp.responseJSON;
      if (!formName) {
        // creation of items on main widget
        $("#form-selector").dxTileView({
          items: forms,
          direction: "vertical",
          itemTemplate: function (itemData, itemIndex, itemElement) {
            itemElement.append(
              `<div>${itemData.name}</div>
            <div id=\"button-remove-form-${itemIndex}\"></div>`
            );
            $(`#button-remove-form-${itemIndex}`).dxButton({
              icon: "trash",
              onClick: function (dxEvt) {
                removeForm(itemData.class)
                  .then(() => {
                    notify("Form deleted");
                    createFormSelector();
                  })
                  .fail(() => {
                    notify("Error in form deleting", "error")
                  });
              }
            });
          },
          onItemClick: (dxEvt) => {
            if ($(dxEvt.event.target).hasClass('dx-tile-content')) {
              window.location.href = `${window.location.href}?formName=${dxEvt.itemData.class}`;
            }
          }
        });
      }
    }
  });

var removeForm = function (formName) {
  var removeFormUrl = `${urlREST}/${formName}`;
  return sendRequest(removeFormUrl, 'DELETE');
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
      var cols = rf2FormInfo.fields.map(rf2Field => createFormField(rf2Field));
      
      var formDescription = rf2FormInfo.name
      $("#divFormName").text(` ${formDescription}`);

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
          allowColumnResizing: true,
          showColumnLines: true,
          showRowLines: true,
          rowAlternationEnabled: true,
          hoverStateEnabled: true,
          showBorders: true,
          paging: {
            pageSize: 10
          },
          pager: {
            showPageSizeSelector: true,
            allowedPageSizes: [10, 20, 30, 40, 50, 100],
            showInfo: true
          },
          sorting: {
            mode: "multiple"
          },
          filterRow: {
            visible: true,
            applyFilter: "auto"
          },
          filterPanel: {
            visible: true
          },
          searchPanel: {
            visible: true,
            width: 240,
            placeholder: "Search..."
          },
          headerFilter: {
            visible: true
          },
          grouping: {
            expandMode: "rowClick",
            autoExpandAll: true,
            allowCollapsing: true
          },
          groupPanel: {
            visible: true,
            allowColumnDragging: true
          },
          columnChooser: {
            enabled: true
          },
          export: {
            enabled: true
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
        dataGridConfig = addDefuaultGridErroHandler(dataGridConfig);

        $("#divRAD").dxDataGrid(dataGridConfig);
      }
    }
  });
}

var createFormDataStore = (lookupForm) => {
  return new DevExpress.data.CustomStore({
    key: "_id",
    load: function () {
      console.log(`${urlREST}/objects/${lookupForm}/info`);
      return sendRequest(`${urlREST}/objects/${lookupForm}/info`);
    },
    byKey: function (key) {
      console.log(`${urlREST}/objects/${lookupForm}/${key}`);
      return sendRequest(`${urlREST}/object/${lookupForm}/${key}`);
    }
  });
}

var createFormField = (rf2Field) => {
  // Default field
  var objCol = {
    dataField: rf2Field.name,
    caption: rf2Field.displayName,
    dataType: getDevExtremeFieldType(rf2Field)
  }

  // Password field
  if (rf2Field.type === FieldType.Password) {
    objCol.editorOptions = {
      mode: 'password'
    }
  }

  // Multiple Form selection field
  if (getPropType(rf2Field) === FieldType.List && rf2Field.category === 'form') {
    var lookupForm = rf2Field.type;
    objCol.editCellTemplate = getTagBoxEditorTemplate(lookupForm);
  }

  // Single Form selection field
  if (getPropType(rf2Field) == FieldType.Form) {
    var lookupForm = rf2Field.type;
    var fieldValue = rf2Field.name.valueOf();
    objCol.lookup = {
      dataSource: {
        store: createFormDataStore(lookupForm)
      },
      valueExpr: "_id",
      displayExpr: "displayName"
    }
  };

  return objCol;
}

var getTagBoxEditorTemplate = function(lookupForm) {
  return function (cellElement, cellInfo) {
    return $("<div>").dxTagBox({
        dataSource: createFormDataStore(lookupForm),
        value: cellInfo.value,
        valueExpr: "_id",
        displayExpr: "displayName",
        showSelectionControls: true,
        maxDisplayedTags: 3,
        showMultiTagOnly: false,
        applyValueMode: "useButtons",
        searchEnabled: true,
        onValueChanged: function(e) {
            cellInfo.setValue(e.value)
        },
        onSelectionChanged: function(e) {
            cellInfo.component.updateDimensions();
        }
    });
  }
}