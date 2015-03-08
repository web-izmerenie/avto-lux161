Changelog
=========

r7
---------

- HEAD requests handlers;
- Fixed routes for '.html' pages suffix (404 status for addresses without '.html' suffix);
- `robots.txt` editing from admin control panel;
- Removed <meta name="author">.

r6
---------

- Added dynamic sitemap.xml;
- Refactoring for zombie db sessions, catch exceptions and close sessions.

r5
---------

- Fixed redirects with unicode in URI.

r4
---------

- Added photos sorting in admin front-end catalog;
- Fixed send E-Mail notify by forms.<br>
  <strong>WARNING!</strong> Added new field (e-mail sender)
  to config.yaml.example
  (don't forget to add it to your local config.yaml);
- Added non-relation data.<br>
  <strong>WARNING!</strong> Added new model (new tables in database),
  you need to upgrade your database by this file:
  [migration_r3_to_r4.sql](avto-lux/migrations/migration_r3_to_r4.sql);
- Counters now provided by non-relation data model.<br>
  <strong>WARNING!</strong> You need to create non-relation data element
  with code `counters` and create multiple textarea field with code
  `bottom_counters` in admin panel and put your counters to this field;
- <strong>WARNING!</strong> Phones in header and footer, and footer
  E-Mail now provided by non-relation data as codes:

    - `phones` → `header`
    - `phones` → `footer`
    - `email` → `footer`

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
