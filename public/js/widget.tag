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
  }
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
      donor_count:          "Donors",
      financed:             "financed",
      donate:               "View & donate",
      visit:                "Visit page",
      donations_prohibited: "Leider kann zurzeit nicht online gespendet werden.",
    },
    de: {
      donor_count:          "Spender",
      financed:             "finanziert",
      donate:               "Informieren & spenden",
      visit:                "Seite besuchen",
      donations_prohibited: "Leider kann zurzeit nicht online gespendet werden.",
    }
  },

  init: function() {
    var params = riot.route.query()
    this.lang = ['de', 'en'].indexOf(params.l) === -1 ? 'de' : params.l
    this.t = this.translations[this.lang]
   }
}

<widget>
  <project record_url={ record_url } client_url={ client_url }></project>

  <script>
    this.mixin(TranslationMixin)
    var params       = riot.route.query()
    var api_host     = (params.api_host || 'https://www.betterplace.org')
    var api_base_url = api_host + '/' + this.lang + '/api_v4'
    this.record_url  = api_base_url + document.location.pathname

    if(params.client) {
      this.client_url = api_base_url + '/clients/' + params.client + '/widget_config'
    }
  </script>
</widget>
