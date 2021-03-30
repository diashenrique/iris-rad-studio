function createMenu() {
  var currPage = location.pathname.split('/').slice(-1)[0];
  var userInfo = getUserInfo();
  if (userInfo) {
    menuForms('#menu', currPage);
    /*
    if (userInfo.admin === 1) menuApps('#menu', currPage);
    if (userInfo.admin === 1) menuClassCreator('#menu', currPage);
    if (userInfo.admin === 1) menuDeploy('#menu', currPage);
    if (userInfo.admin === 1) menuWizard('#menu', currPage);
    */
    menuApps('#menu', currPage);
    menuClassCreator('#menu', currPage);
    menuDeploy('#menu', currPage);
    menuWizard('#menu', currPage);
    menuDSW('#menu');
    menuLogout('#menu');
  }
}

function menuApps(element, currPage) {
  $(element).append(`
  <li class="menu-item ${currPage === 'apps.html' ? 'has-active' : ''}">
    <a href="apps.html" class="menu-link">
      <span class="menu-icon fa fa-folder-open"></span>
      <span class="menu-text">Applications</span>
    </a>
  </li>
  `);
}

function menuForms(element, currPage) {
  $(element).append(`
  <li class="menu-item ${currPage === 'rad.html' ? 'has-active' : ''}">
    <a href="rad.html" class="menu-link">
      <span class="menu-icon fa fa-clone"></span>
      <span class="menu-text">Forms</span>
    </a>
    <!-- child menu -->
    <ul id="menu-forms" class="menu">
    </ul>
  </li>
  `);
}

function menuClassCreator(element, currPage) {
  $(element).append(`
  <li class="menu-item ${currPage === 'classcreator.html' ? 'has-active' : ''}">
    <a href="classcreator.html" class="menu-link">
      <span class="menu-icon fas fa-table"></span>
      <span class="menu-text">Create Class</span>
    </a>
  </li>
  `);
}

function menuDeploy(element, currPage) {
  $(element).append(`
  <li class="menu-item ${currPage === 'deploy.html' ? 'has-active' : ''}">
    <a href="deploy.html" class="menu-link">
      <span class="menu-icon fas fa-cloud-upload-alt"></span>
      <span class="menu-text">Deploy app</span>
    </a>
  </li>
  `);
}

function menuWizard(element, currPage) {
  $(element).append(`
  <li class="menu-item ${currPage === 'wizard.html' ? 'has-active' : ''}">
    <a href="wizard.csp" class="menu-link">
      <span class="menu-icon fas fa-cubes"></span>
      <span class="menu-text">Import Wizard</span>
    </a>
  </li>
  `);
}

function menuDSW(element) {
  $(element).append(`
  <li class="menu-item">
    <a href="../../dsw/index.html#/IRISAPP" class="menu-link" target="_blank">
      <span class="menu-icon fas fa-tachometer-alt"></span>
      <span class="menu-text">DSW Dashboard</span>
    </a>
  </li>
  `);
}

function menuLogout(element) {
  $(element).append(`
  <li class="menu-item">
    <a href="javascript:doLogout()" class="menu-link">
      <span class="menu-icon fas fa-sign-out-alt"></span>
      <span class="menu-text">Logout</span>
    </a>
  </li>
  `);
}

// todo: not used...
function menuIntegraterML(element) {
  $(element).append(`
  <li class="menu-item">
    <a href="#" class="menu-link">
      <span class="menu-icon fas fa-atom"></span>
      <span class="menu-text">IntegratedML</span>
    </a>
  </li>
  `);
}