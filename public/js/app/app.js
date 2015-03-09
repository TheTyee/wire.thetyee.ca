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
    defaults: {
        items: []
    }
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
    url: function(){
        return '/items/' + '?limit=' + this.limit + '&page=' + this.page + '&category=' + this.category;
    },
    //url: '/items.json',
    initialize: function(options){
      if ( options && options.category ) {
        this.set("category", options.category);
      }
    },
    comparator: '-pubdate'
});

App.feedItems = new App.FeedItemCollection();
_.each(items_json, function(item) {
    App.feedItems.add(item);
});

App.HotItemCollection = Backbone.Collection.extend({
    model: App.FeedItem,
    page: 1,
    limit: 20,
    category: '',
    url: function(){
        return '/hot/' + '?limit=' + this.limit + '&page=' + this.page + '&category=' + this.category;
    },
    initialize: function(options){
      if ( options && options.category ) {
        this.set("category", options.category);
      }
    } //,
    // comparator: '-pubdate'
});

App.SourceCollection = Backbone.Collection.extend({
    model: App.Source,
    category: '',
    url: function(){
        if ( this.category ) {
        return '/sources/' + '?category=' + this.category;
        } else {
        return '/sources/';
        }
    },
    initialize: function(){
        console.log('Creating a new Sources collection');
    },
    comparator: 'name'
});

App.sources = new App.SourceCollection();
_.each(sources_json, function(item) {
    App.sources.add(item);
});

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
        this.listenTo(this.collection, "reset sync", this.render);
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
    events: {
    },
    bindings: {
    'h1[data-bind="title"]': 'title',
    'input[data-bind="title"]': 
        {
        'observe': 'title',
        'events': ['blur'],
        }
    },
    initialize: function () {
        console.log('FeedItemView initialized');
        this.listenTo(this.model, 'change:title', this.saveModel);

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
    serialize: function() {
        return { items: this.collection };
    },
    template: 'feed-app-sources',
    initialize: function () {
        console.log('SourcesView initialized');
        this.listenTo(this.collection, "reset sync", this.render);
    },
    render: function () {
    },
    beforeRender: function() {
        this.collection.each(function(item) {
            this.insertView(new App.SourceItemView({ model: item }));
        }, this);
    }
});

App.SourceItemView = Backbone.View.extend({
    template: 'feed-app-sources-item',
    events: {
    },
    initialize: function () {
        console.log('SourceItemView initialized');
    },
    render: function () {
    }
});


App.SourceDetailView = Backbone.View.extend({
    template: 'feed-app-source-detail',
    events: {
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
        'categoryies' : 'displayCategories',
        'category/:id' : 'displayCategory',
        'hot'          : 'displayHot',
        'hot/:id'      :  'displayHotCategory',
        '*default': 'defaultRoute'
  },
    start: function() {
        App.Layout.setView("#app-content", new App.FeedRiverView({ collection: App.feedItems }) );
        App.Layout.setView("footer", new App.FeedNavigationView({ collection: App.feedItems }) );
        App.Layout.setView("#categories", new App.FeedCategoryView({ collection: App.categories }) );
        App.Layout.render();
    },
    displaySource: function(id) {
        console.log('displaying source id ' + id );
        var source = App.sources.get(id);
        source.fetch(function(model, response, options){ console.log(response); },function(model, response, options){ console.log(response); } );
        App.Layout.setView("#app-content", new App.SourceDetailView({ model: source }));
        App.Layout.render();
    },
    displaySources: function() {
        console.log('displaying sourcees');
        App.Layout.setView("#app-content", new App.SourcesView() );
        App.Layout.render();
    },
    displayCategories: function() {
        console.log('displaying categories');
      //  App.Layout.setView("#app-content", new App.SourcesView() );
      //  App.Layout.render();
    },
    displayCategory: function(id) {
        console.log('displaying category id ' + id );
        App.categoryItems = new App.FeedItemCollection();
        App.categoryItems.category = id;
        App.categoryItems.fetch();
//        var source = App.sources.get(id);
//        source.fetch(function(model, response, options){ console.log(response); },function(model, response, options){ console.log(response); } );
        App.Layout.setView("#app-content", new App.FeedRiverView({ collection: App.categoryItems }));
        App.Layout.setView("footer", new App.FeedNavigationView({ collection: App.categoryItems }));
        App.Layout.render();

    },
    displayHot: function() {
        console.log('displaying hot');
        App.hotItems = new App.HotItemCollection();
        App.hotItems.fetch();
        App.Layout.setView("#app-content", new App.FeedRiverView({ collection: App.hotItems }) );
        App.Layout.setView("footer", new App.FeedNavigationView({ collection: App.hotItems }) );
        App.Layout.render();
    },
     displayHotCategory: function(id) {
        console.log('displaying hot category id ' + id );
        App.categoryItems = new App.HotItemCollection();
        App.categoryItems.category = id;
        App.categoryItems.fetch();
//        var source = App.sources.get(id);
//        source.fetch(function(model, response, options){ console.log(response); },function(model, response, options){ console.log(response); } );
        App.Layout.setView("#app-content", new App.FeedRiverView({ collection: App.categoryItems }));
        App.Layout.setView("footer", new App.FeedNavigationView({ collection: App.categoryItems }));
        App.Layout.render();

    },
  initialize: function() {
    
  }
});