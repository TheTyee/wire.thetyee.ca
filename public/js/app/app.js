window.App = {};
window.JST = {};

// Use the backbone.layoutmanager
// turn it on for all views by default

Backbone.Layout.configure({
    manage: true,
    // Set the prefix to where your templates live on the server, but keep in
    // mind that this prefix needs to match what your production paths will be.
    // Typically those are relative.  So we'll add the leading `/` in `fetch`.
    prefix: "/templates/",

    // This method will check for prebuilt templates first and fall back to
    // loading in via AJAX.
    fetchTemplate: function(path) {
        console.log(path);
        // Check for a global JST object.  When you build your templates for
        // production, ensure they are all attached here.
        var JST = window.JST || {};

        // If the path exists in the object, use it instead of fetching remotely.
        if (JST[path]) {
            console.log('cached');
            return JST[path];
        }

        // If it does not exist in the JST object, mark this function as
        // asynchronous.
        var done = this.async();

        // Fetch via jQuery's GET.  The third argument specifies the dataType.
        $.get(path + '.html', function(contents) {
            console.log('fetch');
            // Assuming you're using underscore templates, the compile step here is
            // `_.template`.
            done(_.template(contents));
        }, "text");
    }
});

// ===================================================================
// Models
// ===================================================================
App.FeedItem = Backbone.Model.extend({
    date: '',
    friendlydate: '',
    shares: '',
    initialize: function(){
        console.log('Creating a new model');
        //console.log(this);
        // Parse the pubdate property & return a friendly date from now
        var friendly = moment(this.get("pubdate")).fromNow();
        var pubfriendly     = moment(this.get("pubdate")).toDate();
        this.set("date", pubfriendly);
        this.set("friendlydate", friendly);
        var share_count = this.get("count_fb") + this.get("count_go") + this.get("count_li") + this.get("count_su") + this.get("count_tw");
        this.set("shares", share_count);
    },
    parse: function(model){ // This is used after a fetch to massage the data...
        // It's causing a problem now because it double-saves after a model update
        // Parse the pubdate property & return a friendly date from now
        // console.log(model.pubdate);
        // var friendly = moment(model.pubdate).fromNow();
        // var date     = moment(model.pubdate).toDate();
        // model.date   = date;
        // model.friendlydate = friendly;
        return model;
    },
    urlRoot : '/items'

});

App.Source = Backbone.Model.extend({
    initialize: function(){
        console.log('Creating a new Source model');
    },
    urlRoot: '/sources'
});

App.Category = Backbone.Model.extend({
    initialize: function(){
        console.log('Creating a new Category model');
    },
    urlRoot : '/categories'
});

// ===================================================================
// Collections
// ===================================================================
App.FeedItemCollection = Backbone.Collection.extend({
    model: App.FeedItem,
    page: 1,
    limit: 20,
    category: '',
    hot: 'true',
    url: function(){
        return '/items/' + '?limit=' + this.limit + '&page=' + this.page + '&category=' + this.category + '&hot=' + this.hot;
    },
    //url: '/items.json',
    initialize: function(options){
        if ( options && options.category ) {
            this.set("category", options.category);
        }
    },
    //comparator: '-pubdate'
});

App.feedItems = new App.FeedItemCollection();
_.each(items_json, function(item) {
    App.feedItems.add(item);
});

App.SourceCollection = Backbone.Collection.extend({
    model: App.Source,
    page: 1,
    limit: 20,
    category: '',
    url: function(){
        return '/sources/' + '?limit=' + this.limit + '&page=' + this.page + '&category=' + this.category;
    },
    initialize: function(){
        console.log('Creating a new Sources collection');
    },
    comparator: 'name'
});

App.sources = new App.SourceCollection();
// TODO (probably remove)
//_.each(sources_json, function(item) {
    //App.sources.add(item);
//});

App.CategoryCollection = Backbone.Collection.extend({
    model: App.Category,
    category: '',
    url: function(){
        return '/categories/';
    },
    initialize: function(){
        console.log('Creating a new Categories collection');
    },
    comparator: 'name'
});

App.categories = new App.CategoryCollection();
_.each(cats_json, function(item) {
    App.categories.add(item);
});


