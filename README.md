BC Blogs Re-born for 2015
=========================

## TODO

### Tests
* [ ] Break out json_api tests: items, sources, categories, etc.
* [ ] Test for valid output from mojo app
* [ ] Test for valid output from backbone app
* [ ] Test CRUD features of UI

### Back end
* [x] Add categories for sources
* [x] Output list of items by feed category
* [x] Output list of items by "hot" (social counts)
* [x] Fix issue where feed item is updated to a new URL, but when looking for new items its reimported with the old URL (move fix into the item collection script)
* [x] Add status column to items table, so that items can also be set to deleted (so they are not re-added on the next check/run)
* [x] Finish routes for /categories
* [ ] Switch to Readability Parser API, e.g., https://www.readability.com/api/content/v1/parser?url=http://www.desmogblog.com/2015/07/26/mother-nature-braces-republican-environmental-onslaught&token=ae9e3e6f9e15346638b5b54b3af3710a24cd854c

## Front end

* [x] Re-write app.js to use Backbone Layout Manager for items
* [x] Implement "more" interaction to update collection
* [x] Migrate to async fetch for templates in development mode
* [x] Re-write app.js to use Backbone Layout Manager for sources
* [x] Add route for /categories
* [x] Add route for /hot
* [ ] Remove the category-header template; do something smarter...
* [ ] /source/:id should use a sub-view for the items 
* [ ] dates need to be put in the right timezone! 

## Dream end

* [ ] Move REST endpoints to a full Mojo app with OAuth
* [ ] Only show create/update/delete buttons (or content editable) to an authenticated user
* [ ] Move cron scripts into Minion jobs
* [ ] Embed.ly API for image resizing/croping?
