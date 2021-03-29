# useful commands
## build container with no cache
```
docker-compose build --no-cache
```
## open terminal to docker
```
docker-compose exec iris iris session iris -U IRISAPP
```

## global export
 $System.OBJ.Export("GlobalName.GBL","/irisdev/app/src/gbl/globalname.xml")
```


write "Creating IRIS RAD rest application...",! 
set webName = "/irisrad" 
set webProperties("NameSpace") = "IRISAPP" 
set webProperties("IsNameSpaceDefault") = 0 \
set webProperties("AutheEnabled") = 8224 \
set webProperties("AutheEnabled") = 8192 \
set webProperties("CookiePath") = "/irisrad/" 
set webProperties("MatchRoles") = ":%DB_%DEFAULT" \
set webProperties("DispatchClass") = "dc.irisrad.rest.Main" 
  set sc = ##class(Security.Applications).Create(webName, .webProperties) \




<Resource Name="IRISRADAuthentication.MAC"/>
<Resource Name="ZAUTHENTICATE.MAC"/>

      