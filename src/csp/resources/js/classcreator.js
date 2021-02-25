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

$(document).ready(function () {


  $("#select-class").dxSelectBox({
    displayExpr: "className",
    dataSource: companies,
    value: companies[0],
    onValueChanged: function (data) {
      form.option("formData", data.value);
    }
  });

  var form = $("#formClassCreator").dxForm({
    formData: companies[0],
    readOnly: false,
    showColonAfterLabel: false,
    labelLocation: "top",
    minColWidth: 300,
    colCount: "auto"
  }).dxForm("instance");

});


var companies = [{
  "ID": 1,
  "className": "User.Test.Person"
}];