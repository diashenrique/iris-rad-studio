var urlOrigin = window.location.origin;
var restapp = "/irisrad"
var urlREST = `${urlOrigin}${restapp}`;
var urlRESTForm = `${urlREST}/form`

$(document).ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
  console.log(jqXHR.status, event, ajaxSettings, thrownError)
  if (jqXHR.status === 401) {
    window.location.href = 'login.html';
  }
});

var qs = getQueryString();
var formName = qs.formName || 'Form.Test.Person';
var selectedForms = "";
var newAppData = {};

$(document).ready(function () {
  $("#divResults").hide();

  $("#btnDeploy").dxButton({
    icon: "fas fa-cloud-upload-alt",
    type: "default",
    text: "Deploy",
    onClick: function (e) {
      if (!form.validate().isValid) {
        DevExpress.ui.notify("There are required fields not filled in", "error", 4000);

      } else {
        loadPanel.show();
        $("#msgOK").hide();
        $("#msgError").hide();
        $("#textAreaLog").hide()

        var dataForm = form.option("formData");
        dataForm.forms = selectedForms;

        $.ajax({
          url: `${urlREST}/deploy`,
          method: "POST",
          processData: false,
          contentType: "application/json",
          data: JSON.stringify(dataForm)
        })
          .done(function (resp) {
            newAppData = resp;
            loadPanel.hide();
            $("#divFormsSelection").hide();
            $("#divResults").show();
            if (newAppData.status === 1) {
              $("#msgOK").show();
            } else {
              $("#msgError").hide();
            }
          });
      }
    }
  });

  var loadPanel = $(".loadpanel").dxLoadPanel({
    message: "Deploying...",
    shadingColor: "rgba(0,0,0,0.4)",
    position: { of: "#divFormsSelection" },
    visible: false,
    showIndicator: true,
    showPane: true,
    shading: true,
    closeOnOutsideClick: false,
  }).dxLoadPanel("instance");

  $("#btnOpenApp").dxButton({
    type: "default",
    text: "Open application",
    onClick: function (e) {
      window.open(newAppData.newAppLink);
    }
  });

  $("#btnViewLog").dxButton({
    type: "default",
    text: "View log",
    onClick: function (e) {
      $("#textAreaLog").toggle()
      if ($("#textAreaLog").is(":visible")) {
        $("#textAreaLog").dxTextArea({
          value: newAppData.output,
          height: 250
        }).dxTextArea("instance");
      }
    }
  });

  var formsUrl = `${urlRESTForm}/info`;
  var dataGrid = $("#dataGridForms").dxDataGrid({
    dataSource: new DevExpress.data.CustomStore({
      load: function () {
        return $.getJSON(`${formsUrl}`);
      },
    }),
    selection: {
      mode: "multiple"
    },
    columns: [{
      dataField: "name",
      caption: "Form",
      dataType: "string",
    }/*,
      {
        dataField: "DisplayName"
      },
      {
        dataField: "IsRequired",
        caption: "Is Required?",
        dataType: "boolean",
        value: false,
      }*/
    ],
    onSelectionChanged: function (selectedItems) {
      selectedForms = selectedItems.selectedRowsData;
    }
  }).dxDataGrid("instance");
});

var form = $("#formsSelection").dxForm({
  readOnly: false,
  showColonAfterLabel: false,
  labelLocation: "left",
  minColWidth: 300,
  colCount: "auto",
  items: [{
    dataField: "appName",
    editorOptions: {
      placeholder: "Application name"
    },
    validationRules: [{
      type: "required",
      message: "Application Name is required"
    }]
  }, {
    dataField: "appDescription",
    editorOptions: {
      placeholder: "Application description"
    },
    validationRules: [{
      type: "required",
      message: "Application description is required"
    }]
  }]
}).dxForm("instance");