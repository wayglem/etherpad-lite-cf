# Update this forked etherpad-lite from upstream

In order to update this fork you will need to follow these instructions

**Note**: We assume that you cloned this repo

## 1. merge from upstream

First you will need to merge from a released version of etherpad:

1. `git remote add upstream https://github.com/ether/etherpad-lite.git`
2. `git fetch --tags upstream`
3. `git merge <current-release-tag-name>` (e.g.: `git merge 1.7.5` )

Here you will have a bunch of files which need to be merged manually.

## 2. merge manually `README.md`

Use the `README.md` from this repo, forget all modification

## 3. merge manually `src/node/utils/Settings.js` 

Here take all modification from upstream.
Now we will need to put the code to make it Cloud Foundry ready.

To do so, first add the beggining of the file these two lines:

```javascript
var cfenv = require("cfenv");
var appEnv = cfenv.getAppEnv();
```

You will also need to find where configuration is exported. Normally, this code look like that:
```javascript
//we know this setting, so we overwrite it
    //or it's a settings hash, specific to a plugin
    if(exports[i] !== undefined || i.indexOf('ep_')==0)
    {
      if (_.isObject(settings[i]) && !_.isArray(settings[i])) {
        exports[i] = _.defaults(settings[i], exports[i]);
      } else {
        exports[i] = settings[i];
      }
    }
    //this setting is unkown, output a warning and throw it away
    else
    {
      console.warn("Unknown Setting: '" + i + "'. This setting doesn't exist or it was removed");
}
```

Add this after those lines:
```javascript
var dbService = /.*(db|database|pg|postgres|mysql|mongo|lite|level|dirty|redis|couch|elasticsearch).*/i;

    if (appEnv.getService(dbService) != null
        && appEnv.getService(dbService).credentials.uri != undefined
        && appEnv.getService(dbService).credentials.uri != null) {
        var parseDbUrl = require("parse-database-url");
        var dbConfig = parseDbUrl(appEnv.getService(dbService).credentials.uri);

        exports.dbType = dbConfig.driver;
        /**
         * This setting is passed with dbType to ueberDB to set up the database
         */
        exports.dbSettings = {
            "user": dbConfig.user,
            "password": dbConfig.password,
            "host": dbConfig.host,
            "port": dbConfig.port,
            "database": dbConfig.database
        }
    }


    var ldapService = /.*ldap.*/i;

    if (appEnv.getService(ldapService) != null) {
        exports.users.ldapauth = appEnv.getService(ldapService).credentials;
}
```

This will now Cloud Foundry ready.

## 3. add root `package.json` with tested etherpad plugins dependencies 

```json
"engines": {
    "node": "8.x" // npm line need to be removed but you can change the nodejs version here
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/cloudfoundry-community/etherpad-lite-cf.git"
  },
  "dependencies": { // add the compatible plugins 
    "ep_adminpads": "0.0.12",
    "ep_colors": "0.0.3",
    "ep_headings2": "0.0.9",
    "ep_historicalsearch": "0.0.8",
    "ep_list_pads": "0.0.4",
    "ep_pad-lister": "1.1.3",
    "ep_pad_tracker": "0.0.9",
    "ep_previewimages": "0.0.9",
    "ep_prompt_for_name": "0.1.0",
    "ep_public_view": "0.0.5",
    "ep_scrollto": "0.0.6",
    "ep_set_title_on_pad": "0.1.4",
    "ep_table_of_contents": "0.1.15",
    "ep_tables2": "0.2.13",
    "ep_wrap": "0.0.4"
  },
  "version": "<current-release>-cf" // e.g.: 1.6.3-cf
```

**Note**: At this moment you can check if there is new version of plugin, all etherpad plugins start with `ep_`

## 4. merge manually `src/package.json`

Choose the file from upstream and update engine, repository and version like you did in step 3.

Now you will need to add required dependencies in the `src/package.json`. 
So, add in `dependencies` (don't forget the comma just before adding these dependencies):

```json
"cfenv": "1.0.0",
"parse-database-url": "*"
```

## 5. Create a release

Push all your modification to this repo and create a release. 
The tag name of this release should be `<current-release>-cf` (e.g.: `1.6.3-cf`)

Travis will do the rest, after travis complete its task it will upload a `etherpad-lite-cf.zip` file which will be useable.
