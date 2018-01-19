# CYPRIPEDIUM

<table width="100%">
<tr><td>
<img alt="Cypripedium reginae image" src="app/assets/images/cypripedium.png">
</td><td>
A repository for managing and discovering assets for the Federal Reserve Bank of Minneapolis.
<a href="https://en.wikipedia.org/wiki/Cypripedium_reginae"><em>Cypripedium reginae</em></a>
is a rare, terrestrial, temperate, lady's-slipper orchid native to northern North America. It is the <a href="http://www.dnr.state.mn.us/snapshots/plants/showyladysslipper.html">state flower of Minnesota</a>.
<br/><br/>

[![Build Status](https://travis-ci.org/curationexperts/cypripedium.svg?branch=master)](https://travis-ci.org/curationexperts/cypripedium)      
[![Dependency Status](https://gemnasium.com/badges/github.com/curationexperts/cypripedium.svg)](https://gemnasium.com/github.com/curationexperts/cypripedium)     
[![Coverage Status](https://coveralls.io/repos/github/curationexperts/cypripedium/badge.svg?branch=master)](https://coveralls.io/github/curationexperts/cypripedium?branch=master)    
[![Inline docs](http://inch-ci.org/github/curationexperts/cypripedium.svg?branch=master)](http://inch-ci.org/github/curationexperts/cypripedium)     
[![Stories in Ready](https://badge.waffle.io/curationexperts/cypripedium.png?label=ready&title=Ready)](https://waffle.io/curationexperts/cypripedium)  

</td></tr>
</table>

## Developer Setup

1. Change to your working directory for new development projects   
    `cd .`
1. Clone this repo   
    `git clone https://github.com/curationexperts/cypripedium.git`
1. Change to the application directory  
    `cd cypripedium`
1. Use set your ruby version to **2.4.2** and the gemset of your choice  
    eg. `rvm use --create 2.4.2@cypripedium`
1. Start redis  
    `redis-server &`  
    *note:* use ` &` to start in the background, or run redis in a new terminal session
1. Start sidekiq: `bundle exec sidekiq -d -l tmp/sidekiq.log`
1. Start the demo server in its own terminal session
    `bin/rails hydra:server`
1. Run the first time setup script  
    `bin/setup`
1. Run the test suite  
    `bin/rails ci`
1. Create a default [admin set](https://samvera.github.io/what-are-admin-things.html).
   To add a new work from the dashboard, you will need to setup a default admin set. You
   do this by running this rake task: `rake hyrax:default_admin_set:create`.

## How to create an admin user on the console

1. Connect to the rails console in the production environment and follow this script:
  ```ruby
  RAILS_ENV=production bundle exec rails c
  2.4.2 :001 > u = User.new
  2.4.2 :002 > u.email = "fake@example.com"
  2.4.2 :003 > u.display_name = "Jane Doe"
  2.4.2 :004 > u.password = "123456"
  2.4.2 :005 > admin_role = Role.where(name: 'admin').first_or_create
   => #<Role id: 1, name: "admin">
  2.4.2 :006 > u.roles << admin_role
   => #<ActiveRecord::Associations::CollectionProxy [#<Role id: 1, name: "admin">]>
  2.4.2 :007 > u.save
   => true
  2.4.2 :011 > u.admin?
  Role Exists (0.2ms)  SELECT  1 AS one FROM "roles" INNER JOIN "roles_users" ON "roles"."id" = "roles_users"."role_id" WHERE "roles_users"."user_id" = ? AND "roles"."name" = ? LIMIT ?  [["user_id", 2], ["name", "admin"], ["LIMIT", 1]]
 => true
  ```

1. If the object won't save, or isn't working as expected, you can check the errors like this:
  ```ruby
  2.4.2 :015 > u = User.new
  2.4.2 :016 > u.email = "bess@curationexperts.com"
  2.4.2 :017 > u.save
   => false
  2.4.2 :018 > u.errors.messages
   => {:email=>["has already been taken"], :password=>["can't be blank"], :orcid=>[]}
  ```

## Re-create derivatives
Provide the id of the work to re-create:
`RAILS_ENV=production bundle exec rake derivatives:recreate_by_id[2801pg32c]`

## Import records from Content DM

To import records using XML files that were exported from Content DM, you can run a rake task and pass in the XML file that you want to import.

This method of importing records is meant to be used only for creating new records.  It's not meant to be used to update/edit existing records.  If you need to re-run an import for some reason, you'll need to delete those existing records from fedora before re-running that import.

**NOTE**: Please notice that there is an extra `--` in each of these rake commands.  This is to differentiate the options for the `import:contentdm` task from options for rake itself.

```bash
  rake import:contentdm -- --input_file /path/to/my_file.xml --data_path /path/to/dir/with/data/files --work_type Publication
```

To print out a list of arguments that you can pass to this rake task:
```bash
  rake import:contentdm -- --help
```

Arguments for the rake task:

| Option Switch | Required? | Notes |
| ------------- | --------- | ----- |
| `--input_file` | required | The path to the XML file that contains the exported records from Content DM |
| `--data_path` | required | The path to the directory that contains the content files |
| `--work_type` | required | The default work type.  This is used to decide which type of record(s) the importer will create.  This value will be ignored if the record in the input XML file has a `<work_type>` entry.  The value for this option must exactly match the class name of the model, including capitalization.  For example, `ConferenceProceeding` is the correct spelling.  `Conference Proceeding` (with a space) or `conferenceproceeding` (with different capitalization) are not valid. |