// ===================================================================
// Views
// ===================================================================
App.FeedRiverView = Backbone.View.extend({
    //collection: App.feedItems,
    serialize: function() {
        return { items: this.collection };
    },
    template: 'feed-app-river',
    events: {
    },
    initialize: function () {
        console.log('FeedRiverView initialized');
        // Listen to events on the collection
        this.listenTo(this.collection, "remove reset sync", this.render);
    },
    render: function () {

    },
    beforeRender: function() {
        this.collection.each(function(item) {
            this.insertView(new App.FeedItemView({ model: item }));
        }, this);
    }
});

App.FeedItemView = Backbone.View.extend({
    template: 'feed-app-river-item',
    el: false,
    events: {
        "click button.delete": "deactivateModel",
        "click button.edit":   "editModel",
        "click button.save":   "saveModel",
        "click .cancel":       function() { this.$el.removeClass("editing"); }
    },
    bindings: {
        'h1[data-bind="title"]': 'title',
        'p[data-bind="description"]': 'description',
        'input[data-bind="title"]': 
            {
            'observe': 'title',
            'events': ['blur'],
        },
        'input[data-bind="description"]': 
            {
            'observe': 'description',
            'events': ['blur'],
        }
    },
    initialize: function () {
        console.log('FeedItemView initialized');
        this.listenTo(this.model, 'change', this.saveModel);

    },
    render: function () {
    },
    afterRender: function() {
        this.stickit();
    },
    saveModel: function(){
        console.log("Saving...");
        console.log( this.model.changedAttributes() );
        this.model.save( this.model.changedAttributes(), { patch: true });
        //this.model.save();
    },
    deactivateModel: function() {
        // TODO going to need a db schema update
        console.log('Deactivating item');
        this.model.set("status", "deleted");
        App.feedItems.remove(this.model);
    },
    editModel: function() {
        console.log(this.$el);
        this.$el.addClass("editing");
    }
});

App.FeedCategoryView = Backbone.View.extend({
    template: 'feed-app-river-category',
    serialize: function() {
        return { items: this.collection.models };
    },
    events: {
    },
    bindings: {
    },
    initialize: function () {
        console.log('FeedCategoryView initialized');
        //        this.listenTo(this.model, 'change:title', this.saveModel);

    },
    render: function () {
    },
    afterRender: function() {
        //        this.stickit();
    }
});

App.CategoryHeaderView = Backbone.View.extend({
    template: 'category-header',
    events: {
    },
    bindings: {
        'h1[data-bind="name"]':
            {
            'observe': 'name',
            'events': ['blur']
        },
        'h2[data-bind="description"]':
            {
            'observe': 'description',
            'events': ['blur']
        }
    },
    initialize: function () {
        console.log('CategoryHeaderView initialized');
        this.listenTo(this.model, 'change', this.saveModel);
    },
    saveModel: function () {
        console.log('Saving category...');
        console.log( this.model.changedAttributes() );
        this.model.save( this.model.changedAttributes(), { patch: true });
    },
    render: function () {
    },
    afterRender: function() {
        this.stickit();
    }
});


App.FeedNavigationView = Backbone.View.extend({
    template: 'feed-app-nav',
    initialize: function () {
        console.log('FeedNavView initialized');
        this.listenTo(this.collection, "reset sync", this.render);
    },
    render: function () {
    },
    events: {
        "click button": "addItems"
    },
    addItems: function(){
        var self = this;
        console.log("Adding items");
        this.collection.page++;
        this.collection.fetch({remove: false});
    },
    setMore: function(response){
        if ( response.length < 20 ) {
            this.collection.more = false;      
        }
    },
    afterRender: function() {
        if ( this.collection.more === false ) {
            this.remove();
        }
    }
});

App.SourcesView = Backbone.View.extend({
    collection: App.sources,
    template: 'feed-app-sources',
    serialize: function() {
        return { items: this.collection };
    },
    initialize: function () {
        console.log('SourcesView initialized');
        this.listenTo(this.collection, "remove reset sync", this.render);
    },
    events: {
        "click .new" : "addSource"
    },
    render: function () {
    },
    beforeRender: function() {
        this.collection.each(function(item) {
            this.insertView(new App.SourceItemView({ model: item }));
        }, this);
    },
    addSource: function() {
        console.log('Adding a source...');
        //var source = new App.Source({
                //"name": 'Give it a name',
                //"description": 'And a description',
                //"contact_name": 'Contact name',
                //"contact_email": 'Contact email',
                //"url": 'URL!'
        //});
        //App.sources.add( source );
    }
});

