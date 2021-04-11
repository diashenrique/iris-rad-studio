// todo: move to a generic js file to avoid DRY
var urlOrigin = window.location.origin;
var restapp = "/irisrad"
var urlREST = `${urlOrigin}${restapp}`;

// todo: move to a generic js file to avoid DRY
$(document).ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
  console.log(jqXHR.status, event, ajaxSettings, thrownError)
  if (jqXHR.status === 401) {
    window.location.href = 'login.html';
  }
});

// todo: move to a generic js file to avoid DRY
var qs = getQueryString();
var formName = qs.formName || 'dc.irisrad.default.UserForm';

var selectedForms = "";
var newAppData = {};

$(document).ready(function () {
  createMenu();
  
  var appsUrl = `${urlREST}/apps`;
  var dataGridConfig = {
    editing: {
      allowDeleting: true
    },
    onCellPrepared: function (e) {
      if (e.rowType === "data" && e.column.command === "edit") {
        $('<a>')
          .text("Open")
          .attr({
            "href": "#",
            "class": "dx-link"
          })
          .appendTo(e.cellElement)
          .click(() => {
            console.log(e.row.data);
            window.open(e.row.data.AppURL)
          });
      }
    },
    dataSource: new DevExpress.data.CustomStore({
      load: function () {
        return $.getJSON(`${appsUrl}`);
      },
      remove: function (row) {
        $.ajax({
          url: `${urlREST}/apps/${row.AppName}`,
          method: "DELETE",
          processData: false,
          contentType: "application/json"
        })
          .done(function (resp) {

          });
      }
    }),
    selection: {
      mode: "single"
    },
    columns: [{
      dataField: "AppName",
      caption: "Application name",
      dataType: "string",
    }, {
      dataField: "AppDesc",
      caption: "Description",
      dataType: "string",
    }]
  };
  dataGridConfig = addDefuaultGridErroHandler(dataGridConfig);
  $("#dataGrid").dxDataGrid(dataGridConfig).dxDataGrid("instance");
});