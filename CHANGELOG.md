Changelog
=========

r4
---------

- Added photos sorting in admin front-end catalog;
- Fixed send E-Mail notify by forms.<br>
  <strong>WARNING!</strong> Added new field (e-mail sender)
  to config.yaml.example
  (don't forget add it to your local config.yaml);
- Added non-relation data.
  <strong>WARNING!</strong> Added new model (new tables in database),
  you need to upgrade your database by this file:
  [migration_r3_to_r4.sql](avto-lux/migrations/migration_r3_to_r4.sql).

r3
---------

- Fixed UTF-8 bug.

r2
---------

- Fixed redirects for all pages;
- Removed debug prints;
- Added counters (only for production);
- Fixed 3 columns in catalog for Android native browsers;
- Added DEBUG flag to config and debug conditions;
- Use native input[type=date] field if it supports;
- robots.txt (diallow all for DEBUG mode);
- Fixed bug in admin interface;
- Catalog detail page photos crop.
