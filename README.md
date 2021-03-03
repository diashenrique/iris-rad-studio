
# IRIS RAD Studio
IRIS RAD Studio it's a low-code solution that came to make the developer's life easier; Allowing everyone to create their CRUD based on a simple class definition or even a CSV file.  

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation

1. Clone/git pull the repo into any local directory

```
$ git clone https://github.com/diashenrique/iris-rad-studio.git
```

2. Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Test it

Open in the URL in browser: [http://localhost:52773/csp/irisapp/login.html](http://localhost:52773/csp/irisapp/login.html)

### If you want to test the app without installing anything

[https://irisrad.contest.community.intersystems.com/csp/irisapp/login.html](https://irisrad.contest.community.intersystems.com/csp/irisapp/login.html)

Login with _SYSTEM user

![IRIS RAD Studio](https://raw.githubusercontent.com/diashenrique/iris-rad-studio/master/images/login.png)

After the login, you will see the list of forms/classes available to work with:
![List forms](https://raw.githubusercontent.com/diashenrique/iris-rad-studio/master/images/ListForms.png)

When you click on the desired form, a Datagrid with all information provided for that specific class is shown.
![DataGrid](https://raw.githubusercontent.com/diashenrique/iris-rad-studio/master/images/DataGrid.png)

The Datagrid has the option to edit/delete the information, even adding a new one.
![Editing the Information](https://raw.githubusercontent.com/diashenrique/iris-rad-studio/master/images/FormEditing.png)

Besides the possibility to filter the information, you also have the option to group the info.
![Grouping the info](https://raw.githubusercontent.com/diashenrique/iris-rad-studio/master/images/Grouping.png)

If you have a CSV file that you want to import to the system, the IRIS RAD Studio will create a class, import the data from the CSV file, generate a cube class, a sample dashboard, and also provide a form to edit the imported information provided by the CSV file.
![Import Wizard](https://raw.githubusercontent.com/diashenrique/iris-rad-studio/master/images/ImportWizard.png)

Ahhhh, and we also have a Dark Mode option! :) 
![Dark mode](https://raw.githubusercontent.com/diashenrique/iris-rad-studio/master/images/DarkMode.png)

## Dream team

- [Henrique Dias](https://community.intersystems.com/user/henrique-dias-2)
- [José Roberto Pereira](https://community.intersystems.com/user/jos%C3%A9-roberto-pereira-0)
  