App.SourceItemView = Backbone.View.extend({
    template: 'feed-app-sources-item',
    el: false,
    events: {
        "click button.delete": "deactivateModel",
        "click button.edit":   "editModel",
        "click button.save":   "saveModel",
        "click .cancel":       function() { this.$el.removeClass("editing"); }
    },
    bindings: {
        'h2[data-bind="name"]': 'name',
        'p[data-bind="description"]': 'description',
        'span[data-bind="category"]': 'category',
        'input[data-bind="name"]': 
            {
            'observe': 'name',
            'events': ['blur'],
        },
        'input[data-bind="description"]': 
            {
            'observe': 'description',
            'events': ['blur'],
        },
        'input[data-bind="contact_name"]': 'contact_name',
        'input[data-bind="contact_email"]': 'contact_email', 
        'select.categories': {
            observe: 'category',
            selectOptions: {
                collection: App.categories,
                labelPath: 'name',
                valuePath: 'id'
            }
        }
    },
    initialize: function () {
        console.log('SourceItemView initialized');
        //this.listenTo(this.model, 'change', this.saveModel);
    },
    render: function () {
    },
    afterRender: function() {
        this.stickit();
    },
    saveModel: function(){
        console.log("Saving...");
        console.log(this.model);
        this.model.save( 
                        {   
                            "id": this.model.get('id'),
                            "name": this.model.get('name'),
                            "description": this.model.get('description'),
                            "category": this.model.get('category'),
                            "contact_name": this.model.get('contact_name'),
                            "contact_email": this.model.get('contact_email')
                        }
      , { patch: true });
  //this.model.save();
    },
    deactivateModel: function() {
        console.log('Deactivating item');
        this.model.set("status", "deleted");
        App.sources.remove(this.model);
    },
    editModel: function() {
        console.log(this.$el);
        this.$el.addClass("editing");
    }
});


App.SourceDetailView = Backbone.View.extend({
    template: 'feed-app-source-detail',
    events: {
        "click button.delete": "deactivateModel",
        "click button.edit":   "editModel",
        "click button.save":   "saveModel",
        "click .cancel":       function() { this.$el.removeClass("editing"); }
    },
    bindings: {
        'h2[data-bind="name"]': 'name',
        'p[data-bind="description"]': 'description',
        'span[data-bind="category"]': 'category',
        'input[data-bind="name"]': 
            {
            'observe': 'name',
            'events': ['blur'],
        },
        'input[data-bind="description"]': 
            {
            'observe': 'description',
            'events': ['blur'],
        },
        'input[data-bind="contact_name"]': 'contact_name',
        'input[data-bind="contact_email"]': 'contact_email', 
        'select.categories': {
            observe: 'category',
            selectOptions: {
                collection: App.categories,
                labelPath: 'name',
                valuePath: 'id'
            }
        }
    },
    initialize: function () {
        console.log('SourceDetailView initialized');
        this.collection = new App.FeedItemCollection();
        this.listenTo(this.collection, "reset sync", this.render);
        this.listenTo(this.model, "reset sync change", this.render);
    },
    beforeRender: function() {
        var self = this;
        var items = this.model.get('items');
        _.each(items, function(item) {
            self.collection.add(item);
        });
        this.collection.each(function(item) {
            this.insertView("#items", new App.FeedItemView({ model: item }));
        }, this); 
    },
    render: function () {
    },
    afterRender: function() {
        this.stickit();
    },
    saveModel: function(){
        console.log("Saving...");
        console.log(this.model);
        this.model.save( 
                        {   
                            "id": this.model.get('id'),
                            "name": this.model.get('name'),
                            "description": this.model.get('description'),
                            "category": this.model.get('category'),
                            "contact_name": this.model.get('contact_name'),
                            "contact_email": this.model.get('contact_email')
                        }
      , { patch: true });
  //this.model.save();
    },
    deactivateModel: function() {
        console.log('Deactivating item');
        this.model.set("status", "deleted");
        App.sources.remove(this.model);
    },
    editModel: function() {
        console.log(this.$el);
        this.$el.addClass("editing");
    }
});

