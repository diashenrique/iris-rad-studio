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
var pIdSelected = "";

$(document).ready(function () {
  $("#divProperties").hide();

  var storeSelectBox = new DevExpress.data.DataSource({
    store: new DevExpress.data.CustomStore({
      loadMode: "raw",
      load: function () {
        return $.getJSON(`${urlREST}/class/lookup`)
      }
    })
  });

  $("#toolbar").dxToolbar({
    items: [{
      location: 'after',
      widget: 'dxButton',
      locateInMenu: 'auto',
      options: {
        icon: "plus",
        text: "New class",
        type: "default",
        onClick: function () {
          $("#divProperties").hide();
          form.resetValues();
          selectSearch.option("value", "");
          DevExpress.ui.notify("New class button has been clicked!");
        }
      }
    }, {
      location: 'after',
      widget: 'dxButton',
      locateInMenu: 'auto',
      options: {
        icon: "fas fa-cogs",
        text: "Compile",
        type: "default",
        onClick: function () {
          DevExpress.ui.notify("Compile button has been clicked!");
        }
      }
    }, {
      location: 'after',
      widget: 'dxButton',
      locateInMenu: 'auto',
      options: {
        icon: "fas fa-trash",
        text: "Delete",
        type: "danger",
        onClick: function () {
          DevExpress.ui.notify("Delete button has been clicked!");
        }
      }
    }]
  });

  var selectSearch = $("#select-class").dxSelectBox({
    dataSource: storeSelectBox,
    displayExpr: "ClassName",
    valueExpr: "ID",
    searchEnabled: true,
    onValueChanged: function (data) {
      var pIdSelected = data.value;
      console.log("pIdSelected", pIdSelected);
      formDataValue(pIdSelected);
      $("#divProperties").show();
      dataGrid.getDataSource().reload();
    }
  }).dxSelectBox("instance");

  $("#btnSaveCompile").dxButton({
    icon: "fas fa-save",
    type: "default",
    text: "Save",
    onClick: function (e) {
      $("#divProperties").show();
      DevExpress.ui.notify("Save Class");
    }
  });

  var createCustomStore = new DevExpress.data.DataSource({
    store: new DevExpress.data.CustomStore({
      key: "ID",
      load: function () {
        if (pIdSelected == "") {
          return []
        }
        console.log(pIdSelected);
        return $.getJSON(`${urlREST}/class/fields/${encodeURIComponent(`${pIdSelected}`)}`);
      },
      insert: function (values) {
        return $.ajax({
          url: `${urlREST}/class/fields`,
          method: "POST",
          processData: false,
          contentType: "application/json",
          data: JSON.stringify(values)
        });
      },
      update: function (key, values) {
        return $.ajax({
          url: `${urlREST}/class/fields/${encodeURIComponent(key)}`,
          method: "PUT",
          processData: false,
          contentType: "application/json",
          data: JSON.stringify(values)
        });
      },
      remove: function (key) {
        return $.ajax({
          url: `${urlREST}/class/fields/${encodeURIComponent(key)}`,
          method: "DELETE"
        });
      },
      onBeforeSend: function (method, ajaxOptions) {
        ajaxOptions.xhrFields = {
          withCredentials: true
        };
      }
    })
  });

  var dataGrid = $("#dataGridLine").dxDataGrid({
    dataSource: createCustomStore,
    rowAlternationEnabled: true,
    allowColumnResizing: true,
    columnResizingMode: "widget",
    columnAutoWidth: true,
    showBorders: true,
    editing: {
      refreshMode: "reshape",
      mode: "row",
      allowAdding: true,
      allowUpdating: true,
      allowDeleting: true
    },
    columns: [{
        dataField: "ParentClass",
        lookup: {
          dataSource: {
            store: new DevExpress.data.CustomStore({
              key: "ID",
              loadMode: "raw",
              load: function () {
                return $.getJSON(`${urlREST}/class/lookup`);
              }
            })
          },
          valueExpr: "ID",
          displayExpr: "ClassName"
        }
      },
      {
        dataField: "FieldName"
      },
      {
        dataField: "DisplayName"
      },
      {
        dataField: "FieldType",
        width: 200,
        lookup: {
          dataSource: fieldTypeSelectBox,
          displayExpr: "name",
          valueExpr: "id"
        }
      },
      {
        dataField: "IsRequired",
        caption: "Is Required?",
        dataType: "boolean",
        value: false,
      }
      /*,{
        dataField: "ClassRelated"
      }*/
    ],
    onEditorPrepared: function (options) {
      if (options.parentType == "dataRow" && options.dataField == "ParentClass") {
        var idClass = $("#select-class").dxSelectBox("instance").option("value");
        options.editorElement.dxSelectBox('instance').option('value', idClass);
      }
    },
    onEditorPreparing: function (e) {
      if (e.dataField == "ParentClass" && e.parentType == "dataRow") {
        e.editorOptions.readOnly = true;
      }
    }
  }).dxDataGrid("instance");

});

var form = $("#formClassCreator").dxForm({
  formData: "",
  readOnly: false,
  showColonAfterLabel: false,
  labelLocation: "left",
  minColWidth: 300,
  colCount: "auto",
  items: [{
    dataField: "ClassName",
    validationRules: [{
      type: "required",
      message: "Class Name is required"
    }]
  }, {
    dataField: "Description"
  }]
}).dxForm("instance");


function formDataValue(pId) {
  var retFormData = $.ajax({
    type: "GET",
    url: `${urlREST}/class/${encodeURIComponent(pId)}`,
    async: false,
    processData: false,
    contentType: "application/json",
    dataType: "json",
    done: function (results) {
      JSON.parse(results);
      console.log("done", results)
      return results;
    },
    fail: function (jqXHR, textStatus, errorThrown) {
      console.log('Could not get data, server response: ' + textStatus + ': ' + errorThrown);
    }
  }).responseJSON;
  form.option("formData", retFormData[0]);
};


var fieldTypeSelectBox = [{
    "id": "%Library.BigInt",
    "name": "%Library.BigInt"
  },
  {
    "id": "%Library.Boolean",
    "name": "%Library.Boolean"
  },
  {
    "id": "%Library.Currency",
    "name": "%Library.Currency"
  },
  {
    "id": "%Library.Date",
    "name": "%Library.Date"
  },
  {
    "id": "%Library.DateTime",
    "name": "%Library.DateTime"
  },
  {
    "id": "%Library.Decimal",
    "name": "%Library.Decimal"
  },
  {
    "id": "%Library.Double",
    "name": "%Library.Double"
  },
  {
    "id": "%Library.Float",
    "name": "%Library.Float"
  },
  {
    "id": "%Library.Integer",
    "name": "%Library.Integer"
  },
  {
    "id": "%Library.Numeric",
    "name": "%Library.Numeric"
  },
  {
    "id": "%Library.PosixTime",
    "name": "%Library.PosixTime"
  },
  {
    "id": "%Library.SmallInt",
    "name": "%Library.SmallInt"
  },
  {
    "id": "%Library.String",
    "name": "%Library.String"
  },
  {
    "id": "%Library.Time",
    "name": "%Library.Time"
  },
  {
    "id": "%Library.TimeStamp",
    "name": "%Library.TimeStamp"
  },
  {
    "id": "%Library.TinyInt",
    "name": "%Library.TinyInt"
  },
  {
    "id": "%Library.VarString",
    "name": "%Library.VarString"
  }
]