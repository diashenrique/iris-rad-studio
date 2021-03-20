var urlOrigin = window.location.origin;
//var urlREST = `${urlOrigin}/csp/irisapp/api`;
var urlREST = `${urlOrigin}/forms`;

$(document).ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
  console.log(jqXHR.status, event, ajaxSettings, thrownError)
  if (jqXHR.status === 401) {
    window.location.href = 'login.html';
  }
});

var qs = getQueryString();
var formName = qs.formName || 'dc.irisrad.default.UserForm';

$(document).ready(function () {
  createFormWizard();
});

var createFormWizard = function () {

  var fileUploader = $("#formWizard").dxForm({
    readOnly: false,
    showColonAfterLabel: true,
    showValidationSummary: true,
    validationGroup: "customerData",
    items: [{
        itemType: "group",
        caption: "Import Definitions",
        items: [{
            dataField: "separator",
            editorOptions: {
              placeholder: "Default separator is , (comma)"
            }
          },
          {
            dataField: "className"
          }
        ]
      },
      {
        itemType: "group",
        caption: "Cube Definitions",
        items: [{
            dataField: "cubeCreate",
            editorType: "dxCheckBox",
            label: {
              visible: false
            },
            editorOptions: {
              text: "Should I create a cube for this class?"
            }
          },
          {
            dataField: "cubeName"
          },
          {
            dataField: "sampleDashboard",
            editorType: "dxCheckBox",
            label: {
              visible: false
            },
            editorOptions: {
              text: "Generate a sample dashboard?"
            }
          }
        ]
      },
      {
        itemType: "group",
        caption: "File",
        items: [{
          dataField: "file",
          editorType: "dxFileUploader",
          allowedFileExtensions: [".csv"],
          editorOptions: {
            uploadMode: "useForm"
          },
          label: {
            visible: false
          }
        }]
      }, {
        itemType: "button",
        horizontalAlignment: "right",
        buttonOptions: {
          text: "Upload",
          type: "default",
          onClick: function () {
            var dataForm = $("#formWizard").dxForm("instance").option("formData");

            // console.log(dataForm);

            $.ajax({
              url: `${urlREST}` + "/wizard",
              method: "POST",
              processData: true,
              contentType: "application/json",
              data: JSON.stringify(dataForm)
            }).done(function (msg) {
              DevExpress.ui.notify("Upload sucessfully");
            });
            
          }
        }
      }
    ]
  });
};