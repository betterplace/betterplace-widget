var AjaxMixin = {
  check_status: function(response) {
    if (response.status == 200)
      return Promise.resolve(response)
    else
      return Promise.reject(new Error(response.statusText))
  },

  json: function(response) {
    return response.json()
  },

  handle_error: function(error) {
    // console.log('Fetch Error :-S', error)
  },

  assign_target_promise: function(target) {
    return function(data) {
      this[target] = data
      this.update()
    }.bind(this)
  },

  load: function(url, assign_target) {
    fetch(url)
      .then(this.check_status)
      .then(this.json)
      .then(this.assign_target_promise(assign_target))
      .catch(this.handle_error)
  },
}

var FindLinkMixin = {
  find_link: function(links, rel) {
    for (var i = 0; i < links.length; i++) {
      if(links[i].rel === rel)
        return links[i].href
    }
  }
}

var TranslationMixin = {
  translations: {
    en: {
      donations_count:      "Donations",
      financed:             "financed",
      donate:               "View & donate",
      visit:                "Visit page",
      donations_prohibited: "At the moment you can't donate online.",
      iefallback_text:      "Your version of Internet Explorer is not supported, please visit us on betterplace.org",
    },
    de: {
      donations_count:      "Spenden",
      financed:             "finanziert",
      donate:               "Informieren & spenden",
      visit:                "Seite besuchen",
      donations_prohibited: "Leider kann zurzeit nicht online gespendet werden.",
      iefallback_text:      "In Ihrer Version des Internet Explorers können die Informationen leider nicht geladen werden. Bitte besuchen Sie uns direkt auf betterplace.org",
    }
  },

  init: function() {
    var params = riot.route.query()
    this.lang = ['de', 'en'].indexOf(params.l) === -1 ? 'de' : params.l
    this.t = this.translations[this.lang]
   }
}

<widget class={ widgetClass }>
  <project if={ !oldIE } record_url={ record_url } client_url={ client_url }></project>
  <iefallback if={ oldIE }></iefallback>

  <script>
    this.oldIE = !!window.oldIE

    this.api_hosts = {
      production:  'https://api.betterplace.org',
      staging:     'https://api.bp42.com',
      development: 'http://www.betterplace.dev',
    }
    this.mixin(TranslationMixin)
    var params       = riot.route.query()
    var api_host     = this.api_hosts[(params.env || 'production')]
    var api_base_url = api_host + '/' + this.lang + '/api_v4'
    this.record_url  = api_base_url + document.location.pathname

    if(params.legacy)
      this.widgetClass = 'legacy-size'

    if(params.client) {
      this.client_url = api_base_url + '/clients/' + params.client + '/widget_config'
    }
  </script>
</widget>