App.CategoriesView = Backbone.View.extend({
    collection: App.categories,
    serialize: function() {
        return { items: this.collection };
    },
    template: 'feed-app-categories',
    initialize: function () {
        console.log('CategoriesView initialized');
        this.listenTo(this.collection, "remove reset sync", this.render);
    },
    render: function () {
    },
    beforeRender: function() {
        this.collection.each(function(item) {
            this.insertView(new App.CategoryItemView({ model: item }));
        }, this);
    }
});

App.CategoryItemView = Backbone.View.extend({
    template: 'feed-app-category-item',
    el: false,
    events: {
        "click button.delete": "deactivateModel",
        "click button.edit":   "editModel",
        "click button.save":   "saveModel",
        "click .cancel":       function() { this.$el.removeClass("editing"); }
    },
    bindings: {
        'h2[data-bind="name"]': 'name',
        'p[data-bind="description"]': 'description',
        'input[data-bind="name"]': 
            {
            'observe': 'name',
            'events': ['blur'],
        },
        'input[data-bind="description"]': 
            {
            'observe': 'description',
            'events': ['blur'],
        }
    },
    initialize: function () {
        console.log('CategoryItemView initialized');
        //this.listenTo(this.model, 'change', this.saveModel);
    },
    render: function () {
    },
    afterRender: function() {
        this.stickit();
    },
    saveModel: function(){
        console.log("Saving...");
        console.log(this.model);
        this.model.save( 
                        {   
                            "id": this.model.get('id'),
                            "name": this.model.get('name'),
                            "description": this.model.get('description')
                        }
      , { patch: true });
  //this.model.save();
    },
    deactivateModel: function() {
        console.log('Deactivating item');
        this.model.set("status", "deleted");
        App.sources.remove(this.model);
    },
    editModel: function() {
        console.log(this.$el);
        this.$el.addClass("editing");
    }
});


// ===================================================================
// Layouts
// ===================================================================
App.Layout = new Backbone.Layout({
    // Attach the Layout to the main container.
    el: "#content",
    template: "feed-app-layout",
    views: {
        //".secondary": new LoginView()
        //"#river":  new App.FeedRiverView(),
        //"footer": new App.FeedNavigationView(),
    },
    initialize: function(){ 
    }
});

// ===================================================================
// Router
// ===================================================================

App.Router = Backbone.Router.extend({
    routes: {
        '' : 'start',
        'sources/:id' : 'displaySource',
        'sources' : 'displaySources',
        'categories' : 'displayCategories',
        'category/:id' : 'displayCategory',
        '*default': 'defaultRoute'
    },
    start: function() {
        App.Layout.setView("#app-content", new App.FeedRiverView({ collection: App.feedItems }) );
        App.Layout.setView("footer", new App.FeedNavigationView({ collection: App.feedItems }) );
        App.Layout.setView("#categories", new App.FeedCategoryView({ collection: App.categories }) );
        App.Layout.removeView("header");
        App.Layout.render();
    },
    displaySource: function(id) {
        console.log('displaying source id ' + id );
        var source = new App.Source({"id" : id });
        source.fetch().done(function(){
            console.log(source);
            //source.fetch(function(model, response, options){ console.log(response); },function(model, response, options){ console.log(response); } );
            App.Layout.setView("#app-content", new App.SourceDetailView({ model: source }));
            App.Layout.render();
        });
    },
    displaySources: function() {
        console.log('displaying sourcees');
        App.Layout.setView("#app-content", new App.SourcesView() );
        App.sources.fetch();
        App.Layout.render();
    },
    displayCategories: function() {
        console.log('displaying categories');
        // TODO 
        App.Layout.setView("#app-content", new App.CategoriesView() );
        App.Layout.render();
    },
    displayCategory: function(id) {
        console.log('displaying category id ' + id );
        App.categoryItems = new App.FeedItemCollection();
        App.categoryItems.category = id;
        App.categoryItems.fetch();
        var category = App.categories.get(id) 
        console.log( category );
        //        var source = App.sources.get(id);
        //        source.fetch(function(model, response, options){ console.log(response); },function(model, response, options){ console.log(response); } );
        App.Layout.setView("#app-content", new App.FeedRiverView({ collection: App.categoryItems }));
        App.Layout.setView("header", new App.CategoryHeaderView({ model: category }));
        App.Layout.render();

    },
    initialize: function() {

    }
});
