var urlOrigin = window.location.origin;
var restapp = "/irisrad"
var urlREST = `${urlOrigin}${restapp}/form`;

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
          form.option("readOnly", false);
          selectSearch.option("value", "");
          dataGrid.option("dataSource", []);
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
          $.ajax({
            url: `${urlREST}/class/compile/${encodeURIComponent(pIdSelected)}`,
            method: "POST",
            processData: false,
            contentType: "application/json",
            data: JSON.stringify(pIdSelected)
          }).done(function (e) {
            DevExpress.ui.notify(e.msg, "success", 4000);
          });

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
          var dataForm = form.option("formData");

          if (jQuery.isEmptyObject(dataForm) == true) {
            DevExpress.ui.notify("No class selected", "error", 4000);
          } else {
            $.ajax({
              url: `${urlREST}/class/${encodeURIComponent(dataForm.ID)}`,
              method: "DELETE"
            }).done(function (returnDelete) {
              storeSelectBox.reload();
              $("#divProperties").hide();
              form.resetValues();
              form.option("readOnly", false);
              selectSearch.option("value", "");
              dataGrid.option("dataSource", []);
              DevExpress.ui.notify("Class " + returnDelete[0].ClassName + " has been deleted successfully", "info", 4000);
            });
          }

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
      pIdSelected = data.value;
      console.log(pIdSelected);
      if (pIdSelected != "") {
        formDataValue(pIdSelected);
        form.option("readOnly", true);
        $("#divProperties").show();
        dataGrid.getDataSource().reload();
        $("#dataGridLine").dxDataGrid("instance").option("dataSource", createCustomStore);
      }
    }
  }).dxSelectBox("instance");

  $("#btnSaveCompile").dxButton({
    icon: "fas fa-save",
    type: "default",
    text: "Save",
    onClick: function (e) {
      if (!form.validate().isValid) {
        DevExpress.ui.notify("There are required fields not filled in", "error", 4000);
      } else {
        var dataForm = form.option("formData");

        console.log(dataForm);

        $.ajax({
          url: `${urlREST}/class`,
          method: "POST",
          processData: false,
          contentType: "application/json",
          data: JSON.stringify(dataForm)
        }).done(function (retSaveClass) {
          storeSelectBox.reload();
          $("#select-class").dxSelectBox("instance").option("value", retSaveClass[0].ID);
          DevExpress.ui.notify("Class has been saved", "success", 4000);
        });

        $("#divProperties").show();
      }
    }
  });

  var createCustomStore = new DevExpress.data.DataSource({
    store: new DevExpress.data.CustomStore({
      key: "ID",
      load: function () {
        return $.getJSON(`${urlREST}/class/fields/${encodeURIComponent(pIdSelected)}`, function (e) {
          console.log(e);
        });
      },
      insert: function (values) {
        values.ParentClass = pIdSelected;
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
    //dataSource: createCustomStore,
    dataSource: [],
    rowAlternationEnabled: true,
    allowColumnResizing: true,
    columnResizingMode: "widget",
    columnAutoWidth: true,
    showBorders: true,
    editing: {
      mode: "row",
      allowAdding: true,
      allowUpdating: true,
      allowDeleting: true
    },
    columns: [{
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
      if (options.parentType === "dataRow" && options.dataField === "FieldType") {
        options.editorElement.dxSelectBox("instance").option("value", fieldTypeSelectBox[0].id);
      }
    }
  }).dxDataGrid("instance");
});

var form = $("#formClassCreator").dxForm({
  //formData: "",
  readOnly: false,
  showColonAfterLabel: false,
  labelLocation: "left",
  minColWidth: 300,
  colCount: "auto",
  items: [{
    dataField: "ClassName",
    editorOptions: {
      placeholder: "Enter class name - e.g. <Package>.<ClassName>"
      /*,onValueChanged: function(j) {
        if (!j.value) {
          return 
        } 
        $.getJSON(`${urlREST}/class/check/${j.value}`,function(e){
          if (e.msg != "") {
            DevExpress.ui.notify(e.msg, "error", 4000);
            form.getEditor("ClassName").option("value","");
          }
        });
      }*/
    },
    validationRules: [{
      type: "required",
      message: "Class Name is required"
    }]
  }, {
    dataField: "Description",
    editorOptions: {
      placeholder: "Enter class description to be used as Form Name"
    },
    validationRules: [{
      type: "required",
      message: "Description is required"
    }]
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
    "id": "%Library.String",
    "name": "%Library.String"
  }, {
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